import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';

class AuthService {
  static FirebaseAuth? _auth;
  static bool _initialized = false;
  static String? _verificationId;
  static int? _resendToken;
  // Web phone auth stores ConfirmationResult instead of verificationId
  static ConfirmationResult? _webConfirmationResult;

  /// Inicializa Firebase. Retorna true si se inicializo correctamente.
  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _auth = FirebaseAuth.instance;
      _initialized = true;
      debugPrint('[AuthService] Firebase inicializado correctamente');
      return true;
    } catch (e) {
      debugPrint('[AuthService] Firebase no disponible: $e');
      _initialized = false;
      return false;
    }
  }

  static bool get isAvailable => _initialized && _auth != null;
  static User? get currentUser => _auth?.currentUser;
  static bool get isLoggedIn => _auth?.currentUser != null;

  /// Envia codigo SMS al numero de telefono (10 digitos, se agrega +52).
  /// En web usa signInWithPhoneNumber (reCAPTCHA invisible automatico).
  /// En mobile usa verifyPhoneNumber con callbacks.
  /// Retorna null si exitoso, o un mensaje de error.
  static Future<String?> sendCode(
    String phone, {
    Function(String verificationId)? onCodeSent,
    Function(String error)? onError,
  }) async {
    if (!isAvailable) {
      return 'Firebase no esta configurado. Descarga google-services.json de Firebase Console.';
    }

    final fullPhone = '+52${phone.replaceAll(RegExp(r'\D'), '')}';

    try {
      if (kIsWeb) {
        // Web: signInWithPhoneNumber maneja reCAPTCHA automaticamente
        _webConfirmationResult = await _auth!.signInWithPhoneNumber(fullPhone);
        debugPrint('[AuthService] Codigo enviado (web) a $fullPhone');
        onCodeSent?.call('web');
        return null;
      }

      // Mobile: usar verifyPhoneNumber con callbacks
      await _auth!.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth!.signInWithCredential(credential);
            debugPrint('[AuthService] Auto-verificacion exitosa');
          } catch (e) {
            debugPrint('[AuthService] Error auto-verificacion: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String msg;
          switch (e.code) {
            case 'invalid-phone-number':
              msg = 'Numero de telefono invalido';
              break;
            case 'too-many-requests':
              msg = 'Demasiados intentos. Intenta mas tarde';
              break;
            case 'quota-exceeded':
              msg = 'Limite de SMS excedido. Intenta mas tarde';
              break;
            default:
              msg = 'Error al enviar codigo: ${e.message}';
          }
          debugPrint('[AuthService] Verificacion fallida: ${e.code} - ${e.message}');
          onError?.call(msg);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          debugPrint('[AuthService] Codigo enviado a $fullPhone');
          onCodeSent?.call(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return null;
    } catch (e) {
      debugPrint('[AuthService] Error sendCode: $e');
      return 'Error al enviar SMS: $e';
    }
  }

  /// Verifica el codigo SMS ingresado por el usuario.
  /// En web usa ConfirmationResult.confirm().
  /// En mobile usa PhoneAuthProvider.credential().
  /// Retorna null si exitoso, o un mensaje de error.
  static Future<String?> verifyCode(String smsCode) async {
    if (!isAvailable) {
      return 'Firebase no esta configurado';
    }

    try {
      if (kIsWeb) {
        // Web: usar ConfirmationResult guardado
        if (_webConfirmationResult == null) {
          return 'No se ha enviado un codigo. Solicita uno primero.';
        }
        await _webConfirmationResult!.confirm(smsCode);
        _webConfirmationResult = null;
        debugPrint('[AuthService] Verificacion exitosa (web)');
        return null;
      }

      // Mobile: usar verificationId + credential
      if (_verificationId == null) {
        return 'No se ha enviado un codigo. Solicita uno primero.';
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _auth!.signInWithCredential(credential);
      debugPrint('[AuthService] Verificacion exitosa');
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          return 'Codigo incorrecto. Verifica e intenta de nuevo.';
        case 'session-expired':
          return 'El codigo ha expirado. Solicita uno nuevo.';
        default:
          return 'Error de verificacion: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  /// Inicia sesion con Google.
  /// En web usa signInWithPopup (no necesita clientId).
  /// En mobile usa el paquete google_sign_in.
  static Future<String?> signInWithGoogle() async {
    if (!isAvailable) {
      return 'Firebase no esta configurado';
    }

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await _auth!.signInWithPopup(provider);
        debugPrint('[AuthService] Google Sign-In (web) exitoso');
        return null;
      }

      // Mobile: usar paquete google_sign_in
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return 'Inicio de sesion cancelado';
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth!.signInWithCredential(credential);
      debugPrint('[AuthService] Google Sign-In exitoso: ${googleUser.email}');
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Error de autenticacion: ${e.message}';
    } catch (e) {
      debugPrint('[AuthService] Error Google Sign-In: $e');
      return 'Error al iniciar con Google: $e';
    }
  }

  /// Cierra sesion (Firebase + Google)
  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        // Solo en mobile: GoogleSignIn().signOut() requiere el paquete nativo
        try {
          await GoogleSignIn().signOut();
        } catch (_) {}
      }
      await _auth?.signOut();
      _verificationId = null;
      _resendToken = null;
      _webConfirmationResult = null;
    } catch (e) {
      debugPrint('[AuthService] Error signOut: $e');
    }
  }
}
