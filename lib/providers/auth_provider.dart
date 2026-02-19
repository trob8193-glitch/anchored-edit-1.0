import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'territory_provider.dart';

/// Singleton auth service.
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);

/// Emits the current [AppUser] or null.
/// When Firebase is unavailable, emits null immediately without throwing.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final firebaseReady = ref.watch(firebaseAvailableProvider);
  if (!firebaseReady) {
    // Offline mode: emit null once; _AuthGate routes to MapScreen directly.
    return Stream.value(null);
  }
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges.map((_) => service.appUser);
});
