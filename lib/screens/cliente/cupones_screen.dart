import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class CuponesScreen extends StatefulWidget {
  const CuponesScreen({super.key});
  @override State<CuponesScreen> createState() => _CuponesScreenState();
}

class _CuponesScreenState extends State<CuponesScreen> {
  List<Map<String, dynamic>> _cupones = [];
  bool _loading = true;
  final _codigoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCupones();
  }

  Future<void> _loadCupones() async {
    setState(() => _loading = true);
    try {
      final snap = await FirestoreService.db.collection('cupones')
        .where('activo', isEqualTo: true).get();
      if (!mounted) return;
      setState(() {
        _cupones = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _aplicarCodigo() {
    final code = _codigoCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    final cupon = _cupones.firstWhere((c) => (c['codigo'] ?? '').toString().toUpperCase() == code,
      orElse: () => <String, dynamic>{});
    if (cupon.isNotEmpty) {
      Navigator.pop(context, cupon);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cupón no válido', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.rd, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.sf,
        title: const Text('🎟️ Cupones y Promos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Apply code
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.ac.withOpacity(0.3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('¿Tienes un código?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: _codigoCtrl,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: AppTheme.tx, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
                decoration: InputDecoration(hintText: 'BIENVENIDO', hintStyle: const TextStyle(color: AppTheme.td),
                  filled: true, fillColor: AppTheme.sf,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _aplicarCodigo,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Aplicar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            ]),
          ])),
        const SizedBox(height: 20),
        // Welcome coupon (always shown)
        _cuponCard(
          titulo: '🎉 Tu primer envío GRATIS',
          desc: 'Código: BIENVENIDO\nSe aplica automáticamente en tu primer pedido',
          color: AppTheme.gr,
          codigo: 'BIENVENIDO',
        ),
        const SizedBox(height: 16),
        // Promos from Firestore
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.ac)))
        else ...[
          if (_cupones.isNotEmpty)
            const Text('Promos activas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          ..._cupones.map((c) => _cuponCard(
            titulo: c['nombre'] ?? 'Promo',
            desc: c['descripcion'] ?? '',
            color: Color(int.tryParse('FF${(c['color'] ?? 'FFA502').toString().replaceAll('#', '')}', radix: 16) ?? 0xFFFFA502),
            codigo: c['codigo'] ?? '',
          )),
        ],
      ]),
    );
  }

  Widget _cuponCard({required String titulo, required String desc, required Color color, required String codigo}) {
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        gradient: LinearGradient(colors: [color.withOpacity(0.08), Colors.transparent])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        if (codigo.isNotEmpty) ...[
          const SizedBox(height: 8),
          GestureDetector(onTap: () { Clipboard.setData(ClipboardData(text: codigo));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Código $codigo copiado',
              style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.gr, behavior: SnackBarBehavior.floating)); },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(codigo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, fontFamily: 'monospace', letterSpacing: 2)),
                const SizedBox(width: 6),
                Icon(Icons.copy, size: 14, color: color),
              ]))),
        ],
      ]));
  }

  @override
  void dispose() { _codigoCtrl.dispose(); super.dispose(); }
}
