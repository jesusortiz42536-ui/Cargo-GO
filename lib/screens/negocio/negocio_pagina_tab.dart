import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class NegocioPaginaTab extends StatefulWidget {
  final String negocioId;
  const NegocioPaginaTab({super.key, required this.negocioId});
  @override State<NegocioPaginaTab> createState() => _NegocioPaginaTabState();
}

class _NegocioPaginaTabState extends State<NegocioPaginaTab> {
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _horarioCtrl = TextEditingController();
  final _prepMinCtrl = TextEditingController();
  final _prepMaxCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _dirCtrl = TextEditingController();
  Map<String, dynamic> _negocio = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadNegocio();
  }

  Future<void> _loadNegocio() async {
    setState(() => _loading = true);
    final negocios = await FirestoreService.getNegocios();
    final n = negocios.firstWhere((x) => x['id'] == widget.negocioId, orElse: () => <String, dynamic>{});
    if (!mounted) return;
    setState(() {
      _negocio = n;
      _nombreCtrl.text = n['nombre'] ?? '';
      _descCtrl.text = n['descripcion'] ?? n['desc'] ?? '';
      _horarioCtrl.text = n['horario'] ?? '';
      _prepMinCtrl.text = '${n['prep_time_min'] ?? 10}';
      _prepMaxCtrl.text = '${n['prep_time_max'] ?? 20}';
      _telCtrl.text = n['telefono'] ?? n['tel'] ?? '';
      _dirCtrl.text = n['direccion'] ?? n['zona'] ?? '';
      _loading = false;
    });
  }

  void _save() async {
    setState(() => _saving = true);
    await FirestoreService.updateNegocio(widget.negocioId, {
      'nombre': _nombreCtrl.text.trim(),
      'descripcion': _descCtrl.text.trim(),
      'horario': _horarioCtrl.text.trim(),
      'prep_time_min': int.tryParse(_prepMinCtrl.text) ?? 10,
      'prep_time_max': int.tryParse(_prepMaxCtrl.text) ?? 20,
      'telefono': _telCtrl.text.trim(),
      'direccion': _dirCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cambios guardados', style: TextStyle(color: Colors.white)),
      backgroundColor: AppTheme.gr, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.or));

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Header
      Row(children: [
        const Text('🏪', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        const Text('Mi Página', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
      ]),
      const SizedBox(height: 20),
      // Preview card
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.or.withOpacity(0.4), width: 1.5),
          gradient: LinearGradient(colors: [AppTheme.cd, AppTheme.sf])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vista previa', style: TextStyle(fontSize: 10, color: AppTheme.td)),
          const SizedBox(height: 8),
          Row(children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppTheme.or.withOpacity(0.2)),
              child: _negocio['foto_url'] != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_negocio['foto_url'], fit: BoxFit.cover))
                : const Icon(Icons.store, color: AppTheme.or)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_nombreCtrl.text.isEmpty ? 'Mi Negocio' : _nombreCtrl.text,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
              Text('🕐 ${_prepMinCtrl.text}-${_prepMaxCtrl.text} min · ${_horarioCtrl.text}',
                style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
            ])),
          ]),
        ])),
      const SizedBox(height: 20),
      // Fields
      _field('Nombre del negocio', _nombreCtrl),
      _field('Descripción', _descCtrl, maxLines: 2),
      _field('Horario (ej: 8:00-21:00)', _horarioCtrl),
      Row(children: [
        Expanded(child: _field('Prep. mín (min)', _prepMinCtrl, keyboard: TextInputType.number)),
        const SizedBox(width: 10),
        Expanded(child: _field('Prep. máx (min)', _prepMaxCtrl, keyboard: TextInputType.number)),
      ]),
      _field('Teléfono', _telCtrl, keyboard: TextInputType.phone),
      _field('Dirección', _dirCtrl),
      const SizedBox(height: 20),
      // Save button
      SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.or, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: _saving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      )),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: TextField(controller: ctrl, maxLines: maxLines, keyboardType: keyboard,
        style: const TextStyle(color: AppTheme.tx, fontSize: 13),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
          filled: true, fillColor: AppTheme.cd,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.or)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))));
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _descCtrl.dispose(); _horarioCtrl.dispose();
    _prepMinCtrl.dispose(); _prepMaxCtrl.dispose(); _telCtrl.dispose(); _dirCtrl.dispose();
    super.dispose();
  }
}
