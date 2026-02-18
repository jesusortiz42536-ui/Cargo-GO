/// Roles de la aplicación
enum AppRole { cliente, negocio, sudo }

/// Estados del pedido
enum OrderStatus {
  nuevo,
  aceptado,
  preparando,
  listo,
  en_camino,
  entregado,
  cancelado;

  String get label => switch (this) {
    nuevo => 'Nuevo',
    aceptado => 'Aceptado',
    preparando => 'Preparando',
    listo => 'Listo',
    en_camino => 'En Camino',
    entregado => 'Entregado',
    cancelado => 'Cancelado',
  };

  String get emoji => switch (this) {
    nuevo => '🆕',
    aceptado => '✅',
    preparando => '👨‍🍳',
    listo => '📦',
    en_camino => '🚗',
    entregado => '🏠',
    cancelado => '❌',
  };

  bool get isActive => this != entregado && this != cancelado;

  static OrderStatus fromString(String s) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => OrderStatus.nuevo,
    );
  }
}

/// Sesión del usuario activo
class UserSession {
  final AppRole role;
  final String? negocioId;
  final String? negocioNombre;
  final String? telefono;
  final String? nombre;

  const UserSession({
    required this.role,
    this.negocioId,
    this.negocioNombre,
    this.telefono,
    this.nombre,
  });

  bool get isNegocio => role == AppRole.negocio;
  bool get isSudo => role == AppRole.sudo;
  bool get isCliente => role == AppRole.cliente;

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'negocioId': negocioId,
    'negocioNombre': negocioNombre,
    'telefono': telefono,
    'nombre': nombre,
  };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    role: AppRole.values.firstWhere((e) => e.name == json['role'], orElse: () => AppRole.cliente),
    negocioId: json['negocioId'],
    negocioNombre: json['negocioNombre'],
    telefono: json['telefono'],
    nombre: json['nombre'],
  );

  factory UserSession.cliente() => const UserSession(role: AppRole.cliente);
}

/// Producto de un negocio
class NegocioProducto {
  final String id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? categoria;
  final String? fotoUrl;
  final bool disponible;

  const NegocioProducto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.categoria,
    this.fotoUrl,
    this.disponible = true,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'categoria': categoria,
    'foto_url': fotoUrl,
    'disponible': disponible,
  };

  factory NegocioProducto.fromJson(String id, Map<String, dynamic> json) => NegocioProducto(
    id: id,
    nombre: json['nombre'] ?? '',
    descripcion: json['descripcion'],
    precio: (json['precio'] ?? 0).toDouble(),
    categoria: json['categoria'],
    fotoUrl: json['foto_url'],
    disponible: json['disponible'] ?? true,
  );
}
