import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class NegocioCatalogoTab extends StatefulWidget {
  final String negocioId;
  const NegocioCatalogoTab({super.key, required this.negocioId});
  @override State<NegocioCatalogoTab> createState() => _NegocioCatalogoTabState();
}

class _NegocioCatalogoTabState extends State<NegocioCatalogoTab> {
  List<NegocioProducto> _productos = [];
  bool _loading = true;
  String _catFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() => _loading = true);
    final docs = await FirestoreService.getProductosNegocio(widget.negocioId);
    if (!mounted) return;
    setState(() {
      _productos = docs.map((d) => NegocioProducto.fromJson(d['id'] ?? '', d)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorias = <String>{'all', ..._productos.map((p) => p.categoria ?? 'Sin categoría')};
    final filtered = _catFilter == 'all' ? _productos
      : _productos.where((p) => (p.categoria ?? 'Sin categoría') == _catFilter).toList();

    return Column(children: [
      // Header
      Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(children: [
          const Text('📦', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Catálogo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            Text('${_productos.length} productos', style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
          ]),
          const Spacer(),
          GestureDetector(onTap: _showAddProduct,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.or.withOpacity(0.15), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.or.withOpacity(0.4))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add, size: 16, color: AppTheme.or),
                SizedBox(width: 4),
                Text('Agregar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.or)),
              ]))),
        ])),
      // Category filter
      if (categorias.length > 2)
        SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: categorias.map((c) => GestureDetector(
            onTap: () => setState(() => _catFilter = c),
            child: Container(margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                color: _catFilter == c ? AppTheme.or.withOpacity(0.15) : Colors.transparent,
                border: Border.all(color: _catFilter == c ? AppTheme.or : AppTheme.bd)),
              child: Text(c == 'all' ? 'Todos' : c,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _catFilter == c ? AppTheme.or : AppTheme.tm)))
          )).toList())),
      const SizedBox(height: 12),
      // Products
      Expanded(child: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.or))
        : filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📭', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              const Text('Sin productos', style: TextStyle(color: AppTheme.tm, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(onTap: _showAddProduct,
                child: const Text('+ Agregar primer producto', style: TextStyle(color: AppTheme.or, fontWeight: FontWeight.w700))),
            ]))
          : RefreshIndicator(onRefresh: _loadProductos, color: AppTheme.or,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _productCard(filtered[i]),
              ))),
    ]);
  }

  Widget _productCard(NegocioProducto p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.disponible ? AppTheme.bd : AppTheme.rd.withOpacity(0.3)),
        color: p.disponible ? Colors.transparent : AppTheme.rd.withOpacity(0.05)),
      child: Row(children: [
        // Foto
        Container(width: 56, height: 56,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppTheme.cd,
            image: p.fotoUrl != null ? DecorationImage(image: NetworkImage(p.fotoUrl!), fit: BoxFit.cover) : null),
          child: p.fotoUrl == null ? const Icon(Icons.fastfood, color: AppTheme.td, size: 24) : null),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.nombre, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: p.disponible ? AppTheme.tx : AppTheme.td)),
          if (p.descripcion != null && p.descripcion!.isNotEmpty)
            Text(p.descripcion!, style: const TextStyle(fontSize: 9, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (p.categoria != null)
            Text(p.categoria!, style: const TextStyle(fontSize: 8, color: AppTheme.td)),
        ])),
        Column(children: [
          Text('\$${p.precio.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
            color: p.disponible ? AppTheme.gr : AppTheme.td, fontFamily: 'monospace')),
          const SizedBox(height: 4),
          // Toggle disponible
          GestureDetector(
            onTap: () => _toggleDisponible(p),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: p.disponible ? AppTheme.gr.withOpacity(0.15) : AppTheme.rd.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8)),
              child: Text(p.disponible ? 'Activo' : 'Agotado',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: p.disponible ? AppTheme.gr : AppTheme.rd)))),
        ]),
        const SizedBox(width: 6),
        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.rd),
          onPressed: () => _deleteProduct(p)),
      ]),
    );
  }

  void _toggleDisponible(NegocioProducto p) async {
    await FirestoreService.toggleProductoDisponible(widget.negocioId, p.id, !p.disponible);
    _loadProductos();
  }

  void _deleteProduct(NegocioProducto p) async {
    final confirm = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.sf,
        title: const Text('¿Eliminar producto?', style: TextStyle(color: AppTheme.tx, fontSize: 16)),
        content: Text('Se eliminará "${p.nombre}"', style: const TextStyle(color: AppTheme.tm, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppTheme.rd))),
        ]));
    if (confirm == true) {
      await FirestoreService.eliminarProductoNegocio(widget.negocioId, p.id);
      _loadProductos();
    }
  }

  void _showAddProduct() {
    final nombre = TextEditingController();
    final precio = TextEditingController();
    final desc = TextEditingController();
    final cat = TextEditingController();

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Nuevo Producto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          const SizedBox(height: 16),
          _field('Nombre', nombre, 'Ej: Hamburguesa Clásica'),
          _field('Precio', precio, 'Ej: 85', keyboard: TextInputType.number),
          _field('Descripción', desc, 'Ej: Con papas y refresco'),
          _field('Categoría', cat, 'Ej: Hamburguesas'),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: () async {
              if (nombre.text.isEmpty || precio.text.isEmpty) return;
              await FirestoreService.guardarProductoNegocio(widget.negocioId, {
                'nombre': nombre.text.trim(),
                'precio': double.tryParse(precio.text) ?? 0,
                'descripcion': desc.text.trim(),
                'categoria': cat.text.trim().isEmpty ? 'General' : cat.text.trim(),
                'disponible': true,
              });
              if (!mounted) return;
              Navigator.pop(context);
              _loadProductos();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.or, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Guardar Producto', style: TextStyle(fontWeight: FontWeight.w700)),
          )),
        ])));
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {TextInputType? keyboard}) {
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: ctrl, keyboardType: keyboard,
        style: const TextStyle(color: AppTheme.tx, fontSize: 13),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
          hintText: hint, hintStyle: const TextStyle(color: AppTheme.td, fontSize: 11),
          filled: true, fillColor: AppTheme.cd,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.or)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))));
  }
}
