import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class NegocioConfigTab extends StatefulWidget {
  final UserSession session;
  final VoidCallback onLogout;
  const NegocioConfigTab({super.key, required this.session, required this.onLogout});
  @override State<NegocioConfigTab> createState() => _NegocioConfigTabState();
}

class _NegocioConfigTabState extends State<NegocioConfigTab> {
  bool _activo = true;
  bool _aceptaEfectivo = true;
  String _plan = 'gratis';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final negocios = await FirestoreService.getNegocios();
    final n = negocios.firstWhere((x) => x['id'] == widget.session.negocioId, orElse: () => <String, dynamic>{});
    if (!mounted) return;
    setState(() {
      _activo = n['activo'] ?? true;
      _aceptaEfectivo = n['configuracion']?['aceptar_efectivo'] ?? true;
      _plan = n['plan'] ?? 'gratis';
      _loading = false;
    });
  }

  void _toggleActivo(bool val) async {
    setState(() => _activo = val);
    await FirestoreService.updateNegocio(widget.session.negocioId!, {'activo': val});
  }

  void _toggleEfectivo(bool val) async {
    setState(() => _aceptaEfectivo = val);
    await FirestoreService.updateNegocio(widget.session.negocioId!, {
      'configuracion.aceptar_efectivo': val,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.or));

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Header
      Row(children: [
        const Text('⚙️', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Configuración', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          Text(widget.session.negocioNombre ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        ]),
      ]),
      const SizedBox(height: 24),
      // Prender/Apagar negocio
      _configCard(
        icon: Icons.power_settings_new,
        title: 'Negocio ${_activo ? 'ABIERTO' : 'CERRADO'}',
        subtitle: _activo ? 'Estás recibiendo pedidos' : 'No recibirás pedidos',
        color: _activo ? AppTheme.gr : AppTheme.rd,
        trailing: Switch(value: _activo, onChanged: _toggleActivo,
          activeColor: AppTheme.gr, inactiveTrackColor: AppTheme.rd.withOpacity(0.3)),
      ),
      const SizedBox(height: 10),
      // Plan actual
      _configCard(
        icon: Icons.diamond,
        title: 'Plan: ${_plan.toUpperCase()}',
        subtitle: _planDesc(_plan),
        color: AppTheme.yl,
        trailing: const Icon(Icons.chevron_right, color: AppTheme.tm),
      ),
      const SizedBox(height: 10),
      // Aceptar efectivo
      _configCard(
        icon: Icons.attach_money,
        title: 'Aceptar Efectivo',
        subtitle: _aceptaEfectivo ? 'Los clientes pueden pagar en efectivo' : 'Solo pagos digitales',
        color: AppTheme.gr,
        trailing: Switch(value: _aceptaEfectivo, onChanged: _toggleEfectivo,
          activeColor: AppTheme.gr),
      ),
      const SizedBox(height: 10),
      // Cambiar contraseña
      _configCard(
        icon: Icons.lock,
        title: 'Cambiar Contraseña',
        subtitle: 'Actualiza tu contraseña de acceso',
        color: AppTheme.ac,
        trailing: const Icon(Icons.chevron_right, color: AppTheme.tm),
        onTap: _showChangePassword,
      ),
      const SizedBox(height: 30),
      // Info
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📋 Info de tu cuenta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          _infoRow('ID Negocio', widget.session.negocioId ?? ''),
          _infoRow('Contacto', widget.session.nombre ?? ''),
          _infoRow('Teléfono', widget.session.telefono ?? ''),
          _infoRow('Plan', _plan.toUpperCase()),
        ])),
      const SizedBox(height: 20),
      // Logout
      SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
        onPressed: widget.onLogout,
        icon: const Icon(Icons.logout, size: 18, color: AppTheme.rd),
        label: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.rd, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.rd),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      )),
      const SizedBox(height: 20),
    ]);
  }

  Widget _configCard({required IconData icon, required String title, required String subtitle,
    required Color color, Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          color: color.withOpacity(0.05)),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: color.withOpacity(0.15)),
            child: Icon(icon, size: 20, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
          ])),
          if (trailing != null) trailing,
        ])));
  }

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.tx),
        textAlign: TextAlign.right)),
    ]));

  String _planDesc(String plan) => switch (plan) {
    'gratis' => 'Hasta 20 pedidos/mes',
    'basico' => 'Hasta 100 pedidos/mes',
    'pro' => 'Pedidos ilimitados + stats',
    'ilimitado' => 'Todo incluido + prioridad',
    'vip' => 'Plan VIP especial',
    _ => 'Plan activo',
  };

  void _showChangePassword() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.sf,
      title: const Text('Cambiar Contraseña', style: TextStyle(color: AppTheme.tx, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: oldPass, obscureText: true,
          style: const TextStyle(color: AppTheme.tx, fontSize: 13),
          decoration: InputDecoration(labelText: 'Contraseña actual', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
            filled: true, fillColor: AppTheme.cd,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height: 10),
        TextField(controller: newPass, obscureText: true,
          style: const TextStyle(color: AppTheme.tx, fontSize: 13),
          decoration: InputDecoration(labelText: 'Nueva contraseña', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
            filled: true, fillColor: AppTheme.cd,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Contraseña actualizada', style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.gr));
        }, child: const Text('Guardar', style: TextStyle(color: AppTheme.or))),
      ]));
  }
}
