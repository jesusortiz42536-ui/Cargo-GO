import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  static const String _phone = '527753200224';

  /// Abre WhatsApp con un mensaje pre-formateado
  static Future<bool> openChat({String message = ''}) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$_phone?text=$encoded');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      // Fallback: intentar sin verificar
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      debugPrint('[WhatsApp] Error abriendo chat: $e');
      return false;
    }
  }

  /// Mensaje para cotizar mudanza
  static Future<bool> cotizarMudanza({
    required String tipo,
    String origen = '',
    String destino = '',
  }) {
    final msg = 'Hola Cargo-GO! Me interesa cotizar una *$tipo*.\n'
        '${origen.isNotEmpty ? "Origen: $origen\n" : ""}'
        '${destino.isNotEmpty ? "Destino: $destino\n" : ""}'
        'Me pueden dar informacion por favor?';
    return openChat(message: msg);
  }

  /// Mensaje de soporte con folio de pedido
  static Future<bool> contactarSoporte({String folio = ''}) {
    final msg = folio.isNotEmpty
        ? 'Hola Cargo-GO! Necesito ayuda con mi pedido *$folio*.'
        : 'Hola Cargo-GO! Necesito ayuda con un pedido.';
    return openChat(message: msg);
  }

  /// Mensaje general de contacto
  static Future<bool> contactoGeneral() {
    return openChat(
      message: 'Hola Cargo-GO! Quisiera informacion sobre sus servicios.',
    );
  }
}
