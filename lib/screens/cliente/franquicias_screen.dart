import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../services/firestore_service.dart';

class FranquiciasScreen extends StatefulWidget {
  const FranquiciasScreen({super.key});
  @override State<FranquiciasScreen> createState() => _FranquiciasState();
}

class _FranquiciasState extends State<FranquiciasScreen> {
  // Simulator sliders
  double _enviosDia = 20;
  double _negociosSuscritos = 10;
  bool _showForm = false;
  String? _paqueteSeleccionado;

  // Form controllers
  final _nombreCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _comentCtrl = TextEditingController();
  String _experiencia = 'no';
  bool _tieneMoto = false;
  bool _saving = false;
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: _sent ? _successView() : CustomScrollView(slivers: [
        // Hero AppBar
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppTheme.sf,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A0A3E), Color(0xFF0D0620), Color(0xFF060B18)])),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🚚', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 10),
                  const Text('FRANQUICIAS CARGO-GO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('"Tu propio negocio de envíos\nlisto para operar"', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic, height: 1.4)),
                  const SizedBox(height: 14),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA502)])),
                    child: const Text('Inversión desde \$50,000 MXN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black))),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _heroStat('200+', 'Ciudades'),
                    const SizedBox(width: 20),
                    _heroStat('4-6', 'Meses ROI'),
                    const SizedBox(width: 20),
                    _heroStat('0%', 'Comisión'),
                  ]),
                ]),
              )),
            ),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── What is it ──
            _sectionTitle('🤔', '¿Qué es una franquicia Cargo-GO?'),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppTheme.cd,
                border: Border.all(color: AppTheme.bd)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Cargo-GO es la app de envíos locales #1 en Tulancingo. Ahora puedes llevar este modelo probado a TU ciudad.',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85), height: 1.5)),
                const SizedBox(height: 10),
                Text('Tú operas. Tú ganas. Nosotros te damos todo.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.or)),
                const SizedBox(height: 12),
                ...[
                  'No necesitas experiencia en tecnología',
                  'No necesitas local',
                  'No necesitas empleados de inicio',
                  'Solo necesitas ganas de emprender',
                ].map((t) => Padding(padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    const Text('✅ ', style: TextStyle(fontSize: 12)),
                    Expanded(child: Text(t, style: const TextStyle(fontSize: 11, color: AppTheme.tx))),
                  ]))),
              ])),
            const SizedBox(height: 24),

            // ── Paquetes ──
            _sectionTitle('📦', 'Elige tu paquete'),
            const SizedBox(height: 8),

            // Paquete A
            _paqueteCard(
              titulo: 'PAQUETE A',
              subtitulo: '"LLAVE EN MANO"',
              emoji: '🔑',
              precio: '\$150,000 MXN',
              color: const Color(0xFFFFD700),
              popular: true,
              ideal: 'Quiero todo listo, solo operar',
              items: [
                (true, 'Mini moto 125cc equipada'),
                (true, 'Caja térmica con logo'),
                (true, 'Chaleco + casco con branding'),
                (true, 'Celular para repartidor'),
                (true, 'App activada en tu ciudad'),
                (true, 'Panel SUDO completo'),
                (true, 'Capacitación 1 semana'),
                (true, '50 negocios pre-registrados'),
                (true, 'Material de ventas'),
                (true, 'Marketing de lanzamiento'),
                (true, 'Repartidor asignado y capacitado'),
                (true, 'Soporte técnico 24/7'),
              ],
              onSelect: () => _selectPaquete('A'),
            ),
            const SizedBox(height: 16),

            // Paquete B
            _paqueteCard(
              titulo: 'PAQUETE B',
              subtitulo: '"YO PONGO MI MOTO"',
              emoji: '🛵',
              precio: '\$50,000 MXN',
              color: AppTheme.ac,
              popular: false,
              ideal: 'Ya tengo moto y quiero el sistema',
              items: [
                (false, 'Moto NO incluida (tú la pones)'),
                (true, 'Caja térmica con logo'),
                (true, 'Chaleco + casco con branding'),
                (false, 'Celular (tú lo pones)'),
                (true, 'App activada en tu ciudad'),
                (true, 'Panel SUDO completo'),
                (true, 'Capacitación 1 semana'),
                (true, '50 negocios pre-registrados'),
                (true, 'Material de ventas'),
                (true, 'Marketing de lanzamiento'),
                (false, 'Repartidor (tú lo consigues)'),
                (true, 'Soporte técnico 24/7'),
              ],
              onSelect: () => _selectPaquete('B'),
            ),
            const SizedBox(height: 24),

            // ── Regalías ──
            _sectionTitle('💰', 'Regalías'),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [AppTheme.yl.withOpacity(0.08), Colors.transparent]),
                border: Border.all(color: AppTheme.yl.withOpacity(0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Ambos paquetes pagan:', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
                const SizedBox(height: 10),
                _regaliaRow('📌', 'Mínimo mensual:', '\$3,000 MXN'),
                _regaliaRow('📌', 'O el 8% de ingresos brutos', ''),
                _regaliaRow('📌', 'Se cobra LO QUE SEA MAYOR', ''),
                const Divider(color: AppTheme.bd, height: 24),
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppTheme.cd),
                  child: Column(children: [
                    _ejemploRow('Si generas \$60,000/mes', '8% = \$4,800', 'Pagas \$4,800'),
                    const SizedBox(height: 8),
                    _ejemploRow('Si generas \$20,000/mes', '8% = \$1,600', 'Pagas \$3,000 (mínimo)'),
                  ])),
                const SizedBox(height: 10),
                Text('💡 "Empiezas pagando poco y crece conforme tú creces"',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.or)),
              ])),
            const SizedBox(height: 24),

            // ── Simulador ──
            _sectionTitle('📊', 'Simulador de Ganancias'),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppTheme.cd,
                border: Border.all(color: AppTheme.gr.withOpacity(0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sliderRow('¿Cuántos envíos al día?', _enviosDia, 5, 50, (v) => setState(() => _enviosDia = v),
                  '${_enviosDia.round()} envíos'),
                const SizedBox(height: 14),
                _sliderRow('¿Cuántos negocios suscritos?', _negociosSuscritos, 0, 50, (v) => setState(() => _negociosSuscritos = v),
                  '${_negociosSuscritos.round()} negocios'),
                const Divider(color: AppTheme.bd, height: 24),
                _simRow('📦 Envíos:', '${_enviosDia.round()}/día × \$30', '\$${(_enviosDia * 30 * 30).round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} /mes'),
                const SizedBox(height: 6),
                _simRow('🏪 Suscripciones:', '${_negociosSuscritos.round()} negocios', '\$${_calcSuscripciones().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} /mes'),
                const Divider(color: AppTheme.bd, height: 20),
                _simRow('💰 INGRESO TOTAL:', '', '\$${_calcIngresoTotal().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} /mes', bold: true),
                _simRow('📌 Regalía 8%:', '', '-\$${_calcRegalia().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', color: AppTheme.rd),
                _simRow('⛽ Gasolina:', '', '-\$3,000', color: AppTheme.rd),
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(colors: [AppTheme.gr.withOpacity(0.15), AppTheme.gr.withOpacity(0.05)])),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('🤑 TU GANANCIA:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.gr)),
                    Text('\$${_calcGanancia().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} /mes',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.gr)),
                  ])),
                const SizedBox(height: 8),
                Center(child: Text('💡 Recuperas tu inversión en ~${_calcROIMeses()} meses',
                  style: const TextStyle(fontSize: 11, color: AppTheme.yl, fontWeight: FontWeight.w600))),
              ])),
            const SizedBox(height: 24),

            // ── VS Rappi ──
            _sectionTitle('🥊', 'CARGO-GO vs RAPPI'),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppTheme.cd,
                border: Border.all(color: AppTheme.rd.withOpacity(0.3))),
              child: Column(children: [
                const Text('¿Por qué Cargo-GO y no Rappi?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                const SizedBox(height: 12),
                _vsRow('Comisión al negocio', 'Rappi: 26%', '0%'),
                _vsRow('Envío al cliente', 'Rappi: \$35-65', 'desde \$25'),
                _vsRow('¿Opera en pueblos?', 'No', 'Sí'),
                _vsRow('¿Eres dueño?', 'No, eres repartidor', 'Sí, eres el dueño'),
                const Divider(color: AppTheme.bd, height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppTheme.rd.withOpacity(0.1)),
                    child: Text('Ser repartidor Rappi: \$0 pero ganas \$15 por envío sin crecer',
                      style: TextStyle(fontSize: 9, color: AppTheme.rd.withOpacity(0.8))))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppTheme.gr.withOpacity(0.1)),
                    child: Text('Cargo-GO: \$50,000-150,000 pero construyes TU negocio',
                      style: TextStyle(fontSize: 9, color: AppTheme.gr.withOpacity(0.8))))),
                ]),
              ])),
            const SizedBox(height: 24),

            // ── Testimoniales ──
            _sectionTitle('💬', 'Historias de Éxito'),
            _testimonialCard('Carlos', 'Tulancingo',
              'En 2 meses ya tenía 30 negocios y recuperé mi inversión'),
            const SizedBox(height: 10),
            _testimonialCard('Ana', 'Tulancingo',
              'Lo mejor es que no necesité local. Opero todo desde mi celular'),
            const SizedBox(height: 24),

            // ── Mapa de ciudades ──
            _sectionTitle('🗺️', '¿Dónde está Cargo-GO?'),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppTheme.cd,
                border: Border.all(color: AppTheme.bd)),
              child: Column(children: [
                _ciudadRow('🟢', 'Tulancingo', 'ACTIVO', AppTheme.gr),
                _ciudadRow('🟡', 'Pachuca', 'PRÓXIMAMENTE', AppTheme.yl),
                _ciudadRow('⚪', 'Tu ciudad', 'DISPONIBLE', AppTheme.tm),
                const SizedBox(height: 12),
                Text('200+ ciudades disponibles para franquicia',
                  style: TextStyle(fontSize: 11, color: AppTheme.or, fontWeight: FontWeight.w600)),
              ])),
            const SizedBox(height: 24),

            // ── CTA ──
            SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
              onPressed: () => setState(() => _showForm = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.or, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0),
              child: const Text('QUIERO MI FRANQUICIA 🔥', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            )),
            const SizedBox(height: 10),
            Center(child: GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent('Hola, me interesa una franquicia Cargo-GO')}'), mode: LaunchMode.externalApplication),
              child: Text('O escríbenos por WhatsApp 💬', style: TextStyle(fontSize: 12, color: AppTheme.gr, decoration: TextDecoration.underline, decorationColor: AppTheme.gr)))),

            // ── Formulario ──
            if (_showForm) ...[
              const SizedBox(height: 24),
              _contactForm(),
            ],

            const SizedBox(height: 40),
          ]),
        )),
      ]),
    );
  }

  // ═══════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════

  Widget _heroStat(String val, String label) => Column(children: [
    Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
    Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.5))),
  ]);

  Widget _sectionTitle(String emoji, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text('$emoji $title', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)));

  Widget _paqueteCard({required String titulo, required String subtitulo, required String emoji,
    required String precio, required Color color, required bool popular, required String ideal,
    required List<(bool, String)> items, required VoidCallback onSelect}) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [color.withOpacity(0.08), Colors.transparent]),
        border: Border.all(color: color.withOpacity(0.4), width: popular ? 2 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (popular) Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
          child: const Text('⭐ MÁS POPULAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)))),
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
            Text(subtitulo, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
          ]),
        ]),
        const SizedBox(height: 8),
        Text(precio, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        const Divider(color: AppTheme.bd, height: 16),
        ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 5),
          child: Row(children: [
            Text(item.$1 ? '✅ ' : '❌ ', style: const TextStyle(fontSize: 11)),
            Expanded(child: Text(item.$2, style: TextStyle(fontSize: 11, color: item.$1 ? AppTheme.tx : AppTheme.td))),
          ]))),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withOpacity(0.1)),
          child: Row(children: [
            const Text('💡 ', style: TextStyle(fontSize: 11)),
            Expanded(child: Text('IDEAL SI: "$ideal"', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color))),
          ])),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
          onPressed: onSelect,
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: Text('ELEGIR $titulo $emoji', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        )),
      ]));
  }

  Widget _regaliaRow(String emoji, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text('$emoji ', style: const TextStyle(fontSize: 12)),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.tx))),
      if (value.isNotEmpty) Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.yl)),
    ]));

  Widget _ejemploRow(String caso, String calculo, String resultado) => Row(children: [
    Expanded(child: Text(caso, style: const TextStyle(fontSize: 10, color: AppTheme.tm))),
    Text(calculo, style: const TextStyle(fontSize: 10, color: AppTheme.td)),
    const SizedBox(width: 8),
    Text(resultado, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.yl)),
  ]);

  Widget _sliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged, String display) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppTheme.gr.withOpacity(0.15)),
          child: Text(display, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.gr))),
      ]),
      SliderTheme(
        data: SliderThemeData(activeTrackColor: AppTheme.gr, inactiveTrackColor: AppTheme.bd,
          thumbColor: AppTheme.gr, overlayColor: AppTheme.gr.withOpacity(0.1),
          trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
        child: Slider(value: value, min: min, max: max, divisions: (max - min).round(), onChanged: onChanged)),
    ]);
  }

  Widget _simRow(String label, String detail, String value, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          color: color ?? AppTheme.tx)),
        if (detail.isNotEmpty) Text(detail, style: const TextStyle(fontSize: 9, color: AppTheme.td)),
      ])),
      Text(value, style: TextStyle(fontSize: bold ? 14 : 12, fontWeight: FontWeight.w800, color: color ?? AppTheme.tx)),
    ]));

  Widget _vsRow(String concept, String rappi, String cargo) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(concept, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tm)),
      const SizedBox(height: 3),
      Row(children: [
        Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppTheme.rd.withOpacity(0.1)),
          child: Text('❌ $rappi', style: const TextStyle(fontSize: 10, color: AppTheme.rd)))),
        const SizedBox(width: 6),
        Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppTheme.gr.withOpacity(0.1)),
          child: Text('✅ $cargo', style: const TextStyle(fontSize: 10, color: AppTheme.gr)))),
      ]),
    ]));

  Widget _testimonialCard(String nombre, String ciudad, String texto) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppTheme.cd,
      border: Border.all(color: AppTheme.yl.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      Text('"$texto"', style: const TextStyle(fontSize: 12, color: AppTheme.tx, fontStyle: FontStyle.italic, height: 1.4)),
      const SizedBox(height: 6),
      Text('— $nombre, $ciudad', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.tm)),
    ]));

  Widget _ciudadRow(String emoji, String ciudad, String status, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 10),
      Expanded(child: Text(ciudad, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.tx))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.withOpacity(0.15)),
        child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color))),
    ]));

  // ═══════════════════════════════════════════════
  // CONTACT FORM
  // ═══════════════════════════════════════════════

  Widget _contactForm() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppTheme.cd,
      border: Border.all(color: AppTheme.or.withOpacity(0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('📋 SOLICITA TU FRANQUICIA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.or)),
      const SizedBox(height: 14),
      _formField('👤 Tu nombre', _nombreCtrl, 'Nombre completo'),
      _formField('📱 WhatsApp', _whatsappCtrl, '771 123 4567', keyboard: TextInputType.phone),
      _formField('📧 Correo', _correoCtrl, 'tu@correo.com', keyboard: TextInputType.emailAddress),
      _formField('📍 ¿En qué ciudad quieres operar?', _ciudadCtrl, 'Ej: Pachuca, Hidalgo'),
      // Experiencia
      const Text('💼 ¿Tienes experiencia emprendiendo?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.or)),
      const SizedBox(height: 6),
      ...[
        ('si_actual', 'Sí, ya tengo negocio'),
        ('si_antes', 'Sí, pero no actualmente'),
        ('no', 'No, sería mi primera vez'),
      ].map((o) => GestureDetector(
        onTap: () => setState(() => _experiencia = o.$1),
        child: Padding(padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            Icon(_experiencia == o.$1 ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16, color: _experiencia == o.$1 ? AppTheme.or : AppTheme.td),
            const SizedBox(width: 8),
            Text(o.$2, style: TextStyle(fontSize: 11, color: _experiencia == o.$1 ? AppTheme.tx : AppTheme.tm)),
          ])))),
      const SizedBox(height: 10),
      // Moto
      GestureDetector(
        onTap: () => setState(() => _tieneMoto = !_tieneMoto),
        child: Row(children: [
          const Text('🛵 ¿Ya tienes moto o vehículo?  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.or)),
          Icon(_tieneMoto ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: _tieneMoto ? AppTheme.gr : AppTheme.td),
          Text(_tieneMoto ? ' Sí' : ' No', style: TextStyle(fontSize: 11, color: _tieneMoto ? AppTheme.gr : AppTheme.tm)),
        ])),
      const SizedBox(height: 10),
      // Paquete
      const Text('💰 ¿Qué paquete te interesa?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.or)),
      const SizedBox(height: 6),
      ...[
        ('A', '🔑 Paquete A — \$150,000 (todo incluido)'),
        ('B', '🛵 Paquete B — \$50,000 (yo pongo mi moto)'),
        ('no_se', '🤔 No estoy seguro aún'),
      ].map((o) => GestureDetector(
        onTap: () => setState(() => _paqueteSeleccionado = o.$1),
        child: Padding(padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            Icon(_paqueteSeleccionado == o.$1 ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16, color: _paqueteSeleccionado == o.$1 ? AppTheme.or : AppTheme.td),
            const SizedBox(width: 8),
            Expanded(child: Text(o.$2, style: TextStyle(fontSize: 11, color: _paqueteSeleccionado == o.$1 ? AppTheme.tx : AppTheme.tm))),
          ])))),
      const SizedBox(height: 10),
      _formField('💬 ¿Algo más que quieras decirnos?', _comentCtrl, 'Comentarios...', maxLines: 3),
      const SizedBox(height: 4),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: _saving ? null : _enviarSolicitud,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.or, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _saving
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('ENVIAR SOLICITUD 🚀', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
      )),
      const SizedBox(height: 10),
      Center(child: GestureDetector(
        onTap: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent('Hola, quiero info sobre franquicias Cargo-GO')}'), mode: LaunchMode.externalApplication),
        child: const Text('📞 O escríbenos por WhatsApp directo 💬', style: TextStyle(fontSize: 11, color: AppTheme.gr)),
      )),
    ]));

  Widget _formField(String label, TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.or)),
        const SizedBox(height: 4),
        TextField(controller: ctrl, maxLines: maxLines, keyboardType: keyboard,
          style: const TextStyle(color: AppTheme.tx, fontSize: 12),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppTheme.td, fontSize: 11),
            filled: true, fillColor: AppTheme.sf,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.or)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
      ]));
  }

  // ═══════════════════════════════════════════════
  // SUCCESS VIEW
  // ═══════════════════════════════════════════════

  Widget _successView() => Scaffold(
    backgroundColor: AppTheme.bg,
    appBar: AppBar(backgroundColor: AppTheme.sf,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.tm), onPressed: () => Navigator.pop(context))),
    body: Center(child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎉', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        const Text('¡SOLICITUD RECIBIDA!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.tx)),
        const SizedBox(height: 12),
        Text('Gracias ${_nombreCtrl.text.isNotEmpty ? _nombreCtrl.text.split(' ').first : ''}, nos ponemos en contacto contigo en las próximas 24 horas.',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppTheme.tm, height: 1.4)),
        const SizedBox(height: 16),
        const Text('📱 Revisa tu WhatsApp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.gr)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent('Hola, acabo de enviar mi solicitud de franquicia Cargo-GO')}'), mode: LaunchMode.externalApplication),
          icon: const Text('💬', style: TextStyle(fontSize: 16)),
          label: const Text('WhatsApp directo', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        )),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('Volver al inicio', style: TextStyle(color: AppTheme.tm))),
      ]))));

  // ═══════════════════════════════════════════════
  // CALCULATIONS
  // ═══════════════════════════════════════════════

  int _calcSuscripciones() {
    final n = _negociosSuscritos.round();
    if (n == 0) return 0;
    // Distribution: 50% basico, 30% pro, 20% ilimitado
    final basico = (n * 0.5).round();
    final pro = (n * 0.3).round();
    final ilimitado = n - basico - pro;
    return basico * 500 + pro * 1500 + ilimitado * 2500;
  }

  int _calcIngresoTotal() => (_enviosDia * 30 * 30).round() + _calcSuscripciones();

  int _calcRegalia() {
    final total = _calcIngresoTotal();
    final pct = (total * 0.08).round();
    return pct > 3000 ? pct : 3000;
  }

  int _calcGanancia() => _calcIngresoTotal() - _calcRegalia() - 3000;

  int _calcROIMeses() {
    final ganancia = _calcGanancia();
    if (ganancia <= 0) return 99;
    return (150000 / ganancia).ceil();
  }

  // ═══════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════

  void _selectPaquete(String paquete) {
    setState(() {
      _paqueteSeleccionado = paquete;
      _showForm = true;
    });
  }

  Future<void> _enviarSolicitud() async {
    if (_nombreCtrl.text.trim().isEmpty || _whatsappCtrl.text.trim().isEmpty || _ciudadCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Completa nombre, WhatsApp y ciudad', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.rd, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _saving = true);
    await FirestoreService.addDocument('franquicia_solicitudes', {
      'nombre': _nombreCtrl.text.trim(),
      'whatsapp': _whatsappCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'ciudad': _ciudadCtrl.text.trim(),
      'experiencia': _experiencia,
      'tiene_moto': _tieneMoto,
      'paquete': _paqueteSeleccionado ?? 'no_se',
      'comentario': _comentCtrl.text.trim(),
      'status': 'nuevo',
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (!mounted) return;
    // Also send WhatsApp notification
    final msg = '🚀 NUEVA SOLICITUD FRANQUICIA\n'
      'Nombre: ${_nombreCtrl.text.trim()}\n'
      'WhatsApp: ${_whatsappCtrl.text.trim()}\n'
      'Ciudad: ${_ciudadCtrl.text.trim()}\n'
      'Paquete: ${_paqueteSeleccionado ?? 'No definido'}\n'
      'Moto: ${_tieneMoto ? 'Sí' : 'No'}';
    launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
    setState(() { _saving = false; _sent = true; });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _whatsappCtrl.dispose(); _correoCtrl.dispose();
    _ciudadCtrl.dispose(); _comentCtrl.dispose();
    super.dispose();
  }
}
