import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';
import '../../services/role_service.dart';

class SudoPanelScreen extends StatefulWidget {
  final UserSession session;
  const SudoPanelScreen({super.key, required this.session});
  @override State<SudoPanelScreen> createState() => _SudoPanelState();
}

class _SudoPanelState extends State<SudoPanelScreen> {
  int _tab = 0; // 0=Pedidos, 1=Negocios, 2=Franquicias, 3=Stats

  void _logout() async {
    await RoleService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: switch (_tab) {
        0 => _pedidosLive(),
        1 => _negociosPanel(),
        2 => _franquiciasPanel(),
        3 => _statsPanel(),
        _ => _pedidosLive(),
      }),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color: AppTheme.cd, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.pu.withOpacity(0.3), width: 0.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -4))]),
        child: Row(children: [
          _navBtn(0, Icons.receipt_long, 'Pedidos'),
          _navBtn(1, Icons.store, 'Negocios'),
          _navBtn(2, Icons.rocket_launch, 'Franquicias'),
          _navBtn(3, Icons.analytics, 'Stats'),
        ]),
      ),
    );
  }

  Widget _navBtn(int i, IconData ic, String l) {
    final active = _tab == i;
    return Expanded(child: InkWell(onTap: () => setState(() => _tab = i),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: active ? AppTheme.pu.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12)),
            child: Icon(ic, size: 22, color: active ? AppTheme.pu : AppTheme.td)),
          const SizedBox(height: 3),
          Text(l, style: TextStyle(fontSize: 9, color: active ? AppTheme.pu : AppTheme.td,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        ]))));
  }

  // ═══ PEDIDOS EN VIVO ═══
  Widget _pedidosLive() {
    return Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(children: [
          const Text('🛡️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SUDO Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            Text('Hola, ${widget.session.nombre}', style: const TextStyle(fontSize: 10, color: AppTheme.pu)),
          ]),
          const Spacer(),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: AppTheme.rd, size: 20)),
        ])),
      // Live stream
      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.todosLosPedidosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.pu));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('📭', style: TextStyle(fontSize: 50)),
              SizedBox(height: 12),
              Text('Sin pedidos activos', style: TextStyle(color: AppTheme.tm, fontSize: 14)),
            ]));
          }
          final docs = snapshot.data!.docs;
          // Alert: pedidos sin aceptar >5 min
          final now = DateTime.now();
          final alertas = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            if (data['estado'] != 'nuevo') return false;
            final ts = data['timestamp'] as Timestamp?;
            if (ts == null) return false;
            return now.difference(ts.toDate()).inMinutes >= 5;
          }).toList();

          return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            // Alerts
            if (alertas.isNotEmpty)
              Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                  color: AppTheme.rd.withOpacity(0.1), border: Border.all(color: AppTheme.rd.withOpacity(0.4))),
                child: Row(children: [
                  const Icon(Icons.warning_amber, color: AppTheme.rd, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${alertas.length} pedido(s) sin aceptar >5 min',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.rd))),
                ])),
            // Stats row
            Row(children: [
              _miniStat('Total', '${docs.length}', AppTheme.ac),
              _miniStat('Nuevos', '${docs.where((d) => (d.data() as Map)['estado'] == 'nuevo').length}', AppTheme.yl),
              _miniStat('En curso', '${docs.where((d) {
                final e = (d.data() as Map)['estado'] ?? '';
                return e == 'aceptado' || e == 'preparando' || e == 'listo';
              }).length}', AppTheme.or),
              _miniStat('En camino', '${docs.where((d) => (d.data() as Map)['estado'] == 'en_camino').length}', AppTheme.gr),
            ]),
            const SizedBox(height: 12),
            // Pedido cards
            ...docs.map((d) => _sudoPedidoCard(d)),
          ]);
        },
      )),
    ]);
  }

  Widget _miniStat(String label, String value, Color c) {
    return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: c.withOpacity(0.08), border: Border.all(color: c.withOpacity(0.3))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
        Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
      ])));
  }

  Widget _sudoPedidoCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final estado = OrderStatus.fromString(data['estado'] ?? 'nuevo');
    final numero = data['numero_pedido'] ?? doc.id.substring(0, 8);
    final negocio = data['negocio_nombre'] ?? 'Sin negocio';
    final total = data['total'] ?? 0;
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

    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('#$numero', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('${estado.emoji} ${estado.label}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor))),
          const Spacer(),
          Text(fecha, style: const TextStyle(fontSize: 10, color: AppTheme.td)),
        ]),
        const SizedBox(height: 6),
        Text(negocio, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        Row(children: [
          Text('\$$total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.gr, fontFamily: 'monospace')),
          const Spacer(),
          if (estado == OrderStatus.listo)
            GestureDetector(onTap: () => FirestoreService.actualizarEstadoPedidoConHistorial(doc.id, 'en_camino', 'sudo'),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.pu.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.pu.withOpacity(0.4))),
                child: const Text('🚗 En camino', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.pu)))),
          if (estado == OrderStatus.en_camino)
            GestureDetector(onTap: () => FirestoreService.actualizarEstadoPedidoConHistorial(doc.id, 'entregado', 'sudo'),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.gr.withOpacity(0.4))),
                child: const Text('✅ Entregado', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.gr)))),
        ]),
      ]));
  }

  // ═══ NEGOCIOS PANEL ═══
  Widget _negociosPanel() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService.getNegocios(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.pu));
        final negocios = snapshot.data!;
        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            const Text('🏪', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text('Negocios (${negocios.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          ]),
          const SizedBox(height: 16),
          ...negocios.map((n) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppTheme.cd,
                image: n['foto_url'] != null ? DecorationImage(image: NetworkImage(n['foto_url']), fit: BoxFit.cover) : null),
                child: n['foto_url'] == null ? const Icon(Icons.store, color: AppTheme.td, size: 20) : null),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n['nombre'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                Text('${n['plan'] ?? 'gratis'} · ${n['tipo'] ?? ''}', style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (n['activo'] ?? true) ? AppTheme.gr.withOpacity(0.15) : AppTheme.rd.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: Text((n['activo'] ?? true) ? 'Activo' : 'Inactivo',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                    color: (n['activo'] ?? true) ? AppTheme.gr : AppTheme.rd))),
            ]))),
        ]);
      });
  }

  // ═══ FRANQUICIAS PANEL ═══
  Widget _franquiciasPanel() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.db.collection('franquicia_solicitudes').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final nuevas = docs.where((d) => (d.data() as Map)['status'] == 'nuevo').toList();
        final aprobadas = docs.where((d) => (d.data() as Map)['status'] == 'aprobada').toList();
        final enProceso = docs.where((d) => (d.data() as Map)['status'] == 'en_proceso').toList();
        final activas = docs.where((d) => (d.data() as Map)['status'] == 'activa').toList();

        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            const Text('🚀', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            const Text('Franquicias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          ]),
          const SizedBox(height: 16),
          // Stats row
          Row(children: [
            _miniStat('Nuevas', '${nuevas.length}', AppTheme.yl),
            _miniStat('Proceso', '${enProceso.length}', AppTheme.or),
            _miniStat('Activas', '${activas.length + 1}', AppTheme.gr), // +1 for Tulancingo (us)
          ]),
          const SizedBox(height: 16),

          // Tulancingo (base)
          Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.gr.withOpacity(0.4)),
              gradient: LinearGradient(colors: [AppTheme.gr.withOpacity(0.06), Colors.transparent])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('🟢', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Text('Tulancingo (TÚ)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.gr)),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('SEDE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppTheme.gr))),
              ]),
              const SizedBox(height: 6),
              const Text('Ejemplo de éxito y modelo de operación', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
            ])),

          // New solicitudes
          if (nuevas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('SOLICITUDES NUEVAS (${nuevas.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.yl, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...nuevas.map((d) => _solicitudCard(d)),
          ],

          // En proceso
          if (enProceso.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('EN PROCESO (${enProceso.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.or, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...enProceso.map((d) => _franquiciaProcesoCard(d)),
          ],

          // Activas
          if (activas.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('ACTIVAS (${activas.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.gr, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...activas.map((d) => _franquiciaActivaCard(d)),
          ],

          // Income summary
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.yl.withOpacity(0.3)),
              gradient: LinearGradient(colors: [AppTheme.yl.withOpacity(0.06), Colors.transparent])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💰 INGRESOS POR FRANQUICIAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.yl)),
              const SizedBox(height: 10),
              _ingresoRow('Entradas cobradas', '\$${aprobadas.length * 150000 + enProceso.length * 100000}'),
              _ingresoRow('Regalías este mes', '\$${activas.length * 3000}'),
              const Divider(color: AppTheme.bd, height: 16),
              _ingresoRow('Total', '\$${aprobadas.length * 150000 + enProceso.length * 100000 + activas.length * 3000}', bold: true),
            ])),
        ]);
      });
  }

  Widget _solicitudCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.yl.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🆕', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(data['nombre'] ?? 'Sin nombre', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx))),
          Text(_timeAgo(data['timestamp']), style: const TextStyle(fontSize: 9, color: AppTheme.td)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Text('📍 ', style: TextStyle(fontSize: 10)),
          Text(data['ciudad'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        ]),
        Row(children: [
          const Text('💰 ', style: TextStyle(fontSize: 10)),
          Text('Paquete ${data['paquete'] ?? '?'}', style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
          const SizedBox(width: 10),
          const Text('🛵 ', style: TextStyle(fontSize: 10)),
          Text(data['tiene_moto'] == true ? 'Tiene moto' : 'Sin moto', style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        ]),
        Row(children: [
          const Text('📱 ', style: TextStyle(fontSize: 10)),
          Text(data['whatsapp'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () {
              final msg = 'Hola ${data['nombre']}, gracias por tu interés en la franquicia Cargo-GO para ${data['ciudad']}. ¿Podemos agendar una llamada?';
              launchUrl(Uri.parse('https://wa.me/${data['whatsapp']?.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
            },
            child: Container(padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF25D366).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('CONTACTAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF25D366))))))),
          const SizedBox(width: 6),
          Expanded(child: GestureDetector(
            onTap: () => FirestoreService.db.collection('franquicia_solicitudes').doc(doc.id).update({'status': 'en_proceso'}),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('APROBAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.gr)))))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => FirestoreService.db.collection('franquicia_solicitudes').doc(doc.id).update({'status': 'rechazada'}),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.rd.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('❌', style: TextStyle(fontSize: 12)))),
        ]),
      ]));
  }

  Widget _franquiciaProcesoCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.or.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🟡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text('${data['ciudad'] ?? ''} — ${data['nombre'] ?? ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx))),
        ]),
        const SizedBox(height: 4),
        Text('Paquete ${data['paquete'] ?? '?'} · ${data['tiene_moto'] == true ? 'Tiene moto' : 'Sin moto'}',
          style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => FirestoreService.db.collection('franquicia_solicitudes').doc(doc.id).update({'status': 'activa'}),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('ACTIVAR 🟢', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.gr)))))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              final msg = 'Hola ${data['nombre']}, ¿cómo va el proceso de tu franquicia Cargo-GO en ${data['ciudad']}?';
              launchUrl(Uri.parse('https://wa.me/${data['whatsapp']?.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('CONTACTAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.ac)))),
        ]),
      ]));
  }

  Widget _franquiciaActivaCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gr.withOpacity(0.3)),
        gradient: LinearGradient(colors: [AppTheme.gr.withOpacity(0.04), Colors.transparent])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🟢', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text('${data['ciudad'] ?? ''} — ${data['nombre'] ?? ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.gr))),
        ]),
        const SizedBox(height: 4),
        Text('Paquete ${data['paquete'] ?? '?'}', style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
        const SizedBox(height: 8),
        Row(children: [
          GestureDetector(
            onTap: () => FirestoreService.db.collection('franquicia_solicitudes').doc(doc.id).update({'status': 'pausada'}),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.rd.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('PAUSAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.rd)))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://wa.me/${data['whatsapp']?.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent('Hola, revisando tu franquicia Cargo-GO')}'), mode: LaunchMode.externalApplication);
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('CONTACTAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.ac)))),
        ]),
      ]));
  }

  Widget _ingresoRow(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 11, color: AppTheme.tm, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: bold ? AppTheme.yl : AppTheme.tx)),
    ]));

  String _timeAgo(String? ts) {
    if (ts == null) return '';
    final dt = DateTime.tryParse(ts);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  // ═══ STATS PANEL ═══
  Widget _statsPanel() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        const Text('📊', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        const Text('Estadísticas Globales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
      ]),
      const SizedBox(height: 20),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService.getNegocios(),
        builder: (ctx, snap) {
          final negocios = snap.data ?? [];
          return Column(children: [
            Row(children: [
              _statBox('Negocios', '${negocios.length}', AppTheme.or),
              const SizedBox(width: 10),
              _statBox('Activos', '${negocios.where((n) => n['activo'] == true).length}', AppTheme.gr),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _statBox('VIP', '${negocios.where((n) => n['plan'] == 'vip').length}', AppTheme.yl),
              const SizedBox(width: 10),
              _statBox('Pro', '${negocios.where((n) => n['plan'] == 'pro').length}', AppTheme.pu),
            ]),
          ]);
        }),
      const SizedBox(height: 20),
      // Logout
      SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, size: 18, color: AppTheme.rd),
        label: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.rd, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.rd),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      )),
    ]);
  }

  Widget _statBox(String label, String value, Color c) {
    return Expanded(child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.3)), color: c.withOpacity(0.06)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
      ])));
  }
}
