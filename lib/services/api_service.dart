import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ═══ BASE URLs ═══
  // Puerto 5001 = Cargo-GO API (negocios, farmacia, envios, marketplace)
  // Puerto 5000 = Repartidores API (entregas, drivers, tracking)
  static String _baseUrl = 'http://192.168.0.103:5001';
  static String _repartidoresUrl = 'http://192.168.0.103:5000';

  static String get baseUrl => _baseUrl;
  static set baseUrl(String url) => _baseUrl = url.replaceAll(RegExp(r'/$'), '');

  static String get repartidoresUrl => _repartidoresUrl;
  static set repartidoresUrl(String url) => _repartidoresUrl = url.replaceAll(RegExp(r'/$'), '');

  // ═══ HTTP HELPERS ═══
  static Future<Map<String, dynamic>?> _get(String endpoint, {bool useRepartidores = false}) async {
    try {
      final base = useRepartidores ? _repartidoresUrl : _baseUrl;
      final uri = Uri.parse('$base$endpoint');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) return {'data': decoded};
        return decoded as Map<String, dynamic>;
      }
      return {'error': 'HTTP ${response.statusCode}', 'body': response.body};
    } catch (e) {
      debugPrint('[API] GET $endpoint error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _post(String endpoint, Map<String, dynamic> body, {bool useRepartidores = false}) async {
    try {
      final base = useRepartidores ? _repartidoresUrl : _baseUrl;
      final uri = Uri.parse('$base$endpoint');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));
      final decoded = json.decode(response.body);
      if (decoded is List) return {'data': decoded};
      return decoded as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[API] POST $endpoint error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _put(String endpoint, Map<String, dynamic> body, {bool useRepartidores = false}) async {
    try {
      final base = useRepartidores ? _repartidoresUrl : _baseUrl;
      final uri = Uri.parse('$base$endpoint');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[API] PUT $endpoint error: $e');
      return null;
    }
  }

  // ═══ AUTH ═══
  static Future<Map<String, dynamic>?> login(String usuario, String password) =>
      _post('/api/login', {'usuario': usuario, 'password': password});

  // ═══ STATS (Cargo-GO) ═══
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

  static Future<Map<String, dynamic>?> registrarNegocio(Map<String, dynamic> data) =>
      _post('/api/negocios/registro', data);

  // ═══ ENVÍOS ═══
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

  // ═══ ZONAS ═══
  static Future<List<Map<String, dynamic>>> getZonas() async {
    final res = await _get('/api/zonas');
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> detectarZona(String cp) =>
      _get('/api/detectar-zona/$cp');

  // ═══ REPARTIDORES API (Port 5000) ═══
  static Future<List<Map<String, dynamic>>> getEntregas({String? estado, String? repartidorId}) async {
    String query = '/api/entregas';
    final params = <String>[];
    if (estado != null && estado.isNotEmpty) params.add('estado=$estado');
    if (repartidorId != null) params.add('repartidor_id=$repartidorId');
    if (params.isNotEmpty) query += '?${params.join('&')}';
    final res = await _get(query, useRepartidores: true);
    if (res != null && res.containsKey('data')) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    if (res != null && !res.containsKey('error')) {
      // Some APIs return list directly
      if (res.containsKey('entregas')) return List<Map<String, dynamic>>.from(res['entregas']);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getEntrega(int id) =>
      _get('/api/entregas/$id', useRepartidores: true);

  static Future<Map<String, dynamic>?> iniciarEntrega(int id) =>
      _post('/api/entregas/$id/iniciar', {}, useRepartidores: true);

  static Future<Map<String, dynamic>?> completarEntrega(int id) =>
      _post('/api/entregas/$id/completar', {}, useRepartidores: true);

  static Future<Map<String, dynamic>?> getRepartidor(int id) =>
      _get('/api/repartidor/$id', useRepartidores: true);

  static Future<Map<String, dynamic>?> getRepartidorStats(int repartidorId) =>
      _get('/api/stats/$repartidorId', useRepartidores: true);

  static Future<List<Map<String, dynamic>>> getRepartidores() async {
    final res = await _get('/api/repartidores');
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

  // ═══ HEALTH CHECKS ═══
  static Future<bool> isOnline() async {
    try {
      final res = await _get('/api/stats');
      return res != null && !res.containsKey('error');
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isRepartidoresOnline() async {
    try {
      final res = await _get('/api/entregas', useRepartidores: true);
      return res != null && !res.containsKey('error');
    } catch (_) {
      return false;
    }
  }

  // ═══ FULL HEALTH CHECK (both APIs) ═══
  static Future<Map<String, bool>> checkAllServices() async {
    final results = await Future.wait([
      isOnline(),
      isRepartidoresOnline(),
    ]);
    return {
      'cargo_go': results[0],
      'repartidores': results[1],
    };
  }
}
