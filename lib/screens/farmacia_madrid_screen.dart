import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

// ═══ FARMACIAS MADRID COLOR SCHEME ═══
class FMColors {
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFF42A5F5);
  static const bg = Color(0xFF0D2137);
  static const surface = Color(0xFF0F2844);
  static const card = Color(0xFF112A45);
  static const border = Color(0xFF1E88E5);
  static const borderDim = Color(0xFF1A3A5C);
  static const text = Colors.white;
  static const textMuted = Color(0xFF90CAF9);
  static const textDim = Color(0xFF5C8AB8);
}

// ═══ SUCURSAL DATA ═══
class _Sucursal {
  final String nombre, direccion, horario, tel;
  final double lat, lng;
  _Sucursal({required this.nombre, required this.direccion, required this.horario, required this.tel, required this.lat, required this.lng});
}

final _sucursales = [
  _Sucursal(nombre: 'Farmacias Madrid - Panteón', direccion: 'Calz. Hidalgo 1311, Tulancingo', horario: '8:00 – 22:00', tel: '7753200224', lat: 20.0890, lng: -98.3650),
  _Sucursal(nombre: 'Farmacias Madrid - Lázaro', direccion: 'Gral. L. Cárdenas 107, Tulancingo', horario: '8:00 – 22:00', tel: '7753200224', lat: 20.0830, lng: -98.3580),
  _Sucursal(nombre: 'Farmacias Madrid - Santa María', direccion: 'C. Jazmín 64, Col. Santa María, Tulancingo', horario: '8:00 – 22:00', tel: '7753200224', lat: 20.0780, lng: -98.3700),
  _Sucursal(nombre: 'Farmacias Madrid - Caballito', direccion: '21 de Marzo, Caballito, Tulancingo', horario: '8:00 – 22:00', tel: '7753200224', lat: 20.0920, lng: -98.3540),
];

// ═══ CATEGORÍA DATA ═══
class _Categoria {
  final String nombre, emoji;
  _Categoria({required this.nombre, required this.emoji});
}

final _categorias = [
  _Categoria(nombre: 'Medicamentos\ngenéricos', emoji: '💊'),
  _Categoria(nombre: 'Medicamentos\npatentes', emoji: '💉'),
  _Categoria(nombre: 'Material de\ncuración', emoji: '🩹'),
  _Categoria(nombre: 'Bebés y\nmaternidad', emoji: '👶'),
  _Categoria(nombre: 'Higiene\npersonal', emoji: '🧴'),
  _Categoria(nombre: 'Dermo-\ncosméticos', emoji: '💄'),
  _Categoria(nombre: 'Equipo\nmédico', emoji: '🏥'),
  _Categoria(nombre: 'Naturistas', emoji: '🌿'),
  _Categoria(nombre: 'Dulcería\ny snacks', emoji: '🍬'),
  _Categoria(nombre: 'Pruebas\nrápidas', emoji: '🧪'),
];

// ═══ MAIN SCREEN ═══
class FarmaciaMadridScreen extends StatefulWidget {
  final bool online;
  final List<Map<String, dynamic>> apiFarmProductos;
  final void Function(String name, int price, String from, {int? oferta}) onAddToCart;
  final int cartQty;
  final int cartTotal;
  final VoidCallback onOpenCart;
  final VoidCallback? onBack;

  const FarmaciaMadridScreen({
    super.key,
    required this.online,
    required this.apiFarmProductos,
    required this.onAddToCart,
    required this.cartQty,
    required this.cartTotal,
    required this.onOpenCart,
    this.onBack,
  });

  @override
  State<FarmaciaMadridScreen> createState() => _FarmaciaMadridScreenState();
}

class _FarmaciaMadridScreenState extends State<FarmaciaMadridScreen> {
  // Search
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  // Card carousel
  final _cardPageCtrl = PageController(viewportFraction: 0.92);
  int _currentCard = 0;
  Timer? _autoScroll;

  // Receta
  String? _recetaPath;

  // Selected category
  String? _selectedCat;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _cardPageCtrl.dispose();
    _autoScroll?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScroll = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_cardPageCtrl.hasClients) return;
      final next = (_currentCard + 1) % 3;
      _cardPageCtrl.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void _search(String q) async {
    setState(() { _searchQuery = q; _searching = true; });
    if (widget.online && q.length >= 2) {
      final results = await ApiService.buscarFarmacia(q);
      if (!mounted) return;
      setState(() { _searchResults = results; _searching = false; });
    } else {
      setState(() { _searchResults = []; _searching = false; });
    }
  }

  bool _isOpen(String horario) {
    final now = TimeOfDay.now();
    final parts = horario.replaceAll(' ', '').split('–');
    if (parts.length != 2) return false;
    final open = _parseTime(parts[0]);
    final close = _parseTime(parts[1]);
    if (open == null || close == null) return false;
    final nowMin = now.hour * 60 + now.minute;
    return nowMin >= open.hour * 60 + open.minute && nowMin <= close.hour * 60 + close.minute;
  }

  TimeOfDay? _parseTime(String t) {
    final p = t.split(':');
    if (p.length != 2) return null;
    return TimeOfDay(hour: int.tryParse(p[0]) ?? 0, minute: int.tryParse(p[1]) ?? 0);
  }

  void _openMaps(double lat, double lng, String name) {
    launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'), mode: LaunchMode.externalApplication);
  }

  void _callPhone(String tel) {
    launchUrl(Uri.parse('tel:+52$tel'), mode: LaunchMode.externalApplication);
  }

  void _pickReceta({bool gallery = false}) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: gallery ? ImageSource.gallery : ImageSource.camera, imageQuality: 80);
    if (img == null) return;
    setState(() => _recetaPath = img.path);
    final buf = StringBuffer();
    buf.writeln('*COTIZACION DE RECETA MEDICA*');
    buf.writeln('━━━━━━━━━━━━━━━━━━');
    buf.writeln('El cliente ha enviado foto de su receta');
    buf.writeln('Solicita cotizacion de disponibilidad y precio');
    buf.writeln('\n_Enviado desde Cargo-GO - Farmacias Madrid_');
    launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}'), mode: LaunchMode.externalApplication);
  }

  // ═══ PEDIDO URGENTE ═══
  void _showPedidoUrgente() {
    final medicamento = TextEditingController();
    final nombre = TextEditingController();
    final tel = TextEditingController();
    final direccion = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: FMColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: FMColors.textDim, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.flash_on, color: Color(0xFFFF5252), size: 32),
          ),
          const SizedBox(height: 10),
          const Text('PEDIDO URGENTE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFF5252), letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('Te lo enviamos lo mas rapido posible', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
          const SizedBox(height: 18),
          _formField(medicamento, 'Que medicamento necesitas?', Icons.medication),
          const SizedBox(height: 10),
          _formField(nombre, 'Tu nombre', Icons.person),
          const SizedBox(height: 10),
          _formField(tel, 'Tu telefono', Icons.phone, keyboard: TextInputType.phone),
          const SizedBox(height: 10),
          _formField(direccion, 'Direccion de entrega', Icons.location_on),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (medicamento.text.isEmpty || tel.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                  content: Text('Escribe el medicamento y tu telefono', style: TextStyle(fontWeight: FontWeight.w700)),
                  backgroundColor: Colors.redAccent));
                return;
              }
              final buf = StringBuffer();
              buf.writeln('*PEDIDO URGENTE - FARMACIAS MADRID*');
              buf.writeln('━━━━━━━━━━━━━━━━━━');
              buf.writeln('Medicamento: ${medicamento.text}');
              buf.writeln('Nombre: ${nombre.text}');
              buf.writeln('Tel: ${tel.text}');
              if (direccion.text.isNotEmpty) buf.writeln('Direccion: ${direccion.text}');
              buf.writeln('\n_URGENTE - Enviado desde Cargo-GO_');
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}'), mode: LaunchMode.externalApplication);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.flash_on, size: 20),
              SizedBox(width: 8),
              Text('ENVIAR PEDIDO URGENTE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
            ]),
          )),
          const SizedBox(height: 6),
          const Text('Se envia directo por WhatsApp', style: TextStyle(fontSize: 10, color: FMColors.textDim)),
        ])),
      ),
    );
  }

  // ═══ CREDITO BANNER + FORM ═══

  Widget _creditoBanner() {
    return GestureDetector(
      onTap: _showCreditoForm,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CREDITIS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
              SizedBox(height: 2),
              Text('Credito medico sin aval, sin buro', style: TextStyle(fontSize: 12, color: Colors.white70)),
            ])),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _creditoChip(Icons.check_circle, 'Sin aval'),
            const SizedBox(width: 8),
            _creditoChip(Icons.check_circle, 'Sin buro'),
            const SizedBox(width: 8),
            _creditoChip(Icons.bolt, 'Aprobacion rapida'),
          ]),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.credit_card, color: Color(0xFF1565C0), size: 20),
              SizedBox(width: 8),
              Text('SOLICITAR CREDITO', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1565C0), letterSpacing: 1)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _creditoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
      ]),
    );
  }

  void _showCreditoForm() {
    final nombre = TextEditingController();
    final tel = TextEditingController();
    final monto = TextEditingController();
    final tratamiento = TextEditingController();
    final doctor = TextEditingController();
    String tipo = 'Personal';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: FMColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: FMColors.textDim, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: FMColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.account_balance_wallet, color: FMColors.secondary, size: 30),
          ),
          const SizedBox(height: 12),
          const Text('SOLICITAR CREDITO MEDICO', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: FMColors.text, letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('Completa tus datos y te contactamos', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
          const SizedBox(height: 20),
          _formField(nombre, 'Nombre completo', Icons.person),
          const SizedBox(height: 10),
          _formField(tel, 'Telefono (10 digitos)', Icons.phone, keyboard: TextInputType.phone),
          const SizedBox(height: 10),
          // Tipo de credito selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: FMColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: FMColors.borderDim)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: tipo, isExpanded: true, dropdownColor: FMColors.card,
              style: const TextStyle(color: FMColors.text, fontSize: 13),
              icon: const Icon(Icons.expand_more, color: FMColors.textDim),
              items: ['Personal', 'Especialidad (oncologia, cardiologia...)', 'Institucional (clinica/hospital)']
                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) => setS(() => tipo = v!),
            )),
          ),
          const SizedBox(height: 10),
          _formField(monto, 'Monto solicitado (\$)', Icons.attach_money, keyboard: TextInputType.number),
          const SizedBox(height: 10),
          _formField(tratamiento, 'Tipo de tratamiento / padecimiento', Icons.medical_services),
          const SizedBox(height: 10),
          _formField(doctor, 'Hospital o doctor que lo atiende (opcional)', Icons.local_hospital),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nombre.text.isEmpty || tel.text.isEmpty || monto.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                  content: Text('Completa nombre, telefono y monto', style: TextStyle(fontWeight: FontWeight.w700)),
                  backgroundColor: Colors.redAccent));
                return;
              }
              final buf = StringBuffer();
              buf.writeln('*SOLICITUD DE CREDITO MEDICO - CREDITIS*');
              buf.writeln('━━━━━━━━━━━━━━━━━━');
              buf.writeln('Nombre: ${nombre.text}');
              buf.writeln('Tel: ${tel.text}');
              buf.writeln('Tipo: $tipo');
              buf.writeln('Monto solicitado: \$${monto.text}');
              buf.writeln('Tratamiento: ${tratamiento.text}');
              if (doctor.text.isNotEmpty) buf.writeln('Hospital/Doctor: ${doctor.text}');
              buf.writeln('\n_Enviado desde Cargo-GO - Farmacias Madrid_');
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}'), mode: LaunchMode.externalApplication);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Solicitud enviada por WhatsApp', style: TextStyle(fontWeight: FontWeight.w700)),
                backgroundColor: FMColors.primary));
            },
            style: ElevatedButton.styleFrom(backgroundColor: FMColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.send, size: 18),
              SizedBox(width: 8),
              Text('ENVIAR SOLICITUD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
            ]),
          )),
          const SizedBox(height: 8),
          const Text('Te contactaremos en menos de 24 horas', style: TextStyle(fontSize: 10, color: FMColors.textDim)),
        ])),
      )),
    );
  }

  // ═══ CARD FORM DIALOGS ═══

  void _showBlueForm() {
    final nombre = TextEditingController();
    final tel = TextEditingController();
    String sucursal = 'Panteón';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: FMColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: FMColors.textDim, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('SOLICITAR TARJETA BLUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FMColors.secondary)),
          const SizedBox(height: 4),
          const Text('Monedero Electronico · GRATIS', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
          const SizedBox(height: 16),
          _formField(nombre, 'Nombre completo', Icons.person),
          const SizedBox(height: 10),
          _formField(tel, 'Telefono', Icons.phone, keyboard: TextInputType.phone),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: FMColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: FMColors.borderDim)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: sucursal, isExpanded: true, dropdownColor: FMColors.card,
              style: const TextStyle(color: FMColors.text, fontSize: 13),
              icon: const Icon(Icons.expand_more, color: FMColors.textDim),
              items: ['Panteon', 'Lazaro', 'Santa Maria', 'Caballito'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setS(() => sucursal = v!),
            )),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nombre.text.isEmpty || tel.text.isEmpty) return;
              final buf = StringBuffer();
              buf.writeln('*SOLICITUD TARJETA BLUE*');
              buf.writeln('━━━━━━━━━━━━━━━━━━');
              buf.writeln('Nombre: ${nombre.text}');
              buf.writeln('Tel: ${tel.text}');
              buf.writeln('Sucursal preferida: $sucursal');
              buf.writeln('\n_Enviado desde Cargo-GO - Farmacias Madrid_');
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}'), mode: LaunchMode.externalApplication);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: FMColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('SOLICITAR TARJETA BLUE', style: TextStyle(fontWeight: FontWeight.w800)),
          )),
        ]),
      )),
    );
  }

  void _showGoldForm() {
    final nombre = TextEditingController();
    final tel = TextEditingController();
    final ine = TextEditingController();
    final tratamiento = TextEditingController();
    final monto = TextEditingController();
    final doctor = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: FMColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: FMColors.textDim, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('SOLICITAR TARJETA GOLD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFFFD700))),
          const SizedBox(height: 4),
          const Text('Credito en Medicamento de Especialidad', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
          const SizedBox(height: 16),
          _formField(nombre, 'Nombre completo', Icons.person),
          const SizedBox(height: 10),
          _formField(tel, 'Telefono', Icons.phone, keyboard: TextInputType.phone),
          const SizedBox(height: 10),
          _formField(ine, 'Numero de INE', Icons.badge, keyboard: TextInputType.number),
          const SizedBox(height: 10),
          _formField(tratamiento, 'Tipo de tratamiento', Icons.medical_services),
          const SizedBox(height: 10),
          _formField(monto, 'Monto estimado mensual (\$)', Icons.attach_money, keyboard: TextInputType.number),
          const SizedBox(height: 10),
          _formField(doctor, 'Hospital/Doctor que lo atiende', Icons.local_hospital),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (nombre.text.isEmpty || tel.text.isEmpty) return;
              final buf = StringBuffer();
              buf.writeln('*SOLICITUD TARJETA GOLD - CREDITIS*');
              buf.writeln('━━━━━━━━━━━━━━━━━━');
              buf.writeln('Nombre: ${nombre.text}');
              buf.writeln('Tel: ${tel.text}');
              buf.writeln('INE: ${ine.text}');
              buf.writeln('Tratamiento: ${tratamiento.text}');
              buf.writeln('Monto mensual: \$${monto.text}');
              buf.writeln('Hospital/Doctor: ${doctor.text}');
              buf.writeln('\n_Enviado desde Cargo-GO - Farmacias Madrid_');
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}'), mode: LaunchMode.externalApplication);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8860B), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('SOLICITAR TARJETA GOLD', style: TextStyle(fontWeight: FontWeight.w800)),
          )),
        ])),
      ),
    );
  }

  void _showBlackForm() {
    final clinica = TextEditingController();
    final rfc = TextEditingController();
    final direccion = TextEditingController();
    final responsable = TextEditingController();
    final tel = TextEditingController();
    final consumo = TextEditingController();
    final especialidades = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: FMColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: FMColors.textDim, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('SOLICITAR TARJETA BLACK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFC0C0C0))),
          const SizedBox(height: 4),
          const Text('Credito Clinicas y Hospitales', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
          const SizedBox(height: 16),
          _formField(clinica, 'Nombre de clinica/hospital', Icons.local_hospital),
          const SizedBox(height: 10),
          _formField(rfc, 'RFC', Icons.description),
          const SizedBox(height: 10),
          _formField(direccion, 'Direccion', Icons.location_on),
          const SizedBox(height: 10),
          _formField(responsable, 'Nombre del responsable', Icons.person),
          const SizedBox(height: 10),
          _formField(tel, 'Telefono', Icons.phone, keyboard: TextInputType.phone),
          const SizedBox(height: 10),
          _formField(consumo, 'Consumo estimado mensual (\$)', Icons.attach_money, keyboard: TextInputType.number),
          const SizedBox(height: 10),
          _formField(especialidades, 'Especialidades que manejan', Icons.medical_services),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (clinica.text.isEmpty || tel.text.isEmpty) return;
              final buf = StringBuffer();
              buf.writeln('*SOLICITUD TARJETA BLACK - CREDITIS INSTITUCIONAL*');
              buf.writeln('━━━━━━━━━━━━━━━━━━');
              buf.writeln('Clinica/Hospital: ${clinica.text}');
              buf.writeln('RFC: ${rfc.text}');
              buf.writeln('Direccion: ${direccion.text}');
              buf.writeln('Responsable: ${responsable.text}');
              buf.writeln('Tel: ${tel.text}');
              buf.writeln('Consumo mensual: \$${consumo.text}');
              buf.writeln('Especialidades: ${especialidades.text}');
              buf.writeln('\n_Enviado desde Cargo-GO - Farmacias Madrid_');
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}'), mode: LaunchMode.externalApplication);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF333333), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFF666666))),
            child: const Text('SOLICITAR TARJETA BLACK', style: TextStyle(fontWeight: FontWeight.w800)),
          )),
        ])),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboard}) {
    return TextField(
      controller: ctrl, keyboardType: keyboard,
      style: const TextStyle(color: FMColors.text, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: FMColors.textDim, fontSize: 13),
        prefixIcon: Icon(icon, color: FMColors.textDim, size: 18),
        filled: true, fillColor: FMColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: FMColors.borderDim)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: FMColors.borderDim)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: FMColors.secondary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  // ═══ BUILD ═══
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FMColors.bg,
      body: CustomScrollView(
        slivers: [
          // ═══ HEADER ═══
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: FMColors.primary,
            automaticallyImplyLeading: false,
            leading: widget.onBack != null ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: widget.onBack,
            ) : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), FMColors.primary, FMColors.secondary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(children: [
                  Positioned(right: -30, top: -20, child: Container(width: 120, height: 120,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                  Positioned(left: -20, bottom: -30, child: Container(width: 80, height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF67D8EF)]), borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]),
                          child: ClipRRect(borderRadius: BorderRadius.circular(12),
                            child: Image.asset('assets/images/farmacia_madrid_logo.png', fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.local_pharmacy, color: FMColors.primary, size: 28))),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Farmacias Madrid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                          Text('Tu salud, nuestra prioridad', style: TextStyle(fontSize: 11, color: Colors.white70)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.verified, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('4 Sucursales', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
          ),

          // ═══ BODY ═══
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ─── 1. TARJETAS / MEMBRESIAS CAROUSEL ───
              _sectionTitle('Tarjetas Farmacias Madrid', Icons.credit_card),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: PageView(
                  controller: _cardPageCtrl,
                  onPageChanged: (i) => setState(() => _currentCard = i),
                  children: [_blueCard(), _goldCard(), _blackCard()],
                ),
              ),
              const SizedBox(height: 8),
              // Dot indicators
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) {
                final colors = [FMColors.secondary, const Color(0xFFFFD700), const Color(0xFF666666)];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentCard == i ? 20 : 6, height: 6,
                  decoration: BoxDecoration(
                    color: _currentCard == i ? colors[i] : colors[i].withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              })),

              const SizedBox(height: 20),

              // ─── SOLICITAR CRÉDITO BANNER ───
              _creditoBanner(),

              const SizedBox(height: 24),

              // ─── 2. BUSCAR + PEDIDO URGENTE ───
              Row(children: [
                // Buscador chico dorado
                Expanded(child: SizedBox(height: 44, child: TextField(
                  controller: _searchCtrl, onChanged: _search,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Buscar medicamento...',
                    hintStyle: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.5), fontSize: 12),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700), size: 18),
                    suffixIcon: _searching
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD700))))
                      : _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.close, color: Color(0xFFB8860B), size: 16), onPressed: () { _searchCtrl.clear(); _search(''); })
                        : null,
                    filled: true, fillColor: FMColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFB8860B), width: 1)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                ))),
                const SizedBox(width: 8),
                // Botón PEDIDO URGENTE
                GestureDetector(
                  onTap: _showPedidoUrgente,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF5252)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.flash_on, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text('URGENTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                    ]),
                  ),
                ),
              ]),
              if (_searchQuery.isNotEmpty && _searchResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('${_searchResults.length} resultado${_searchResults.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 11, color: FMColors.textMuted)),
                const SizedBox(height: 6),
                ..._searchResults.take(15).map((p) => _searchResultCard(p)),
              ],
              if (_searchQuery.length >= 2 && _searchResults.isEmpty && !_searching)
                Padding(padding: const EdgeInsets.only(top: 8),
                  child: Container(padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: FMColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: FMColors.borderDim)),
                    child: const Row(children: [
                      Icon(Icons.info_outline, color: FMColors.textDim, size: 18), SizedBox(width: 8),
                      Expanded(child: Text('No se encontraron resultados. Intenta con otro nombre.', style: TextStyle(fontSize: 11, color: FMColors.textMuted))),
                    ]))),

              const SizedBox(height: 24),

              // ─── 3. CATEGORIAS ───
              _sectionTitle('Categorias', Icons.category),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.4,
                children: _categorias.map((c) => _categoriaCard(c)).toList(),
              ),
              if (_selectedCat != null) ...[
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: FMColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: FMColors.secondary.withOpacity(0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.inventory_2, size: 16, color: FMColors.secondary), const SizedBox(width: 6),
                      Text(_selectedCat!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FMColors.text)),
                      const Spacer(),
                      GestureDetector(onTap: () => setState(() => _selectedCat = null), child: const Icon(Icons.close, size: 16, color: FMColors.textDim)),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Proximamente: catalogo completo.\nVisita tu sucursal o llama para consultar.', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      onPressed: () => _callPhone('7753200224'),
                      icon: const Icon(Icons.phone, size: 16), label: const Text('Llamar para consultar'),
                      style: ElevatedButton.styleFrom(backgroundColor: FMColors.primary, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    )),
                  ])),
              ],

              const SizedBox(height: 24),

              // ─── 4. SUCURSALES ───
              _sectionTitle('Sucursales', Icons.store),
              const SizedBox(height: 10),
              ..._sucursales.map((s) => _sucursalCard(s)),

              const SizedBox(height: 24),

              // ─── 5. PEDIR A DOMICILIO ───
              _deliverySection(),

              const SizedBox(height: 24),

              // ─── 6. RECETAS ───
              _recetaSection(),

              const SizedBox(height: 100),
            ]),
          )),
        ],
      ),
      floatingActionButton: widget.cartQty > 0 ? FloatingActionButton.extended(
        onPressed: widget.onOpenCart, backgroundColor: const Color(0xFFE3F2FD), heroTag: 'farmMadridCart',
        icon: const Icon(Icons.shopping_cart, color: Color(0xFF0D47A1), size: 18),
        label: Text('${widget.cartQty} · \$${widget.cartTotal}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
      ) : null,
    );
  }

  // ═══ CREDIT CARD WIDGETS ═══

  Widget _blueCard() {
    return GestureDetector(
      onTap: _showBlueForm,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Stack(children: [
          // Decorative
          Positioned(right: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
          Positioned(left: -10, bottom: -10, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Chip
              Container(width: 36, height: 26, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
              )),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('FARMACIAS MADRID', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 2)),
                Container(height: 1, width: 60, color: Colors.white24),
              ]),
            ]),
            const SizedBox(height: 12),
            const Text('....  ....  ....  ....', style: TextStyle(fontSize: 16, color: Colors.white54, letterSpacing: 3, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            const Text('FARMACIAS MADRID BLUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
            const Text('Monedero Electronico', style: TextStyle(fontSize: 11, color: Colors.white70)),
            const Spacer(),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Acumula Puntos Saturno', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.8))),
                Text('Usa tus puntos como dinero', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.8))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('GRATIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _goldCard() {
    return GestureDetector(
      onTap: _showGoldForm,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFB8860B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Stack(children: [
          Positioned(right: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
          Positioned(left: -10, bottom: -10, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 26, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFD700)]),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.5), blurRadius: 4)],
              )),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('FARMACIAS MADRID', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF5D4037), letterSpacing: 2)),
                Container(height: 1, width: 60, color: const Color(0xFF5D4037).withOpacity(0.3)),
              ]),
            ]),
            const SizedBox(height: 12),
            const Text('....  ....  ....  ....', style: TextStyle(fontSize: 16, color: Color(0xFF5D4037), letterSpacing: 3, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            const Text('FARMACIAS MADRID GOLD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF3E2723), letterSpacing: 1)),
            const Text('Credito en Medicamento de Especialidad', style: TextStyle(fontSize: 10, color: Color(0xFF5D4037))),
            const Spacer(),
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Credito para medicamento especializado', style: TextStyle(fontSize: 9, color: Color(0xFF5D4037))),
                Text('Paga tu tratamiento a plazos', style: TextStyle(fontSize: 9, color: Color(0xFF5D4037))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF5D4037).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('CREDITO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF3E2723)))),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _blackCard() {
    return GestureDetector(
      onTap: _showBlackForm,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF333333)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6))],
          border: Border.all(color: const Color(0xFF555555), width: 0.5),
        ),
        child: Stack(children: [
          // Silver sparkle lines
          Positioned(right: 30, top: 15, child: Container(width: 40, height: 0.5, color: const Color(0xFF888888).withOpacity(0.3))),
          Positioned(right: 50, top: 25, child: Container(width: 25, height: 0.5, color: const Color(0xFF888888).withOpacity(0.2))),
          Positioned(left: 40, bottom: 50, child: Container(width: 30, height: 0.5, color: const Color(0xFF888888).withOpacity(0.2))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Silver chip
              Container(width: 36, height: 26, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(colors: [Color(0xFFC0C0C0), Color(0xFF808080)]),
              )),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('FARMACIAS MADRID', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF999999), letterSpacing: 2)),
                Container(height: 1, width: 60, color: const Color(0xFF555555)),
              ]),
            ]),
            const SizedBox(height: 12),
            Text('....  ....  ....  ....', style: TextStyle(fontSize: 16, color: const Color(0xFFC0C0C0).withOpacity(0.4), letterSpacing: 3, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            const Text('FARMACIAS MADRID BLACK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFC0C0C0), letterSpacing: 1)),
            const Text('Credito Clinicas y Hospitales', style: TextStyle(fontSize: 10, color: Color(0xFF999999))),
            const Spacer(),
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Linea de credito institucional', style: TextStyle(fontSize: 9, color: Color(0xFF999999))),
                Text('Facturacion y pago a 30/60/90 dias', style: TextStyle(fontSize: 9, color: Color(0xFF999999))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFC0C0C0).withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF666666), width: 0.5)),
                child: const Text('PREMIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFC0C0C0)))),
            ]),
          ])),
        ]),
      ),
    );
  }

  // ═══ SECTION TITLE ═══
  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: FMColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: FMColors.secondary)),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FMColors.text)),
    ]);
  }

  // ═══ SEARCH RESULT CARD ═══
  Widget _searchResultCard(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: FMColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: FMColors.borderDim)),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: FMColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.medication, size: 18, color: FMColors.secondary)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p['nombre'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: FMColors.text), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${p['laboratorio'] ?? ''} · Stock: ${p['stock'] ?? 0}', style: const TextStyle(fontSize: 9, color: FMColors.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${p['precio'] ?? 0}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: FMColors.secondary, fontFamily: 'monospace')),
          if (p['requiere_receta'] == true) const Text('Receta', style: TextStyle(fontSize: 8, color: Colors.orangeAccent, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => widget.onAddToCart(p['nombre'] ?? '', (p['precio'] as num?)?.toInt() ?? 0, 'Farmacias Madrid'),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: FMColors.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white))),
      ]),
    );
  }

  // ═══ CATEGORIA CARD ═══
  Widget _categoriaCard(_Categoria c) {
    final name = c.nombre.replaceAll('\n', ' ');
    final selected = _selectedCat == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedCat = selected ? null : name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? FMColors.primary.withOpacity(0.2) : null,
          gradient: selected ? null : const LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF67D8EF)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? FMColors.secondary : const Color(0xFFE0E0E0), width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Text(c.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(child: Text(c.nombre, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: selected ? FMColors.secondary : const Color(0xFF1A1A1A), height: 1.2), maxLines: 2)),
        ]),
      ),
    );
  }

  // ═══ SUCURSAL CARD ═══
  Widget _sucursalCard(_Sucursal s) {
    final open = _isOpen(s.horario);
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FMColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FMColors.primary, width: 1),
        boxShadow: [BoxShadow(color: FMColors.primary.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: FMColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.local_pharmacy, size: 22, color: FMColors.secondary)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FMColors.text)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.location_on, size: 11, color: FMColors.textMuted), const SizedBox(width: 3),
              Expanded(child: Text(s.direccion, style: const TextStyle(fontSize: 10, color: FMColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: open ? FMColors.primary.withOpacity(0.2) : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: open ? FMColors.secondary : Colors.redAccent, width: 0.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: open ? FMColors.secondary : Colors.redAccent)),
              const SizedBox(width: 4),
              Text(open ? 'Abierta' : 'Cerrada', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: open ? FMColors.secondary : Colors.redAccent)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _infoChip(Icons.access_time, s.horario), const SizedBox(width: 8),
          _infoChip(Icons.phone, s.tel),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _actionBtn(Icons.phone, 'Llamar', () => _callPhone(s.tel))),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn(Icons.map, 'Ubicacion', () => _openMaps(s.lat, s.lng, s.nombre))),
          const SizedBox(width: 8),
          Expanded(child: _actionBtn(Icons.message, 'WhatsApp', () {
            launchUrl(Uri.parse('https://wa.me/52${s.tel}'), mode: LaunchMode.externalApplication);
          })),
        ]),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: FMColors.bg, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: FMColors.textDim), const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: FMColors.textMuted)),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: FMColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: FMColors.primary.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: FMColors.secondary), const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: FMColors.secondary)),
        ]),
      ),
    );
  }

  // ═══ DELIVERY SECTION ═══
  Widget _deliverySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Entrega a Domicilio', Icons.delivery_dining),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: FMColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: FMColors.border, width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.delivery_dining, color: FMColors.secondary, size: 28),
            const SizedBox(width: 8),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Servicio a Domicilio GRATIS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: FMColors.text)),
              Text('Sin costo adicional en todas las ciudades', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(20)),
              child: const Text('GRATIS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 14),

          // Ciudades de cobertura
          const Text('Cobertura de entrega:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: FMColors.textMuted)),
          const SizedBox(height: 8),
          Row(children: [
            _cityChip('Tulancingo', Icons.location_city, true),
            const SizedBox(width: 6),
            _cityChip('Pachuca', Icons.location_city, true),
            const SizedBox(width: 6),
            _cityChip('CDMX', Icons.location_city, true),
          ]),
          const SizedBox(height: 14),

          _deliveryStep('1', 'Busca tu medicamento arriba'),
          _deliveryStep('2', 'Agregalo al carrito'),
          _deliveryStep('3', 'Confirma tu pedido y direccion'),
          _deliveryStep('4', 'Te lo llevamos sin costo adicional'),
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _deliveryChip(Icons.money_off, 'Envio GRATIS'),
            _deliveryChip(Icons.access_time, 'Mismo dia en Tulancingo'),
            _deliveryChip(Icons.schedule, '24-48 hrs Pachuca/CDMX'),
          ]),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Busca tu medicamento arriba y agregalo al carrito', style: TextStyle(fontWeight: FontWeight.w700)),
              backgroundColor: Color(0xFFD32F2F))),
            icon: const Icon(Icons.delivery_dining, size: 20, color: Color(0xFF1A1A1A)),
            label: const Text('PEDIR A DOMICILIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1A1A1A))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ]),
      ),
    ]);
  }

  Widget _cityChip(String city, IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? FMColors.primary.withOpacity(0.2) : FMColors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? FMColors.secondary : FMColors.borderDim)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: active ? FMColors.secondary : FMColors.textDim),
        const SizedBox(width: 4),
        Text(city, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? FMColors.secondary : FMColors.textDim)),
      ]),
    );
  }

  Widget _deliveryChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: FMColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: FMColors.secondary), const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: FMColors.secondary)),
      ]),
    );
  }

  Widget _deliveryStep(String num, String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(width: 22, height: 22, decoration: BoxDecoration(color: FMColors.primary, borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text(num, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)))),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: FMColors.textMuted)),
      ]));
  }

  // ═══ RECETA SECTION ═══
  Widget _recetaSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Apartado de Recetas', Icons.receipt_long),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: FMColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: FMColors.border, width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.camera_alt, color: FMColors.secondary, size: 24), SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sube tu receta medica', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: FMColors.text)),
              Text('Toma foto y te cotizamos al instante', style: TextStyle(fontSize: 11, color: FMColors.textMuted)),
            ])),
          ]),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: FMColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: FMColors.borderDim)),
            child: Column(children: [
              Icon(_recetaPath != null ? Icons.check_circle : Icons.add_a_photo, size: 36, color: _recetaPath != null ? FMColors.secondary : FMColors.textDim),
              const SizedBox(height: 6),
              Text(_recetaPath != null ? 'Foto tomada' : 'Toca para tomar foto de tu receta',
                style: TextStyle(fontSize: 11, color: _recetaPath != null ? FMColors.secondary : FMColors.textDim)),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _pickReceta(),
              icon: const Icon(Icons.camera_alt, size: 18), label: const Text('TOMAR FOTO', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: FMColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _pickReceta(gallery: true),
              icon: const Icon(Icons.photo_library, size: 18), label: const Text('GALERIA', style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: FMColors.card, foregroundColor: FMColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: FMColors.border)),
            )),
          ]),
          const SizedBox(height: 8),
          const Text('La farmacia te respondera por WhatsApp con precio y disponibilidad.',
            style: TextStyle(fontSize: 10, color: FMColors.textDim), textAlign: TextAlign.center),
        ]),
      ),
    ]);
  }
}
