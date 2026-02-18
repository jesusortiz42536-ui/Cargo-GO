import 'dart:convert';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';
import '../../services/role_service.dart';
import 'negocio_panel_screen.dart';
import 'negocio_onboarding_screen.dart';

class NegocioLoginScreen extends StatefulWidget {
  const NegocioLoginScreen({super.key});
  @override State<NegocioLoginScreen> createState() => _NegocioLoginState();
}

class _NegocioLoginState extends State<NegocioLoginScreen> {
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  String _hashPassword(String pass) =>
    sha256.convert(utf8.encode(pass)).toString();

  void _login() async {
    final tel = _telCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    final pass = _passCtrl.text.trim();
    if (tel.length < 10 || pass.isEmpty) {
      _showError('Ingresa teléfono (10 dígitos) y contraseña');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await FirestoreService.loginNegocio(tel, _hashPassword(pass));
      if (!mounted) return;
      if (result != null) {
        final session = await RoleService.loginNegocio(
          negocioId: result['negocio_id'],
          negocioNombre: result['nombre_contacto'] ?? 'Mi Negocio',
          telefono: tel,
          nombre: result['nombre_contacto'],
        );
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => NegocioPanelScreen(session: session)));
      } else {
        _showError('Teléfono o contraseña incorrectos');
      }
    } catch (e) {
      if (mounted) _showError('Error de conexión: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: AppTheme.rd,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF060B18), Color(0xFF0D0B20)])),
        child: SafeArea(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Back button
            Align(alignment: Alignment.centerLeft, child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 14, color: AppTheme.tm),
              label: const Text('Volver', style: TextStyle(color: AppTheme.tm, fontSize: 11)),
            )),
            const SizedBox(height: 16),
            // Icon
            Container(width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTheme.or.withOpacity(0.2), AppTheme.or.withOpacity(0.05)]),
                border: Border.all(color: AppTheme.or.withOpacity(0.4), width: 2)),
              child: const Icon(Icons.store, size: 40, color: AppTheme.or)),
            const SizedBox(height: 20),
            const Text('Panel de Negocio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Administra tu negocio en Cargo-GO', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
            const SizedBox(height: 30),
            // Teléfono
            const Align(alignment: Alignment.centerLeft,
              child: Text('Teléfono registrado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.or))),
            const SizedBox(height: 8),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.bd)),
                child: const Text('+52', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _telCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1),
                decoration: InputDecoration(
                  hintText: '10 dígitos', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 14),
                  filled: true, fillColor: AppTheme.cd,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.or)),
                ))),
            ]),
            const SizedBox(height: 16),
            // Contraseña
            const Align(alignment: Alignment.centerLeft,
              child: Text('Contraseña', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.or))),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '••••••••', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 14),
                filled: true, fillColor: AppTheme.cd,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.tm, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.or)),
              )),
            const SizedBox(height: 24),
            // Login button
            SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.or, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
              child: _loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Entrar a mi Panel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            )),
            const SizedBox(height: 16),
            // Registrar negocio
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NegocioOnboardingScreen())),
              child: RichText(text: TextSpan(children: [
                TextSpan(text: '¿Nuevo negocio? ', style: TextStyle(color: AppTheme.tm, fontSize: 12)),
                TextSpan(text: 'Regístrate aquí', style: TextStyle(color: AppTheme.or, fontSize: 12, fontWeight: FontWeight.w700)),
              ])),
            ),
          ]),
        ))),
      ),
    );
  }

  @override
  void dispose() {
    _telCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
