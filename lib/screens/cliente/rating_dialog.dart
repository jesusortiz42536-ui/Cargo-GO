import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

/// Dialog de calificación post-entrega
class RatingDialog extends StatefulWidget {
  final String pedidoDocId;
  final String negocioNombre;
  final String negocioId;
  const RatingDialog({super.key, required this.pedidoDocId, required this.negocioNombre, required this.negocioId});

  static void show(BuildContext context, {required String pedidoDocId, required String negocioNombre, required String negocioId}) {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => RatingDialog(pedidoDocId: pedidoDocId, negocioNombre: negocioNombre, negocioId: negocioId));
  }

  @override State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _negocioRating = 0;
  int _entregaRating = 0;
  bool _aTiempo = true;
  final _comentario = TextEditingController();

  void _submit() async {
    if (_negocioRating == 0) return;
    // Save rating to Firestore
    await FirestoreService.addDocument('calificaciones', {
      'pedido_id': widget.pedidoDocId,
      'negocio_id': widget.negocioId,
      'negocio_nombre': widget.negocioNombre,
      'rating_negocio': _negocioRating,
      'rating_entrega': _entregaRating,
      'a_tiempo': _aTiempo,
      'comentario': _comentario.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('¡Gracias por tu calificación! ⭐', style: TextStyle(color: Colors.white)),
      backgroundColor: AppTheme.gr, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.sf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        const Text('¡Pedido entregado!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        const SizedBox(height: 4),
        const Text('¿Cómo estuvo tu pedido?', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
        const SizedBox(height: 16),
        // Negocio rating
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Row(children: [
              const Text('🏪 ', style: TextStyle(fontSize: 16)),
              Expanded(child: Text(widget.negocioNombre,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
              GestureDetector(onTap: () => setState(() => _negocioRating = i + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(i < _negocioRating ? Icons.star : Icons.star_border,
                    size: 32, color: i < _negocioRating ? AppTheme.yl : AppTheme.td))))),
          ])),
        const SizedBox(height: 10),
        // Entrega rating
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            const Row(children: [
              Text('🚚 ', style: TextStyle(fontSize: 16)),
              Text('Entrega', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
              GestureDetector(onTap: () => setState(() => _entregaRating = i + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(i < _entregaRating ? Icons.star : Icons.star_border,
                    size: 32, color: i < _entregaRating ? AppTheme.yl : AppTheme.td))))),
            const SizedBox(height: 8),
            const Text('¿Llegó a tiempo?', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _tiempoBtn('Sí', true),
              const SizedBox(width: 10),
              _tiempoBtn('No', false),
            ]),
          ])),
        const SizedBox(height: 10),
        // Comentario
        TextField(controller: _comentario, maxLines: 2,
          style: const TextStyle(color: AppTheme.tx, fontSize: 12),
          decoration: InputDecoration(hintText: 'Comentario (opcional)', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 11),
            filled: true, fillColor: AppTheme.cd,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
            contentPadding: const EdgeInsets.all(12))),
        const SizedBox(height: 16),
        // Buttons
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.tm,
              side: const BorderSide(color: AppTheme.bd),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Saltar', style: TextStyle(fontSize: 12)))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: _negocioRating > 0 ? _submit : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gr, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Enviar ✅', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
        ]),
      ])),
    );
  }

  Widget _tiempoBtn(String label, bool val) => GestureDetector(
    onTap: () => setState(() => _aTiempo = val),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: _aTiempo == val ? AppTheme.ac.withOpacity(0.15) : Colors.transparent,
        border: Border.all(color: _aTiempo == val ? AppTheme.ac : AppTheme.bd)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
        color: _aTiempo == val ? AppTheme.ac : AppTheme.tm))));

  @override
  void dispose() { _comentario.dispose(); super.dispose(); }
}
