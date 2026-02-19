import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anchored/main.dart';

void main() {
  testWidgets('App smoke test — renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AnchoredApp()),
    );
    // App should render a Scaffold-based UI regardless of Firebase state.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
