import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

/// Singleton location service instance.
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService.instance,
);

/// Live GPS position stream.
final positionStreamProvider = StreamProvider<Position>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.positionStream();
});

/// Convenience: current LatLng or null.
final currentLatLngProvider = Provider<LatLng?>((ref) {
  final posAsync = ref.watch(positionStreamProvider);
  return posAsync.whenOrNull(
    data: (pos) => LatLng(pos.latitude, pos.longitude),
  );
});
