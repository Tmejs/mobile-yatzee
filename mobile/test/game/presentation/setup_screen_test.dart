import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';
import 'package:mobile_yatzee/src/game/presentation/game_setup_screen.dart';

void main() {
  testWidgets('pass-and-play limits setup to two through four named players', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const GameSetupScreen(),
      ),
    );
    await tester.tap(find.byKey(const Key('mode-pass-and-play')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-name-0')), findsOneWidget);
    expect(find.byKey(const Key('player-name-1')), findsOneWidget);
    expect(find.byKey(const Key('remove-player')), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('remove-player')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('add-player')));
    await tester.tap(find.byKey(const Key('add-player')));
    await tester.pump();
    expect(find.byKey(const Key('player-name-3')), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byKey(const Key('add-player'))).onPressed,
      isNull,
    );
  });
}
