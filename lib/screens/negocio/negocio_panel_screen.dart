import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../services/role_service.dart';
import 'negocio_pedidos_tab.dart';
import 'negocio_catalogo_tab.dart';
import 'negocio_ventas_tab.dart';
import 'negocio_pagina_tab.dart';
import 'negocio_config_tab.dart';

class NegocioPanelScreen extends StatefulWidget {
  final UserSession session;
  const NegocioPanelScreen({super.key, required this.session});
  @override State<NegocioPanelScreen> createState() => _NegocioPanelState();
}

class _NegocioPanelState extends State<NegocioPanelScreen> {
  int _tab = 0;

  Widget _buildTab() => switch (_tab) {
    0 => NegocioPedidosTab(negocioId: widget.session.negocioId!),
    1 => NegocioCatalogoTab(negocioId: widget.session.negocioId!),
    2 => NegocioVentasTab(negocioId: widget.session.negocioId!),
    3 => NegocioPaginaTab(negocioId: widget.session.negocioId!),
    4 => NegocioConfigTab(session: widget.session, onLogout: _logout),
    _ => NegocioPedidosTab(negocioId: widget.session.negocioId!),
  };

  void _logout() async {
    await RoleService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildTab()),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color: AppTheme.cd,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.or.withOpacity(0.3), width: 0.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -4)),
            BoxShadow(color: AppTheme.or.withOpacity(0.08), blurRadius: 30, spreadRadius: -5),
          ],
        ),
        child: Row(children: [
          _navBtn(0, Icons.receipt_long, 'Pedidos'),
          _navBtn(1, Icons.inventory_2, 'Catálogo'),
          _navBtn(2, Icons.bar_chart, 'Ventas'),
          _navBtn(3, Icons.storefront, 'Mi Página'),
          _navBtn(4, Icons.settings, 'Config'),
        ]),
      ),
    );
  }

  Widget _navBtn(int i, IconData ic, String l) {
    final bool active = _tab == i;
    return Expanded(child: InkWell(
      onTap: () => setState(() => _tab = i),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? AppTheme.or.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
          child: Icon(ic, size: 22, color: active ? AppTheme.or : AppTheme.td)),
        const SizedBox(height: 3),
        Text(l, style: TextStyle(fontSize: 9, color: active ? AppTheme.or : AppTheme.td, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ]))));
  }
}
