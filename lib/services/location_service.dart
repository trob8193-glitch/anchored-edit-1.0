import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Handles GPS permission, position streaming, and distance calculations.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  StreamSubscription<Position>? _subscription;
  Position? _lastPosition;

  Position? get lastPosition => _lastPosition;

  LatLng? get latLng => _lastPosition == null
      ? null
      : LatLng(_lastPosition!.latitude, _lastPosition!.longitude);

  /// Request location permissions.
  /// Returns true if permission is granted.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Subscribe to live position updates.
  Stream<Position> positionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // metres before emitting a new update
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Returns distance in metres between current position and [target].
  double distanceTo(LatLng target) {
    if (_lastPosition == null) return double.infinity;
    return Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      target.latitude,
      target.longitude,
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
