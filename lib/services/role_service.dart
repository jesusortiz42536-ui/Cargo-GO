import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class RoleService {
  static const _key = 'user_session';
  static UserSession? _session;

  static UserSession? get current => _session;
  static bool get isLoggedIn => _session != null;
  static bool get isNegocio => _session?.isNegocio ?? false;
  static bool get isSudo => _session?.isSudo ?? false;

  /// Cargar sesión guardada
  static Future<UserSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        _session = UserSession.fromJson(jsonDecode(json));
        return _session;
      } catch (_) {
        await prefs.remove(_key);
      }
    }
    return null;
  }

  /// Guardar sesión
  static Future<void> saveSession(UserSession session) async {
    _session = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  /// Login como negocio
  static Future<UserSession> loginNegocio({
    required String negocioId,
    required String negocioNombre,
    required String telefono,
    String? nombre,
  }) async {
    final session = UserSession(
      role: AppRole.negocio,
      negocioId: negocioId,
      negocioNombre: negocioNombre,
      telefono: telefono,
      nombre: nombre,
    );
    await saveSession(session);
    return session;
  }

  /// Login como sudo
  static Future<UserSession> loginSudo({String? nombre}) async {
    final session = UserSession(
      role: AppRole.sudo,
      nombre: nombre ?? 'Admin',
    );
    await saveSession(session);
    return session;
  }

  /// Entrar como cliente (sin login)
  static Future<UserSession> enterAsCliente() async {
    final session = UserSession.cliente();
    await saveSession(session);
    return session;
  }

  /// Logout
  static Future<void> logout() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
