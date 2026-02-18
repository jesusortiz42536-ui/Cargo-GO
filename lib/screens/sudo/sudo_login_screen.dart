import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/role_service.dart';
import 'sudo_panel_screen.dart';

class SudoLoginScreen extends StatefulWidget {
  const SudoLoginScreen({super.key});
  @override State<SudoLoginScreen> createState() => _SudoLoginState();
}

class _SudoLoginState extends State<SudoLoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  // Credenciales sudo (mismo patrón que CLAUDE.md)
  static const _sudoCredentials = {
    'admin': 'admin123',
    'super': 'root123',
  };

  void _login() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (user.isEmpty || pass.isEmpty) {
      _showError('Ingresa usuario y contraseña');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // simular

    if (_sudoCredentials[user] == pass) {
      final session = await RoleService.loginSudo(nombre: user);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => SudoPanelScreen(session: session)));
    } else {
      if (mounted) _showError('Credenciales incorrectas');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: AppTheme.rd, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF060B18), Color(0xFF1A0A2E)])),
        child: SafeArea(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Back
            Align(alignment: Alignment.centerLeft, child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 14, color: AppTheme.tm),
              label: const Text('Volver', style: TextStyle(color: AppTheme.tm, fontSize: 11)))),
            const SizedBox(height: 16),
            // Icon
            Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AppTheme.pu.withOpacity(0.3), AppTheme.pu.withOpacity(0.05)]),
                border: Border.all(color: AppTheme.pu.withOpacity(0.5), width: 2)),
              child: const Icon(Icons.admin_panel_settings, size: 40, color: AppTheme.pu)),
            const SizedBox(height: 20),
            const Text('Administrador', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Acceso SUDO · Panel completo', style: TextStyle(fontSize: 12, color: AppTheme.pu.withOpacity(0.7))),
            const SizedBox(height: 30),
            // Usuario
            const Align(alignment: Alignment.centerLeft,
              child: Text('Usuario', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.pu))),
            const SizedBox(height: 8),
            TextField(controller: _userCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'admin', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 14),
                prefixIcon: const Icon(Icons.person, color: AppTheme.pu, size: 20),
                filled: true, fillColor: AppTheme.cd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.pu)),
              )),
            const SizedBox(height: 16),
            // Contraseña
            const Align(alignment: Alignment.centerLeft,
              child: Text('Contraseña', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.pu))),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl, obscureText: _obscure,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '••••••••', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 14),
                prefixIcon: const Icon(Icons.lock, color: AppTheme.pu, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.tm, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure)),
                filled: true, fillColor: AppTheme.cd,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.pu)),
              ),
              onSubmitted: (_) => _login()),
            const SizedBox(height: 24),
            // Login button
            SizedBox(width: double.infinity, height: 54, child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pu, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
              child: _loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Acceder al Panel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            )),
          ])))),
      ),
    );
  }

  @override
  void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}
