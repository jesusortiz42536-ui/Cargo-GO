import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class PedidoChatScreen extends StatefulWidget {
  final String pedidoId;
  final String negocioNombre;
  final bool esNegocio;
  const PedidoChatScreen({super.key, required this.pedidoId, required this.negocioNombre, this.esNegocio = false});
  @override State<PedidoChatScreen> createState() => _PedidoChatState();
}

class _PedidoChatState extends State<PedidoChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    FirestoreService.db.collection('pedidos').doc(widget.pedidoId)
      .collection('chat').add({
        'mensaje': text,
        'de': widget.esNegocio ? 'negocio' : 'cliente',
        'timestamp': FieldValue.serverTimestamp(),
      });
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.sf,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('💬 Chat — Pedido', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          Text(widget.negocioNombre, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
        ]),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        // Messages
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.db.collection('pedidos').doc(widget.pedidoId)
            .collection('chat').orderBy('timestamp').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.ac));
            final msgs = snapshot.data!.docs;
            if (msgs.isEmpty) {
              return const Center(child: Text('Sin mensajes aún\nEscribe para iniciar la conversación',
                textAlign: TextAlign.center, style: TextStyle(color: AppTheme.td, fontSize: 12)));
            }
            return ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final data = msgs[i].data() as Map<String, dynamic>;
                final esMio = widget.esNegocio ? data['de'] == 'negocio' : data['de'] == 'cliente';
                final ts = data['timestamp'] as Timestamp?;
                final hora = ts != null ? '${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}' : '';
                return _msgBubble(data['mensaje'] ?? '', esMio, hora, data['de'] == 'negocio');
              });
          })),
        // Input
        Container(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(color: AppTheme.sf, border: Border(top: BorderSide(color: AppTheme.bd))),
          child: SafeArea(child: Row(children: [
            Expanded(child: TextField(controller: _msgCtrl,
              style: const TextStyle(color: AppTheme.tx, fontSize: 13),
              decoration: InputDecoration(hintText: 'Escribe mensaje...', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
                filled: true, fillColor: AppTheme.cd,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              onSubmitted: (_) => _send())),
            const SizedBox(width: 8),
            GestureDetector(onTap: _send,
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.ac),
                child: const Icon(Icons.send, color: Colors.white, size: 20))),
          ]))),
      ]),
    );
  }

  Widget _msgBubble(String text, bool esMio, String hora, bool esNeg) {
    return Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esMio) Text(esNeg ? '🏪' : '👤', style: const TextStyle(fontSize: 14)),
          if (!esMio) const SizedBox(width: 6),
          Flexible(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: esMio ? AppTheme.ac.withOpacity(0.2) : AppTheme.cd,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(esMio ? 16 : 4),
                bottomRight: Radius.circular(esMio ? 4 : 16))),
            child: Column(crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
              Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.tx)),
              const SizedBox(height: 2),
              Text(hora, style: const TextStyle(fontSize: 8, color: AppTheme.td)),
            ]))),
          if (esMio) const SizedBox(width: 6),
          if (esMio) Text(esNeg ? '🏪' : '👤', style: const TextStyle(fontSize: 14)),
        ]));
  }

  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }
}
