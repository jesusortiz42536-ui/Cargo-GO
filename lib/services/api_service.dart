import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// HTTP client sin dependencias externas - usa dart:io en mobile
import 'dart:io';

class ApiService {
  // En emulador Android, 10.0.2.2 apunta al localhost de la PC host
  static String _baseUrl = 'http://192.168.0.103:5000';

  static String get baseUrl => _baseUrl;
  static set baseUrl(String url) => _baseUrl = url.replaceAll(RegExp(r'/$'), '');

  static final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);

  // ═══ HTTP HELPER ═══
  static Future<Map<String, dynamic>?> _get(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = await _client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        final decoded = json.decode(body);
        if (decoded is List) return {'data': decoded};
        return decoded as Map<String, dynamic>;
      }
      return {'error': 'HTTP ${response.statusCode}', 'body': body};
    } catch (e) {
      debugPrint('[API] GET $endpoint error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(json.encode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = json.decode(responseBody);
      if (decoded is List) return {'data': decoded};
      return decoded as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[API] POST $endpoint error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _put(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = await _client.openUrl('PUT', uri);
      request.headers.contentType = ContentType.json;
      request.write(json.encode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      return json.decode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[API] PUT $endpoint error: $e');
      return null;
    }
  }

  // ═══ AUTH ═══
  static Future<Map<String, dynamic>?> login(String usuario, String password) =>
      _post('/api/login', {'usuario': usuario, 'password': password});

  // ═══ STATS ═══
  static Future<Map<String, dynamic>?> getStats() => _get('/api/stats');

  // ═══ NEGOCIOS (MARKETPLACE) ═══
  static Future<List<Map<String, dynamic>>> getNegocios() async {
    final res = await _get('/api/negocios');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getNegocio(int id) => _get('/api/negocios/$id');

  static Future<List<Map<String, dynamic>>> getProductosNegocio(int negocioId) async {
    final res = await _get('/api/negocios/$negocioId/productos');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  // ═══ ENVIOS ═══
  static Future<Map<String, dynamic>?> cotizar(String cp, double peso) =>
      _post('/api/cotizar', {'cp': cp, 'peso': peso});

  static Future<Map<String, dynamic>?> crearEnvio(Map<String, dynamic> data) =>
      _post('/api/envios', data);

  static Future<Map<String, dynamic>?> rastrear(String folio) => _get('/api/rastrear/$folio');

  static Future<List<Map<String, dynamic>>> getHistorial() async {
    final res = await _get('/api/historial');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  // ═══ FARMACIA ═══
  static Future<List<Map<String, dynamic>>> getFarmaciaProductos({
    String categoria = '',
    String busqueda = '',
    int limite = 50,
    int offset = 0,
  }) async {
    String query = '/api/farmacia/productos?limite=$limite&offset=$offset';
    if (categoria.isNotEmpty) query += '&categoria=$categoria';
    if (busqueda.isNotEmpty) query += '&q=${Uri.encodeComponent(busqueda)}';
    final res = await _get(query);
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> buscarFarmacia(String q) async {
    if (q.length < 2) return [];
    final res = await _get('/api/farmacia/buscar?q=${Uri.encodeComponent(q)}');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getCategorias() async {
    final res = await _get('/api/farmacia/categorias');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getOfertas() async {
    final res = await _get('/api/farmacia/ofertas');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> crearPedidoFarmacia({
    required String clienteNombre,
    required String clienteTelefono,
    required String clienteDireccion,
    required String clienteCp,
    required double subtotal,
    required double costoEnvio,
    required double total,
    required List<Map<String, dynamic>> items,
  }) => _post('/api/farmacia/pedido', {
    'cliente_nombre': clienteNombre,
    'cliente_telefono': clienteTelefono,
    'cliente_direccion': clienteDireccion,
    'cliente_cp': clienteCp,
    'subtotal': subtotal,
    'costo_envio': costoEnvio,
    'total': total,
    'items': items,
  });

  static Future<List<Map<String, dynamic>>> getPedidos({String estado = ''}) async {
    String query = '/api/farmacia/pedidos';
    if (estado.isNotEmpty) query += '?estado=$estado';
    final res = await _get(query);
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getPedidoDetalle(int id) =>
      _get('/api/farmacia/pedidos/$id');

  static Future<Map<String, dynamic>?> actualizarEstadoPedido(int id, String estado) =>
      _put('/api/farmacia/pedidos/$id/estado', {'estado': estado});

  static Future<Map<String, dynamic>?> getPedidosStats() =>
      _get('/api/farmacia/pedidos/stats');

  // ═══ ZONAS ═══
  static Future<List<Map<String, dynamic>>> getZonas() async {
    final res = await _get('/api/zonas');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  // ═══ HEALTH CHECK ═══
  static Future<bool> isOnline() async {
    try {
      final res = await _get('/api/stats');
      return res != null && !res.containsKey('error');
    } catch (_) {
      return false;
    }
  }
}
