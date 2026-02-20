/// App-wide constants for Anchored.
class AppConstants {
  AppConstants._();

  // Claim radius in metres — player must be within this distance to anchor a zone.
  static const double claimRadiusMeters = 50.0;

  // Firestore collections
  static const String territoriesCollection = 'territories';
  static const String usersCollection = 'users';

  // CartoDB Dark Matter tile (free, no API key required)
  static const String osmTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
  static const List<String> tileSubdomains = ['a', 'b', 'c', 'd'];

  // Default map center — San Antonio demo location
  static const double defaultLat = 29.5155;
  static const double defaultLng = -98.4558;

  // Default map zoom
  static const double defaultZoom = 13.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;
}
