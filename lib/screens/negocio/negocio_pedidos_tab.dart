import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class NegocioPedidosTab extends StatefulWidget {
  final String negocioId;
  const NegocioPedidosTab({super.key, required this.negocioId});
  @override State<NegocioPedidosTab> createState() => _NegocioPedidosTabState();
}

class _NegocioPedidosTabState extends State<NegocioPedidosTab> {
  String _filter = 'activos'; // activos, todos, completados

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header
      Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(children: [
          const Text('📋', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          const Text('Pedidos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, size: 8, color: AppTheme.gr),
              SizedBox(width: 4),
              Text('En vivo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.gr)),
            ])),
        ])),
      // Filter pills
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          for (var f in [('activos', 'Activos'), ('todos', 'Todos'), ('completados', 'Completados')])
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                  color: _filter == f.$1 ? AppTheme.or.withOpacity(0.15) : Colors.transparent,
                  border: Border.all(color: _filter == f.$1 ? AppTheme.or : AppTheme.bd)),
                child: Text(f.$2, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _filter == f.$1 ? AppTheme.or : AppTheme.tm))))),
        ])),
      const SizedBox(height: 12),
      // Pedidos stream
      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.pedidosNegocioStream(widget.negocioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.or));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📭', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              Text('Sin pedidos ${_filter == 'activos' ? 'activos' : ''}',
                style: const TextStyle(color: AppTheme.tm, fontSize: 14)),
            ]));
          }
          var docs = snapshot.data!.docs;
          // Filter
          if (_filter == 'activos') {
            docs = docs.where((d) {
              final est = (d.data() as Map)['estado'] ?? 'nuevo';
              return est != 'entregado' && est != 'cancelado';
            }).toList();
          } else if (_filter == 'completados') {
            docs = docs.where((d) {
              final est = (d.data() as Map)['estado'] ?? 'nuevo';
              return est == 'entregado' || est == 'cancelado';
            }).toList();
          }
          if (docs.isEmpty) {
            return Center(child: Text('Sin pedidos ${_filter}', style: const TextStyle(color: AppTheme.tm)));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: docs.length,
            itemBuilder: (_, i) => _pedidoCard(docs[i]),
          );
        },
      )),
    ]);
  }

  Widget _pedidoCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final numero = data['numero_pedido'] ?? doc.id.substring(0, 8);
    final estado = OrderStatus.fromString(data['estado'] ?? 'nuevo');
    final items = data['items'] as List? ?? [];
    final total = data['total'] ?? 0;
    final cliente = data['cliente_nombre'] ?? 'Cliente';
    final tel = data['cliente_telefono'] ?? '';
    final ts = data['timestamp'] as Timestamp?;
    final fecha = ts != null ? '${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}' : '';

    final statusColor = switch (estado) {
      OrderStatus.nuevo => AppTheme.yl,
      OrderStatus.aceptado => AppTheme.ac,
      OrderStatus.preparando => AppTheme.or,
      OrderStatus.listo => AppTheme.gr,
      OrderStatus.en_camino => AppTheme.pu,
      OrderStatus.entregado => AppTheme.gr,
      OrderStatus.cancelado => AppTheme.rd,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: numero + estado + hora
        Row(children: [
          Text('#$numero', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Text('${estado.emoji} ${estado.label}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor))),
          const SizedBox(width: 8),
          Text(fecha, style: const TextStyle(fontSize: 10, color: AppTheme.td)),
        ]),
        const SizedBox(height: 8),
        // Cliente
        Row(children: [
          const Icon(Icons.person, size: 14, color: AppTheme.tm),
          const SizedBox(width: 4),
          Text(cliente, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
          if (tel.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(tel, style: const TextStyle(fontSize: 10, color: AppTheme.td)),
          ],
        ]),
        const SizedBox(height: 6),
        // Items
        ...items.take(3).map((it) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(children: [
            Text('${it['cantidad'] ?? 1}x ', style: const TextStyle(fontSize: 10, color: AppTheme.or, fontWeight: FontWeight.w700)),
            Expanded(child: Text(it['nombre'] ?? '', style: const TextStyle(fontSize: 10, color: AppTheme.tx))),
            Text('\$${it['precio'] ?? 0}', style: const TextStyle(fontSize: 10, color: AppTheme.tm, fontFamily: 'monospace')),
          ]),
        )),
        if (items.length > 3)
          Text('+${items.length - 3} más...', style: const TextStyle(fontSize: 9, color: AppTheme.td)),
        const SizedBox(height: 8),
        // Total + actions
        Row(children: [
          Text('Total: \$$total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
          const Spacer(),
          // Action buttons based on status
          if (estado == OrderStatus.nuevo) ...[
            _actionBtn('Rechazar', AppTheme.rd, Icons.close, () => _cambiarEstado(doc.id, 'cancelado')),
            const SizedBox(width: 6),
            _actionBtn('Aceptar', AppTheme.gr, Icons.check, () => _cambiarEstado(doc.id, 'aceptado')),
          ],
          if (estado == OrderStatus.aceptado)
            _actionBtn('Preparando', AppTheme.or, Icons.restaurant, () => _cambiarEstado(doc.id, 'preparando')),
          if (estado == OrderStatus.preparando)
            _actionBtn('Listo', AppTheme.gr, Icons.check_circle, () => _cambiarEstado(doc.id, 'listo')),
        ]),
      ]),
    );
  }

  Widget _actionBtn(String label, Color c, IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withOpacity(0.4))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
        ])));
  }

  void _cambiarEstado(String docId, String nuevoEstado) async {
    await FirestoreService.actualizarEstadoPedidoConHistorial(
      docId, nuevoEstado, 'negocio');
  }
}
