import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.sf,
        title: const Text('🔒 Aviso de Privacidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Header
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [AppTheme.gr.withOpacity(0.1), Colors.transparent]),
            border: Border.all(color: AppTheme.gr.withOpacity(0.3))),
          child: Column(children: [
            const Text('🔒', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            const Text('AVISO DE PRIVACIDAD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.tx)),
            const SizedBox(height: 4),
            Text('Última actualización: 17 Feb 2026', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
          ])),
        const SizedBox(height: 20),

        // Responsable
        _section('📋 Responsable',
          'Cargo-GO, operado por Farmacias Madrid, con domicilio en '
          'Av. 21 de Marzo, Col. Centro, Tulancingo, Hidalgo, México.'),

        // Datos que recopilamos
        _section('📱 Datos que recopilamos', ''),
        _dataRow('👤 Nombre', 'Para identificar tu pedido', true),
        _dataRow('📱 Teléfono', 'Para contactarte sobre tu pedido', true),
        _dataRow('📍 Dirección', 'Temporal, solo durante la entrega', true),
        _dataRow('📍 GPS', 'Solo durante entrega activa', true),
        _dataRow('📧 Correo', 'Opcional, solo si quieres ticket por email', false),
        const SizedBox(height: 16),

        // Datos que NO recopilamos
        _section('🚫 Datos que NO recopilamos', ''),
        _noDataRow('💳 Datos bancarios', 'Los maneja Mercado Pago directamente'),
        _noDataRow('📍 Historial de ubicaciones', 'No rastreamos tu posición'),
        _noDataRow('📞 Contactos', 'No accedemos a tu agenda'),
        _noDataRow('🎤 Micrófono', 'No grabamos audio'),
        _noDataRow('📁 Archivos', 'No accedemos a tus archivos'),
        const SizedBox(height: 16),

        // Uso de datos
        _section('🎯 Para qué usamos tus datos',
          'Tus datos se usan ÚNICAMENTE para:\n'
          '• Procesar y entregar tus pedidos\n'
          '• Contactarte sobre el estado de tu pedido\n'
          '• Mejorar nuestro servicio\n\n'
          'NO vendemos, compartimos ni transferimos tus datos '
          'personales a terceros bajo ninguna circunstancia.'),

        // Pagos
        _section('💳 Seguridad en pagos',
          'Los pagos con tarjeta son procesados por Mercado Pago, '
          'una plataforma certificada PCI DSS. Cargo-GO NUNCA recibe, '
          'almacena ni procesa datos de tarjetas de crédito o débito.\n\n'
          'Solo guardamos: referencia de transacción, monto, fecha y status.'),

        // Retención
        _section('⏱️ Retención de datos',
          '• Dirección de entrega: se mantiene para "repetir pedido", '
          'puedes solicitar su eliminación.\n'
          '• GPS: solo durante entrega activa, se elimina al completar.\n'
          '• Historial de pedidos: se mantiene para tu consulta.\n'
          '• Teléfono: se mantiene como identificador.'),

        // Derechos ARCO
        _section('⚖️ Tus derechos (ARCO)',
          'Tienes derecho a Acceder, Rectificar, Cancelar u Oponerte '
          'al tratamiento de tus datos personales. Para ejercer estos '
          'derechos, contáctanos:'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent('Hola, quiero ejercer mis derechos de privacidad (ARCO) en Cargo-GO')}'), mode: LaunchMode.externalApplication),
          child: Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFF25D366).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3))),
            child: const Row(children: [
              Text('💬', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('WhatsApp: 771-XXX-XXXX', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF25D366))),
                Text('Escríbenos para cualquier solicitud de privacidad', style: TextStyle(fontSize: 9, color: AppTheme.tm)),
              ])),
            ]))),
        const SizedBox(height: 16),

        // Seguridad
        _section('🔐 Medidas de seguridad',
          '• Todas las comunicaciones van cifradas (HTTPS/TLS)\n'
          '• Contraseñas almacenadas con hash criptográfico\n'
          '• Acceso restringido a bases de datos\n'
          '• Monitoreo continuo de actividad sospechosa\n'
          '• Autenticación de dos factores para administradores'),

        // Ley
        _section('📜 Marco legal',
          'Este aviso se emite en cumplimiento de la Ley Federal de '
          'Protección de Datos Personales en Posesión de los Particulares '
          '(LFPDPPP) y su Reglamento, vigentes en México.'),

        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppTheme.cd,
            border: Border.all(color: AppTheme.bd)),
          child: Column(children: [
            const Text('🇲🇽 Cargo-GO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            const SizedBox(height: 4),
            Text('Conectamos CDMX con toda la República Mexicana', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
            const SizedBox(height: 4),
            Text('Tu privacidad es nuestra prioridad', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.gr)),
          ])),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _section(String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
      if (body.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(body, style: TextStyle(fontSize: 11, color: AppTheme.tm, height: 1.5)),
      ],
    ]));

  Widget _dataRow(String icon, String desc, bool required_) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 8),
      Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.tx))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
          color: required_ ? AppTheme.or.withOpacity(0.15) : AppTheme.ac.withOpacity(0.15)),
        child: Text(required_ ? 'Requerido' : 'Opcional',
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
            color: required_ ? AppTheme.or : AppTheme.ac))),
    ]));

  Widget _noDataRow(String icon, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 8),
      Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.tm))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppTheme.rd.withOpacity(0.15)),
        child: const Text('NO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppTheme.rd))),
    ]));
}
