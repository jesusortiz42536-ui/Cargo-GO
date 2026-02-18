import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});
  @override State<OnboardingScreen> createState() => _OnboardingState();

  /// Checks if onboarding was already shown
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_done') ?? false);
  }
}

class _OnboardingState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🚚',
      title: 'Pide lo que quieras',
      subtitle: 'Comida, farmacia, tienda, mandados...\ntodo llega a tu puerta',
      color: Color(0xFF00C853),
    ),
    _OnboardingPage(
      emoji: '🕐',
      title: 'Rápido y seguro',
      subtitle: 'Envío desde \$25\nRastreo en tiempo real',
      color: Color(0xFF2962FF),
    ),
    _OnboardingPage(
      emoji: '🏪',
      title: '¿Tienes un negocio?',
      subtitle: 'Regístrate GRATIS y vende\nsin local, sin rentas, sin comisiones',
      color: Color(0xFFFF6D00),
    ),
  ];

  void _next() {
    if (_page < 2) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _complete();
    }
  }

  void _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView.builder(
          controller: _pageCtrl,
          itemCount: 3,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) {
            final p = _pages[i];
            return Container(
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [p.color.withOpacity(0.15), const Color(0xFF060B18)])),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(p.emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 30),
                  Text(p.title, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text(p.subtitle, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7), height: 1.5)),
                ]))),
            );
          }),
        // Skip button
        Positioned(top: 50, right: 20, child: SafeArea(child: TextButton(
          onPressed: _complete,
          child: const Text('Saltar', style: TextStyle(color: Colors.white54, fontSize: 13))))),
        // Bottom
        Positioned(left: 0, right: 0, bottom: 40, child: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(children: [
            // Dots
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) =>
              Container(width: _page == i ? 24 : 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                  color: _page == i ? _pages[_page].color : Colors.white24)))),
            const SizedBox(height: 24),
            // Button
            SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pages[_page].color, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0),
              child: Text(_page == 2 ? 'EMPEZAR 🚀' : 'Siguiente',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            )),
          ])))),
      ]),
    );
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }
}

class _OnboardingPage {
  final String emoji, title, subtitle;
  final Color color;
  const _OnboardingPage({required this.emoji, required this.title, required this.subtitle, required this.color});
}
