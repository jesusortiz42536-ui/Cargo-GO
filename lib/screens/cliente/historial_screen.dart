import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class HistorialScreen extends StatefulWidget {
  final void Function(List<Map<String, dynamic>> items, String negocio)? onRepetir;
  const HistorialScreen({super.key, this.onRepetir});
  @override State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _telCtrl = TextEditingController();
  List<Map<String, dynamic>> _pedidos = [];
  bool _loading = false;
  bool _loaded = false;

  void _buscar() async {
    final tel = _telCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (tel.length < 10) return;
    setState(() { _loading = true; _loaded = false; });
    final pedidos = await FirestoreService.getPedidosPorTelefono(tel);
    if (!mounted) return;
    setState(() { _pedidos = pedidos; _loading = false; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.sf,
        title: const Text('📜 Mis Pedidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Phone input
        const Text('📱 Tu teléfono', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.or)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _telCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.tx, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '771-xxx-xxxx', hintStyle: const TextStyle(color: AppTheme.td),
              prefixText: '+52 ', prefixStyle: const TextStyle(color: AppTheme.tm),
              filled: true, fillColor: AppTheme.cd,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            onSubmitted: (_) => _buscar())),
          const SizedBox(width: 8),
          SizedBox(height: 48, child: ElevatedButton(
            onPressed: _loading ? null : _buscar,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('VER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          )),
        ]),
        const SizedBox(height: 20),
        // Results
        if (_loaded && _pedidos.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(40),
            child: Text('No encontramos pedidos con este teléfono', textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.tm, fontSize: 12)))),
        ..._pedidos.map(_pedidoCard),
      ]),
    );
  }

  Widget _pedidoCard(Map<String, dynamic> p) {
    final numero = p['numero_pedido'] ?? '';
    final negocio = p['negocio_nombre'] ?? '';
    final items = p['items'] as List? ?? [];
    final total = p['total'] ?? 0;
    final estado = p['estado'] ?? 'nuevo';
    final ts = p['timestamp'] as Timestamp?;
    final fecha = ts != null ? _formatDate(ts.toDate()) : '';
    final rating = p['calificacion'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bd)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(fecha, style: const TextStyle(fontSize: 10, color: AppTheme.td)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: estado == 'entregado' ? AppTheme.gr.withOpacity(0.15) : AppTheme.or.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
            child: Text(estado == 'entregado' ? '✅ Entregado' : estado,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                color: estado == 'entregado' ? AppTheme.gr : AppTheme.or))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Text('🏪 ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(negocio, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx))),
        ]),
        const SizedBox(height: 4),
        ...items.take(3).map((it) => Text(
          '${it['cantidad'] ?? 1}x ${it['nombre'] ?? ''} · \$${it['precio'] ?? 0}',
          style: const TextStyle(fontSize: 10, color: AppTheme.tm))),
        if (items.length > 3) Text('+${items.length - 3} más', style: const TextStyle(fontSize: 9, color: AppTheme.td)),
        const SizedBox(height: 6),
        Row(children: [
          Text('\$$total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
          if (rating != null) ...[
            const SizedBox(width: 8),
            Text('⭐ $rating', style: const TextStyle(fontSize: 10, color: AppTheme.yl)),
          ],
          const Spacer(),
          if (estado == 'entregado')
            GestureDetector(onTap: () {
              if (widget.onRepetir != null) {
                widget.onRepetir!(List<Map<String, dynamic>>.from(items), negocio);
                Navigator.pop(context);
              }
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.ac.withOpacity(0.4))),
              child: const Text('🔄 Repetir', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.ac)))),
        ]),
      ]));
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hoy ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Ayer ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() { _telCtrl.dispose(); super.dispose(); }
}
