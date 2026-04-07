import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anchored/main.dart';
import 'package:anchored/providers/auth_provider.dart';
import 'package:anchored/providers/territory_provider.dart';

void main() {
  testWidgets('App smoke test — renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Force the auth gate path to avoid map tile HTTP requests in tests.
          firebaseAvailableProvider.overrideWith((_) => true),
          authStateProvider.overrideWith((_) => Stream.value(null)),
        ],
        child: const AnchoredApp(),
      ),
    );
    await tester.pumpAndSettle();

    // App should render a Scaffold-based UI regardless of Firebase state.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
