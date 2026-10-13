import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_yatzee/src/app.dart';

void main() {
  testWidgets('uses the supported English device locale', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: MobileYatzeeApp()));
    expect(find.text('New game'), findsOneWidget);
  });

  testWidgets('falls back to Polish for an unsupported device locale', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('de')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: MobileYatzeeApp()));
    expect(find.text('Nowa gra'), findsOneWidget);
  });

  testWidgets('supports an explicitly injected application locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MobileYatzeeApp(locale: Locale('en'))),
    );
    expect(find.text('New game'), findsOneWidget);
  });
}
