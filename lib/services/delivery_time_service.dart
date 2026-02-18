/// Calcula tiempos estimados de entrega
class DeliveryTimeService {
  /// Zonas con tiempos de tránsito en minutos
  static const _zoneTime = <String, int>{
    'centro': 5,
    'colonias': 10,
    'orilla': 15,
  };

  /// Tiempo estimado total = prep + pickup + zone
  static ({int min, int max}) calcular({
    int prepMin = 10,
    int prepMax = 20,
    String zona = 'colonias',
  }) {
    final zoneMin = _zoneTime[zona] ?? 10;
    return (
      min: prepMin + 5 + zoneMin,   // pickup mínimo 5 min
      max: prepMax + 10 + zoneMin,  // pickup máximo 10 min
    );
  }

  /// Formatea como "25-35 min"
  static String formatear({
    int prepMin = 10,
    int prepMax = 20,
    String zona = 'colonias',
  }) {
    final t = calcular(prepMin: prepMin, prepMax: prepMax, zona: zona);
    return '${t.min}-${t.max} min';
  }

  /// Detectar zona por dirección simple
  static String detectarZona(String direccion) {
    final d = direccion.toLowerCase();
    if (d.contains('centro') || d.contains('hidalgo') || d.contains('21 de marzo')) {
      return 'centro';
    }
    if (d.contains('orilla') || d.contains('santiago') || d.contains('jaltepec')) {
      return 'orilla';
    }
    return 'colonias';
  }
}
