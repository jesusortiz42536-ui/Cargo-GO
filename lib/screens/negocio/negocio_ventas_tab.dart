import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class NegocioVentasTab extends StatefulWidget {
  final String negocioId;
  const NegocioVentasTab({super.key, required this.negocioId});
  @override State<NegocioVentasTab> createState() => _NegocioVentasTabState();
}

class _NegocioVentasTabState extends State<NegocioVentasTab> {
  String _periodo = 'hoy'; // hoy, semana, mes
  Map<String, dynamic> _resumen = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResumen();
  }

  Future<void> _loadResumen() async {
    setState(() => _loading = true);
    final data = await FirestoreService.getVentasResumen(widget.negocioId, _periodo);
    if (!mounted) return;
    setState(() { _resumen = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final totalVentas = _resumen['total_ventas'] ?? 0;
    final numPedidos = _resumen['num_pedidos'] ?? 0;
    final ticketPromedio = numPedidos > 0 ? (totalVentas / numPedidos).round() : 0;
    final productoTop = _resumen['producto_top'] ?? 'N/A';

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Header
      Row(children: [
        const Text('📊', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        const Text('Mis Ventas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
      ]),
      const SizedBox(height: 16),
      // Period pills
      Row(children: [
        for (var f in [('hoy', 'Hoy'), ('semana', 'Semana'), ('mes', 'Mes')])
          Expanded(child: GestureDetector(
            onTap: () { setState(() => _periodo = f.$1); _loadResumen(); },
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                color: _periodo == f.$1 ? AppTheme.or.withOpacity(0.15) : Colors.transparent,
                border: Border.all(color: _periodo == f.$1 ? AppTheme.or : AppTheme.bd)),
              child: Text(f.$2, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _periodo == f.$1 ? AppTheme.or : AppTheme.tm))))),
      ]),
      const SizedBox(height: 20),
      if (_loading) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.or)))
      else ...[
        // Stats grid
        Row(children: [
          _statCard('Ventas', '\$${_formatNumber(totalVentas)}', AppTheme.gr, Icons.attach_money),
          const SizedBox(width: 10),
          _statCard('Pedidos', '$numPedidos', AppTheme.ac, Icons.receipt),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _statCard('Ticket Prom.', '\$$ticketPromedio', AppTheme.or, Icons.analytics),
          const SizedBox(width: 10),
          _statCard('Top Producto', productoTop, AppTheme.pu, Icons.star),
        ]),
        const SizedBox(height: 24),
        // Quick insights
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bd),
            gradient: LinearGradient(
              colors: [AppTheme.cd, AppTheme.sf],
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('💡 Resumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            const SizedBox(height: 10),
            _insightRow('Total vendido', '\$${_formatNumber(totalVentas)}', AppTheme.gr),
            _insightRow('Pedidos completados', '$numPedidos', AppTheme.ac),
            _insightRow('Ticket promedio', '\$$ticketPromedio', AppTheme.or),
            _insightRow('Producto estrella', productoTop, AppTheme.yl),
          ])),
      ],
    ]);
  }

  Widget _statCard(String label, String value, Color c, IconData icon) {
    return Expanded(child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.3)),
        color: c.withOpacity(0.06)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: c),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
      ])));
  }

  Widget _insightRow(String label, String value, Color c) {
    return Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
      ]));
  }

  String _formatNumber(num n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
