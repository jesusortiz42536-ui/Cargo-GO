import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../main.dart';

class TicketScreen extends StatelessWidget {
  final Map<String, dynamic> pedido;
  const TicketScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final numero = pedido['numero_pedido'] ?? 'CG-000';
    final items = pedido['items'] as List? ?? [];
    final subtotal = pedido['subtotal'] ?? 0;
    final envio = pedido['envio'] ?? 35;
    final total = pedido['total'] ?? 0;
    final metodo = pedido['metodo_pago'] ?? 'efectivo';
    final tiempoMin = pedido['tiempo_estimado_min'] ?? 25;
    final tiempoMax = pedido['tiempo_estimado_max'] ?? 40;
    final negocio = pedido['negocio_nombre'] ?? '';
    final cliente = pedido['cliente_nombre'] ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF060B18)])),
        child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
          // Close button
          Align(alignment: Alignment.centerRight,
            child: IconButton(onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppTheme.tm))),
          // Ticket card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.ac.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))]),
            child: Column(children: [
              // Logo
              Container(width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppTheme.ac.withOpacity(0.8), AppTheme.ac])),
                child: const Icon(Icons.local_shipping, color: Colors.white, size: 30)),
              const SizedBox(height: 12),
              const Text('Cargo-GO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text('Envíos en Tulancingo', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
              const SizedBox(height: 16),
              // Dotted divider
              _dottedDivider(),
              const SizedBox(height: 12),
              // Numero
              Text('PEDIDO $numero', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E), letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(DateTime.now().toString().substring(0, 16), style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
              if (negocio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(negocio, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
              ],
              const SizedBox(height: 16),
              // Items
              ...items.map((it) => Padding(padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Text('${it['cantidad'] ?? 1}x', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFFA502))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(it['nombre'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF333333)))),
                  Text('\$${it['precio'] ?? 0}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFF333333), fontFamily: 'monospace')),
                ]))),
              const SizedBox(height: 12),
              _dottedDivider(),
              const SizedBox(height: 12),
              // Totals
              _totalRow('Subtotal', '\$$subtotal'),
              _totalRow('Envío', '\$$envio'),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
                Text('\$$total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A2E), fontFamily: 'monospace')),
              ]),
              const SizedBox(height: 12),
              _dottedDivider(),
              const SizedBox(height: 12),
              // Pago
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Método de pago', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                Text(_metodoPagoLabel(metodo), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
              ]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tiempo estimado', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                Text('$tiempoMin-$tiempoMax min', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFFA502))),
              ]),
              if (cliente.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Cliente', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                  Text(cliente, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
                ]),
              ],
              const SizedBox(height: 20),
              // Agradecimiento
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  '¡Gracias por tu compra!\nTu apoyo impulsa los negocios\nlocales de Tulancingo 💛',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF795548), height: 1.4),
                )),
            ]),
          ),
          const SizedBox(height: 20),
          // Download PDF button
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
            onPressed: () => _downloadPdf(context),
            icon: const Icon(Icons.download, size: 20),
            label: const Text('Descargar Ticket PDF', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          )),
          const SizedBox(height: 12),
          // Back button
          SizedBox(width: double.infinity, height: 48, child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.tm,
              side: const BorderSide(color: AppTheme.bd),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Volver al inicio', style: TextStyle(fontWeight: FontWeight.w600)),
          )),
        ])),
      ),
    );
  }

  Widget _dottedDivider() => Row(children: List.generate(40, (i) =>
    Expanded(child: Container(height: 1, color: i.isEven ? const Color(0xFFDDDDDD) : Colors.transparent))));

  Widget _totalRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
      Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF444444), fontFamily: 'monospace')),
    ]));

  String _metodoPagoLabel(String m) => switch (m) {
    'mercadopago' => 'MercadoPago',
    'efectivo' => 'Efectivo',
    'whatsapp' => 'WhatsApp',
    'spei' => 'SPEI',
    'farmacia' => 'Farmacia Madrid',
    _ => m,
  };

  void _downloadPdf(BuildContext context) async {
    final items = pedido['items'] as List? ?? [];
    final numero = pedido['numero_pedido'] ?? 'CG-000';
    final subtotal = pedido['subtotal'] ?? 0;
    final envio = pedido['envio'] ?? 35;
    final total = pedido['total'] ?? 0;
    final metodo = pedido['metodo_pago'] ?? 'efectivo';
    final tiempoMin = pedido['tiempo_estimado_min'] ?? 25;
    final tiempoMax = pedido['tiempo_estimado_max'] ?? 40;

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, 200 * PdfPageFormat.mm, marginAll: 5 * PdfPageFormat.mm),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Text('CARGO-GO', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text('Envíos en Tulancingo', style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 8),
        pw.Divider(),
        pw.Text('PEDIDO $numero', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Text(DateTime.now().toString().substring(0, 16), style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 8),
        pw.Divider(),
        ...items.map((it) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(children: [
            pw.Text('${it['cantidad'] ?? 1}x ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Expanded(child: pw.Text(it['nombre'] ?? '', style: const pw.TextStyle(fontSize: 9))),
            pw.Text('\$${it['precio'] ?? 0}', style: const pw.TextStyle(fontSize: 9)),
          ]))),
        pw.SizedBox(height: 6),
        pw.Divider(),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('\$$subtotal', style: const pw.TextStyle(fontSize: 9)),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Envío', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('\$$envio', style: const pw.TextStyle(fontSize: 9)),
        ]),
        pw.SizedBox(height: 4),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('TOTAL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text('\$$total', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.SizedBox(height: 6),
        pw.Divider(),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Pago:', style: const pw.TextStyle(fontSize: 8)),
          pw.Text(_metodoPagoLabel(metodo), style: const pw.TextStyle(fontSize: 8)),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Tiempo est.:', style: const pw.TextStyle(fontSize: 8)),
          pw.Text('$tiempoMin-$tiempoMax min', style: const pw.TextStyle(fontSize: 8)),
        ]),
        pw.SizedBox(height: 10),
        pw.Text('Gracias por tu compra!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text('Tu apoyo impulsa los negocios locales', style: const pw.TextStyle(fontSize: 7)),
        pw.Text('de Tulancingo', style: const pw.TextStyle(fontSize: 7)),
      ]),
    ));

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'ticket_$numero.pdf');
  }
}
