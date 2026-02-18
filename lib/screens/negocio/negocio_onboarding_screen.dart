import 'dart:convert';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class NegocioOnboardingScreen extends StatefulWidget {
  const NegocioOnboardingScreen({super.key});
  @override State<NegocioOnboardingScreen> createState() => _NegocioOnboardingState();
}

class _NegocioOnboardingState extends State<NegocioOnboardingScreen> {
  int _step = 0; // 0-4

  // Step 0: Nombre y tipo
  final _nombreCtrl = TextEditingController();
  String _tipo = 'comida';
  // Step 1: Contacto
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  // Step 2: Dirección y horario
  final _dirCtrl = TextEditingController();
  final _horarioCtrl = TextEditingController();
  // Step 3: Descripción
  final _descCtrl = TextEditingController();
  // Step 4: Plan
  String _plan = 'gratis';

  bool _saving = false;

  final _tipos = [
    ('comida', '🍽️ Comida'),
    ('farmacia', '💊 Farmacia'),
    ('tienda', '🛒 Tienda'),
    ('cafe', '☕ Café'),
    ('postres', '🎂 Postres'),
    ('otro', '📦 Otro'),
  ];

  final _planes = [
    ('gratis', 'Gratis', '20 pedidos/mes', '\$0'),
    ('basico', 'Básico', '100 pedidos/mes', '\$199/mes'),
    ('pro', 'Pro', 'Ilimitado + stats', '\$499/mes'),
    ('ilimitado', 'Ilimitado', 'Todo + prioridad', '\$999/mes'),
  ];

  void _next() {
    if (_step == 0 && _nombreCtrl.text.trim().isEmpty) { _showError('Ingresa el nombre'); return; }
    if (_step == 1 && _telCtrl.text.trim().length < 10) { _showError('Ingresa un teléfono válido'); return; }
    if (_step == 1 && _passCtrl.text.trim().length < 4) { _showError('La contraseña debe tener al menos 4 caracteres'); return; }
    if (_step < 4) setState(() => _step++);
    else _register();
  }

  void _register() async {
    setState(() => _saving = true);
    try {
      final hash = sha256.convert(utf8.encode(_passCtrl.text.trim())).toString();
      // Create negocio in Firestore
      final negocioId = await FirestoreService.addDocumentWithId('negocios', {
        'nombre': _nombreCtrl.text.trim(),
        'tipo': _tipo,
        'descripcion': _descCtrl.text.trim(),
        'direccion': _dirCtrl.text.trim(),
        'zona': _dirCtrl.text.trim(),
        'horario': _horarioCtrl.text.trim(),
        'telefono': _telCtrl.text.trim(),
        'plan': _plan,
        'activo': true,
        'ciudad': 'tulancingo',
        'rating': 0,
        'pedidos_count': 0,
        'prep_time_min': 10,
        'prep_time_max': 20,
        'creado': DateTime.now().toIso8601String(),
      });
      // Create negocio_usuarios
      await FirestoreService.addDocument('negocio_usuarios', {
        'telefono': _telCtrl.text.trim().replaceAll(RegExp(r'\D'), ''),
        'password_hash': hash,
        'negocio_id': negocioId,
        'nombre_contacto': _contactoCtrl.text.trim(),
        'activo': true,
        'creado': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      showDialog(context: context, barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.sf,
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            const Text('¡Negocio Registrado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            const SizedBox(height: 8),
            Text('Bienvenido a Cargo-GO\nYa puedes iniciar sesión en tu panel.',
              textAlign: TextAlign.center, style: TextStyle(color: AppTheme.tm, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.or,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Ir a Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )),
          ])));
    } catch (e) {
      if (mounted) _showError('Error al registrar: $e');
    }
    if (mounted) setState(() => _saving = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppTheme.rd, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF060B18)])),
        child: SafeArea(child: Column(children: [
          // Back + progress
          Padding(padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm),
                onPressed: () => _step > 0 ? setState(() => _step--) : Navigator.pop(context)),
              Expanded(child: Row(children: List.generate(5, (i) =>
                Expanded(child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
                    color: i <= _step ? AppTheme.or : AppTheme.bd)))))),
              Text('${_step + 1}/5', style: const TextStyle(color: AppTheme.tm, fontSize: 11)),
            ])),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildStep())),
          // Next button
          Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _saving ? null : _next,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.or, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_step == 4 ? 'Registrar Negocio 🚀' : 'Siguiente',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ))),
        ])),
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    0 => _stepNombre(),
    1 => _stepContacto(),
    2 => _stepDireccion(),
    3 => _stepDescripcion(),
    4 => _stepPlan(),
    _ => _stepNombre(),
  };

  Widget _stepNombre() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('🏪', style: TextStyle(fontSize: 50)),
    const SizedBox(height: 12),
    const Text('¿Cómo se llama tu negocio?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tx)),
    const SizedBox(height: 20),
    _field('Nombre del negocio', _nombreCtrl, 'Ej: Cocina Doña Mary'),
    const SizedBox(height: 16),
    const Text('¿Qué tipo de negocio es?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.tx)),
    const SizedBox(height: 10),
    Wrap(spacing: 8, runSpacing: 8, children: _tipos.map((t) =>
      GestureDetector(onTap: () => setState(() => _tipo = t.$1),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
            color: _tipo == t.$1 ? AppTheme.or.withOpacity(0.15) : Colors.transparent,
            border: Border.all(color: _tipo == t.$1 ? AppTheme.or : AppTheme.bd)),
          child: Text(t.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: _tipo == t.$1 ? AppTheme.or : AppTheme.tm))))).toList()),
  ]);

  Widget _stepContacto() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('📱', style: TextStyle(fontSize: 50)),
    const SizedBox(height: 12),
    const Text('Datos de contacto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tx)),
    const SizedBox(height: 20),
    _field('Nombre de contacto', _contactoCtrl, 'Tu nombre'),
    _field('Teléfono (10 dígitos)', _telCtrl, '7711234567', keyboard: TextInputType.phone),
    _field('Contraseña para el panel', _passCtrl, 'Mínimo 4 caracteres'),
    Text('Esta contraseña la usarás para entrar a tu panel de negocio',
      style: TextStyle(fontSize: 10, color: AppTheme.td)),
  ]);

  Widget _stepDireccion() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('📍', style: TextStyle(fontSize: 50)),
    const SizedBox(height: 12),
    const Text('¿Dónde estás?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tx)),
    const SizedBox(height: 20),
    _field('Dirección', _dirCtrl, 'Calle, número, colonia'),
    _field('Horario (ej: 8:00-21:00)', _horarioCtrl, 'Lun-Sáb 9:00-20:00'),
  ]);

  Widget _stepDescripcion() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('✍️', style: TextStyle(fontSize: 50)),
    const SizedBox(height: 12),
    const Text('Cuéntanos de tu negocio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tx)),
    const SizedBox(height: 20),
    _field('Descripción', _descCtrl, '¿Qué ofreces? ¿Qué te hace especial?', maxLines: 4),
  ]);

  Widget _stepPlan() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('💎', style: TextStyle(fontSize: 50)),
    const SizedBox(height: 12),
    const Text('Elige tu plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tx)),
    const SizedBox(height: 6),
    Text('Puedes cambiar después', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
    const SizedBox(height: 20),
    ...(_planes.map((p) => GestureDetector(
      onTap: () => setState(() => _plan = p.$1),
      child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
          color: _plan == p.$1 ? AppTheme.or.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: _plan == p.$1 ? AppTheme.or : AppTheme.bd, width: _plan == p.$1 ? 2 : 1)),
        child: Row(children: [
          Icon(_plan == p.$1 ? Icons.check_circle : Icons.circle_outlined,
            color: _plan == p.$1 ? AppTheme.or : AppTheme.td, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.$2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: _plan == p.$1 ? AppTheme.or : AppTheme.tx)),
            Text(p.$3, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
          ])),
          Text(p.$4, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
            color: _plan == p.$1 ? AppTheme.or : AppTheme.tm)),
        ]))))),
  ]);

  Widget _field(String label, TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(padding: const EdgeInsets.only(bottom: 14),
      child: TextField(controller: ctrl, maxLines: maxLines, keyboardType: keyboard,
        style: const TextStyle(color: AppTheme.tx, fontSize: 14),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppTheme.or, fontSize: 12),
          hintText: hint, hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
          filled: true, fillColor: AppTheme.cd,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.or)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14))));
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _telCtrl.dispose(); _passCtrl.dispose();
    _contactoCtrl.dispose(); _dirCtrl.dispose(); _horarioCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
