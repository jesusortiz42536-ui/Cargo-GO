import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class ReferidosScreen extends StatelessWidget {
  final String codigo;
  const ReferidosScreen({super.key, this.codigo = 'CARGO2026'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.sf,
        title: const Text('🎁 Invita a un amigo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 20),
        const Center(child: Text('🎁', style: TextStyle(fontSize: 60))),
        const SizedBox(height: 16),
        const Center(child: Text('INVITA A UN AMIGO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.tx))),
        const SizedBox(height: 20),
        // Code box
        const Center(child: Text('Comparte tu código:', style: TextStyle(fontSize: 12, color: AppTheme.tm))),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () { Clipboard.setData(ClipboardData(text: codigo));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Código copiado', style: TextStyle(color: Colors.white)),
              backgroundColor: AppTheme.gr, behavior: SnackBarBehavior.floating)); },
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.yl, width: 2)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(codigo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.yl, fontFamily: 'monospace', letterSpacing: 3)),
              const SizedBox(width: 10),
              const Icon(Icons.copy, size: 18, color: AppTheme.yl),
            ]))),
        const SizedBox(height: 24),
        // Benefit
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [AppTheme.gr.withOpacity(0.1), AppTheme.ac.withOpacity(0.05)])),
          child: const Column(children: [
            Text('Cuando tu amigo haga su primer pedido, LOS DOS ganan:', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.tm)),
            SizedBox(height: 12),
            Text('🎉 1 ENVÍO GRATIS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.gr)),
          ])),
        const SizedBox(height: 24),
        // Share buttons
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
          onPressed: () {
            final msg = '¡Hola! 🚚 Te invito a usar Cargo-GO, la app de envíos de Tulancingo. Usa mi código $codigo y tu primer envío es GRATIS 🎉\n\nDescarga: cargo-go.web.app';
            final url = 'https://wa.me/?text=${Uri.encodeComponent(msg)}';
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          },
          icon: const Text('📲', style: TextStyle(fontSize: 18)),
          label: const Text('Compartir por WhatsApp', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        )),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(
          onPressed: () { Clipboard.setData(ClipboardData(text: 'Usa mi código $codigo en Cargo-GO y tu primer envío es GRATIS 🎉 cargo-go.web.app'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Link copiado', style: TextStyle(color: Colors.white)),
              backgroundColor: AppTheme.ac, behavior: SnackBarBehavior.floating)); },
          icon: const Icon(Icons.link, color: AppTheme.ac),
          label: const Text('Compartir link 🔗', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ac)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.ac),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        )),
        const SizedBox(height: 24),
        // Stats
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
          child: Column(children: [
            _statRow('Amigos invitados', '0'),
            _statRow('Envíos gratis ganados', '0'),
          ])),
      ]),
    );
  }

  Widget _statRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
      Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    ]));
}
