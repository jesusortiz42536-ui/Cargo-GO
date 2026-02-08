import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// MercadoPago Checkout Pro - Sandbox Integration
/// Crea preferencias de pago y redirige al checkout de MercadoPago.
class MercadoPagoService {
  // ═══ CREDENCIALES SANDBOX ═══
  static const publicKey = 'APP_USR-c4f9d601-6760-4abf-bad4-1e0d8b928f91';
  static const _accessToken = 'APP_USR-2567177952927542-020722-4f0c4729c8db104679498a23308e4ebb-428476282';
  static const _apiBase = 'https://api.mercadopago.com';
  static const _backUrl = 'https://cargo-go-b5f77.web.app';

  /// Crea una preferencia de pago y abre el checkout de MercadoPago.
  /// Retorna true si se abrió exitosamente, false si hubo error.
  static Future<bool> checkout({
    required String title,
    required String description,
    required double amount,
    int quantity = 1,
    String? externalReference,
    String? payerEmail,
  }) async {
    try {
      final body = {
        'items': [
          {
            'title': title,
            'description': description,
            'quantity': quantity,
            'unit_price': amount,
            'currency_id': 'MXN',
          }
        ],
        'back_urls': {
          'success': '$_backUrl?pago=ok',
          'failure': '$_backUrl?pago=error',
          'pending': '$_backUrl?pago=pendiente',
        },
        'auto_return': 'approved',
        'payment_methods': {
          'excluded_payment_types': [],
          'installments': 12,
        },
        if (externalReference != null) 'external_reference': externalReference,
        if (payerEmail != null)
          'payer': {'email': payerEmail},
      };

      final response = await http.post(
        Uri.parse('$_apiBase/checkout/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        // Sandbox usa sandbox_init_point, producción usa init_point
        final checkoutUrl = data['sandbox_init_point'] ?? data['init_point'];
        if (checkoutUrl != null) {
          final uri = Uri.parse(checkoutUrl);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      debugPrint('[MercadoPago] Error ${response.statusCode}: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('[MercadoPago] Exception: $e');
      return false;
    }
  }

  /// Pago de pedido (delivery, mandado, mudanza, paquetería)
  static Future<bool> pagarPedido({
    required String folio,
    required String tipo,
    required double total,
    String? descripcion,
  }) => checkout(
    title: 'Pedido Cargo-GO $folio',
    description: descripcion ?? 'Servicio de $tipo',
    amount: total,
    externalReference: folio,
  );

  /// Suscripción mensual de negocio ($500 MXN)
  static Future<bool> pagarSuscripcion({
    required String nombreNegocio,
    double monto = 500.0,
  }) => checkout(
    title: 'Suscripción Cargo-GO Marketplace',
    description: 'Plan mensual para $nombreNegocio',
    amount: monto,
    externalReference: 'SUB-${DateTime.now().millisecondsSinceEpoch}',
  );

  /// Pago de carrito (farmacia / marketplace)
  static Future<bool> pagarCarrito({
    required double subtotal,
    required double envio,
    required int items,
    String? folio,
  }) => checkout(
    title: 'Pedido Cargo-GO${folio != null ? ' $folio' : ''}',
    description: '$items productos + envío a domicilio',
    amount: subtotal + envio,
    externalReference: folio ?? 'CART-${DateTime.now().millisecondsSinceEpoch}',
  );
}
