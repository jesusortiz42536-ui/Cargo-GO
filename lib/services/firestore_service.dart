import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static const _col = 'negocios';

  /// Lee todos los negocios (opcionalmente filtrados por ciudad).
  static Future<List<Map<String, dynamic>>> getNegocios({String? ciudad}) async {
    try {
      Query<Map<String, dynamic>> q = _db.collection(_col);
      if (ciudad != null && ciudad != 'all') {
        q = q.where('ciudad', isEqualTo: ciudad);
      }
      final snap = await q.get();
      final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      list.sort((a, b) => (a['nombre'] ?? '').toString().compareTo((b['nombre'] ?? '').toString()));
      return list;
    } catch (e) {
      debugPrint('[FirestoreService] getNegocios error: $e');
      return [];
    }
  }

  /// Sube foto de negocio a Storage y actualiza foto_url en Firestore.
  static Future<String> uploadNegocioPhoto(String negocioId, Uint8List bytes) async {
    final ref = _storage.ref('negocios/$negocioId/foto.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _db.collection(_col).doc(negocioId).update({'foto_url': url});
    return url;
  }

  /// Actualiza campos arbitrarios de un negocio.
  static Future<void> updateNegocio(String id, Map<String, dynamic> data) async {
    await _db.collection(_col).doc(id).update(data);
  }

  /// Access to the Firestore instance.
  static FirebaseFirestore get db => _db;

  /// Agrega un documento a una colección arbitraria.
  static Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  /// Agrega documento y retorna referencia (para obtener ID).
  static Future<String> addDocumentWithId(String collection, Map<String, dynamic> data) async {
    final doc = await _db.collection(collection).add(data);
    return doc.id;
  }

  /// Genera número de pedido secuencial: CG-YYYYMMDD-XXX
  static Future<String> generarNumeroPedido() async {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final counterRef = _db.collection('counters').doc('pedidos');
    try {
      final result = await _db.runTransaction((tx) async {
        final snap = await tx.get(counterRef);
        final data = snap.data() ?? {};
        final lastDate = data['date'] as String? ?? '';
        int count = 1;
        if (lastDate == dateStr) {
          count = ((data['count'] as int?) ?? 0) + 1;
        }
        tx.set(counterRef, {'date': dateStr, 'count': count});
        return count;
      });
      return 'CG-$dateStr-${result.toString().padLeft(3, '0')}';
    } catch (e) {
      // Fallback: use timestamp
      debugPrint('[FirestoreService] generarNumeroPedido error: $e');
      return 'CG-$dateStr-${(now.millisecond + now.second * 1000).toString().padLeft(3, '0')}';
    }
  }

  /// Guarda pedido completo y retorna el ID del documento.
  static Future<String> guardarPedido(Map<String, dynamic> data) async {
    final ref = await _db.collection('pedidos').add(data);
    return ref.id;
  }

  /// Actualiza estado de un pedido.
  static Future<void> actualizarEstadoPedido(String docId, String estado) async {
    await _db.collection('pedidos').doc(docId).update({'estado': estado});
  }

  /// Lee pedidos del usuario (por teléfono).
  static Future<List<Map<String, dynamic>>> getPedidosPorTelefono(String tel) async {
    try {
      final snap = await _db.collection('pedidos')
        .where('cliente_telefono', isEqualTo: tel)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
      return snap.docs.map((d) => {'doc_id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('[FirestoreService] getPedidos error: $e');
      return [];
    }
  }

  // ═══ FARMACIA PRODUCTOS ═══

  /// Lee productos de farmacia (opcionalmente filtrados por categoría).
  static Future<List<Map<String, dynamic>>> getFarmaciaProductos({String? categoria}) async {
    try {
      Query<Map<String, dynamic>> q = _db.collection('farmacia_productos');
      if (categoria != null && categoria.isNotEmpty) {
        q = q.where('categoria', isEqualTo: categoria);
      }
      final snap = await q.limit(100).get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('[FirestoreService] getFarmaciaProductos error: $e');
      return [];
    }
  }

  /// Busca productos de farmacia por nombre.
  static Future<List<Map<String, dynamic>>> buscarFarmaciaProductos(String query) async {
    try {
      final q = query.toLowerCase();
      final snap = await _db.collection('farmacia_productos').get();
      final results = snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .where((p) => (p['nombre'] ?? '').toString().toLowerCase().contains(q) ||
                      (p['principio_activo'] ?? '').toString().toLowerCase().contains(q))
        .toList();
      return results;
    } catch (e) {
      debugPrint('[FirestoreService] buscarFarmaciaProductos error: $e');
      return [];
    }
  }

  /// Stream reactivo de negocios.
  static Stream<List<Map<String, dynamic>>> negociosStream({String? ciudad}) {
    Query<Map<String, dynamic>> q = _db.collection(_col);
    if (ciudad != null && ciudad != 'all') {
      q = q.where('ciudad', isEqualTo: ciudad);
    }

    List<Map<String, dynamic>> mapSnap(QuerySnapshot<Map<String, dynamic>> snap) {
      final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      list.sort((a, b) => (a['nombre'] ?? '').toString().compareTo((b['nombre'] ?? '').toString()));
      return list;
    }

    return q.snapshots().map(mapSnap);
  }

  // ═══ NEGOCIO USUARIOS (Login de negocios) ═══

  /// Login de negocio: verifica teléfono + password_hash
  static Future<Map<String, dynamic>?> loginNegocio(String telefono, String passwordHash) async {
    try {
      final snap = await _db.collection('negocio_usuarios')
        .where('telefono', isEqualTo: telefono)
        .where('password_hash', isEqualTo: passwordHash)
        .where('activo', isEqualTo: true)
        .limit(1)
        .get();
      if (snap.docs.isEmpty) return null;
      return {'id': snap.docs.first.id, ...snap.docs.first.data()};
    } catch (e) {
      debugPrint('[FirestoreService] loginNegocio error: $e');
      return null;
    }
  }

  /// Registrar usuario de negocio
  static Future<void> registrarNegocioUsuario(Map<String, dynamic> data) async {
    await _db.collection('negocio_usuarios').add(data);
  }

  // ═══ PEDIDOS STREAMS (Tiempo real) ═══

  /// Stream de pedidos para un negocio específico
  static Stream<QuerySnapshot> pedidosNegocioStream(String negocioId) {
    return _db.collection('pedidos')
      .where('negocio_id', isEqualTo: negocioId)
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots();
  }

  /// Stream de TODOS los pedidos activos (para SUDO)
  static Stream<QuerySnapshot> todosLosPedidosStream() {
    return _db.collection('pedidos')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots();
  }

  /// Actualizar estado de pedido CON historial de timestamps
  static Future<void> actualizarEstadoPedidoConHistorial(
    String docId, String nuevoEstado, String por) async {
    await _db.collection('pedidos').doc(docId).update({
      'estado': nuevoEstado,
      'estado_historial': FieldValue.arrayUnion([{
        'estado': nuevoEstado,
        'timestamp': FieldValue.serverTimestamp(),
        'por': por,
      }]),
    });
  }

  // ═══ PRODUCTOS DE NEGOCIO (CRUD) ═══

  /// Leer productos de un negocio (subcollection)
  static Future<List<Map<String, dynamic>>> getProductosNegocio(String negocioId) async {
    try {
      final snap = await _db.collection('negocios').doc(negocioId)
        .collection('productos').get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('[FirestoreService] getProductosNegocio error: $e');
      return [];
    }
  }

  /// Guardar producto de negocio
  static Future<String> guardarProductoNegocio(String negocioId, Map<String, dynamic> data) async {
    final ref = await _db.collection('negocios').doc(negocioId)
      .collection('productos').add(data);
    return ref.id;
  }

  /// Eliminar producto de negocio
  static Future<void> eliminarProductoNegocio(String negocioId, String productoId) async {
    await _db.collection('negocios').doc(negocioId)
      .collection('productos').doc(productoId).delete();
  }

  /// Toggle disponibilidad de producto
  static Future<void> toggleProductoDisponible(String negocioId, String productoId, bool disponible) async {
    await _db.collection('negocios').doc(negocioId)
      .collection('productos').doc(productoId).update({'disponible': disponible});
  }

  // ═══ VENTAS RESUMEN ═══

  /// Obtener resumen de ventas de un negocio por periodo
  static Future<Map<String, dynamic>> getVentasResumen(String negocioId, String periodo) async {
    try {
      final now = DateTime.now();
      DateTime desde;
      switch (periodo) {
        case 'hoy': desde = DateTime(now.year, now.month, now.day); break;
        case 'semana': desde = now.subtract(const Duration(days: 7)); break;
        case 'mes': desde = DateTime(now.year, now.month, 1); break;
        default: desde = DateTime(now.year, now.month, now.day);
      }
      final snap = await _db.collection('pedidos')
        .where('negocio_id', isEqualTo: negocioId)
        .where('estado', isEqualTo: 'entregado')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(desde))
        .get();

      int totalVentas = 0;
      final productCount = <String, int>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        totalVentas += (data['total'] as num? ?? 0).toInt();
        final items = data['items'] as List? ?? [];
        for (final it in items) {
          final nombre = it['nombre'] ?? '';
          productCount[nombre] = (productCount[nombre] ?? 0) + (it['cantidad'] as int? ?? 1);
        }
      }
      String productoTop = 'N/A';
      if (productCount.isNotEmpty) {
        productoTop = productCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }

      return {
        'total_ventas': totalVentas,
        'num_pedidos': snap.docs.length,
        'producto_top': productoTop,
      };
    } catch (e) {
      debugPrint('[FirestoreService] getVentasResumen error: $e');
      return {'total_ventas': 0, 'num_pedidos': 0, 'producto_top': 'N/A'};
    }
  }
}
