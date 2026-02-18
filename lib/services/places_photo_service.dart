/// Servicio de fotos para negocios usando Google Maps Static API.
/// Genera URLs de vista satelital con la ubicación real del negocio.
class PlacesPhotoService {
  static const _key = 'AIzaSyD37YdGfyW3DFpQl6v48mLfGrjBds78iOI';

  /// Genera URL de foto satelital para un negocio con coordenadas.
  static String satelliteUrl(double lat, double lng, {int zoom = 18, int width = 600, int height = 300}) =>
      'https://maps.googleapis.com/maps/api/staticmap'
      '?center=$lat,$lng&zoom=$zoom&size=${width}x$height&scale=2'
      '&maptype=satellite&markers=color:red%7C$lat,$lng&key=$_key';

  /// Genera URL de foto real de Google Places usando photo_reference.
  static String placePhotoUrl(String photoReference, {int maxWidth = 400}) =>
      'https://maps.googleapis.com/maps/api/place/photo'
      '?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_key';

  /// Genera URL de Street View por nombre y zona del negocio.
  /// fov=120 da una vista amplia de la fachada completa sin acercarse demasiado.
  static String streetViewUrl(String nombre, String zona, {int width = 600, int height = 400, int fov = 120}) {
    final query = Uri.encodeComponent('$nombre, $zona');
    return 'https://maps.googleapis.com/maps/api/streetview'
        '?size=${width}x$height&location=$query&fov=$fov&source=outdoor&key=$_key';
  }

  /// Genera URL de mapa estilizado (dark mode) para un negocio.
  static String mapUrl(double lat, double lng, {int zoom = 16, int width = 600, int height = 300}) =>
      'https://maps.googleapis.com/maps/api/staticmap'
      '?center=$lat,$lng&zoom=$zoom&size=${width}x$height&scale=2'
      '&maptype=roadmap&markers=color:red%7C$lat,$lng'
      '&style=feature:all%7Celement:geometry%7Ccolor:0x1a1a2e'
      '&style=feature:road%7Celement:geometry%7Ccolor:0x2a2a4a'
      '&style=feature:water%7Celement:geometry%7Ccolor:0x0a0a1e'
      '&style=feature:all%7Celement:labels.text.fill%7Ccolor:0x8899b4'
      '&style=feature:all%7Celement:labels.text.stroke%7Ccolor:0x060b18'
      '&key=$_key';
}
