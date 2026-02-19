import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/territory_provider.dart';
import 'screens/auth_screen.dart';
import 'services/location_service.dart';
import 'widgets/main_nav_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialise Firebase — if credentials are placeholder / missing
  // the app continues in offline / local-demo mode.
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('[Anchored] Firebase unavailable — running in offline mode. $e');
  }

  // Request GPS permission early so the stream never errors silently.
  await LocationService.instance.requestPermission();

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWith((_) => firebaseReady),
      ],
      child: const AnchoredApp(),
    ),
  );
}

class AnchoredApp extends StatelessWidget {
  const AnchoredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchored',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

/// Routes to [AuthScreen] or [MapScreen] based on auth state.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentLatLngProvider); // warm up location stream
    final firebaseReady = ref.watch(firebaseAvailableProvider);
    final authAsync = ref.watch(authStateProvider);

    // When Firebase is unavailable skip the auth screen and go straight
    // to the map in offline / demo mode.
    if (!firebaseReady) return const MainNavShell();

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const AuthScreen(),
      data: (user) => user != null ? const MainNavShell() : const AuthScreen(),
    );
  }
}
