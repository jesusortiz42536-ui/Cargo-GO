import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class ProponerNegocioScreen extends StatefulWidget {
  const ProponerNegocioScreen({super.key});
  @override State<ProponerNegocioScreen> createState() => _ProponerNegocioState();
}

class _ProponerNegocioState extends State<ProponerNegocioScreen> {
  final _nombreCtrl = TextEditingController();
  final _zonaCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _comentCtrl = TextEditingController();
  String _tipo = 'comida';
  bool _saving = false;

  final _tipos = [
    ('comida', '🍔 Comida'),
    ('farmacia', '💊 Farmacia'),
    ('tienda', '🛒 Tienda'),
    ('ropa', '👗 Ropa'),
    ('postres', '🎂 Postres'),
    ('otro', '📦 Otro'),
  ];

  void _proponer() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ingresa el nombre del negocio', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.rd, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _saving = true);
    await FirestoreService.addDocument('negocios_propuestos', {
      'nombre': _nombreCtrl.text.trim(),
      'tipo': _tipo,
      'zona': _zonaCtrl.text.trim(),
      'telefono': _telCtrl.text.trim(),
      'comentario': _comentCtrl.text.trim(),
      'votos': 1,
      'status': 'nuevo',
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    // Show success
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.sf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 50)),
        const SizedBox(height: 12),
        const Text('¡Gracias por tu propuesta!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        const SizedBox(height: 8),
        Text('Vamos a invitar a\n"${_nombreCtrl.text.trim()}" a unirse\na Cargo-GO',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.tm)),
        const SizedBox(height: 6),
        const Text('Te avisamos cuando esté listo 🔔', style: TextStyle(fontSize: 10, color: AppTheme.td)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () {
            final msg = '¡Ayúdame a convencer a ${_nombreCtrl.text.trim()} de unirse a Cargo-GO! 🚚\nEntra y vota: cargo-go.web.app';
            final url = 'https://wa.me/?text=${Uri.encodeComponent(msg)}';
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          },
          icon: const Text('📲', style: TextStyle(fontSize: 14)),
          label: const Text('Compartir con amigos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
        const SizedBox(height: 8),
        TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); },
          child: const Text('Cerrar', style: TextStyle(color: AppTheme.tm))),
      ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.sf,
        title: const Text('💡 Propón un negocio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('¿Qué negocio te gustaría\nencontrar en Cargo-GO?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        const SizedBox(height: 20),
        // Nombre
        _field('🏪 Nombre', _nombreCtrl, 'Ej: Tacos El Güero'),
        // Tipo
        const Text('📂 ¿Qué vende?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.or)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _tipos.map((t) =>
          GestureDetector(onTap: () => setState(() => _tipo = t.$1),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                color: _tipo == t.$1 ? AppTheme.or.withOpacity(0.15) : Colors.transparent,
                border: Border.all(color: _tipo == t.$1 ? AppTheme.or : AppTheme.bd)),
              child: Text(t.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: _tipo == t.$1 ? AppTheme.or : AppTheme.tm))))).toList()),
        const SizedBox(height: 16),
        // Zona
        _field('📍 ¿Dónde está?', _zonaCtrl, 'Colonia o dirección aprox'),
        // Teléfono
        _field('📱 ¿Sabes su teléfono? (opcional)', _telCtrl, '', keyboard: TextInputType.phone),
        // Comentario
        _field('💬 ¿Por qué lo recomiendas?', _comentCtrl, 'Me gusta porque...', maxLines: 3),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: _saving ? null : _proponer,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.or, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: _saving
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('PROPONER 🚀', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        )),
      ]),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.or)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, maxLines: maxLines, keyboardType: keyboard,
          style: const TextStyle(color: AppTheme.tx, fontSize: 13),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
            filled: true, fillColor: AppTheme.cd,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.or)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
      ]));
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _zonaCtrl.dispose(); _telCtrl.dispose(); _comentCtrl.dispose();
    super.dispose();
  }
}
