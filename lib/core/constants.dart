/// App-wide constants for Anchored.
class AppConstants {
  AppConstants._();

  // Claim radius in metres — player must be within this distance to anchor a zone.
  static const double claimRadiusMeters = 50.0;

  // Firestore collections
  static const String territoriesCollection = 'territories';
  static const String usersCollection = 'users';

  // OSM tile template (no API key required)
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Default map zoom
  static const double defaultZoom = 15.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;
}
