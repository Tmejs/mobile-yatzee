import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';
import 'package:mobile_yatzee/src/game/application/providers.dart';
import 'package:mobile_yatzee/src/game/data/game_repository.dart';
import 'package:mobile_yatzee/src/game/domain/completed_game.dart';
import 'package:mobile_yatzee/src/game/presentation/game_screen.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';
import 'package:mobile_yatzee/src/theme/modern_tabletop_theme.dart';

final class _NoopRepository implements GameRepository {
  @override
  Future<void> saveActive(GameSession session) async {}
  @override
  Future<void> complete(GameSession session) async {}
  @override
  Future<GameSession?> loadActive(String gameId) async => null;
  @override
  Stream<List<GameSession>> watchActive() => const Stream.empty();
  @override
  Stream<List<CompletedGame>> watchCompleted({String? rulesetId}) =>
      const Stream.empty();
  @override
  Future<double?> latestTenSoloAverage({
    required String rulesetId,
    required int rulesetVersion,
  }) async => null;
}

GameSession _session(int count) => GameSession.start(
  gameId: 'golden-$count',
  rulesetId: 'polish-general',
  rulesetVersion: 1,
  mode: count == 1 ? GameMode.solo : GameMode.passAndPlay,
  players: [
    for (var i = 0; i < count; i++)
      Player(
        id: 'p$i',
        name: i == 0 ? 'Aleksandra' : 'Gracz o długim imieniu ${i + 1}',
      ),
  ],
);

const _longPlayerNames = [
  'Aleksandra Kowalska-Zawadzka',
  'Konstanty Maksymilian Wiśniewski',
  'Małgorzata Krystyna Nowakowska',
  'Bartłomiej Zieliński-Piotrowski',
];

GameSession _fourLongNameSession() => GameSession.start(
  gameId: 'golden-four-long',
  rulesetId: 'polish-general',
  rulesetVersion: 1,
  mode: GameMode.passAndPlay,
  players: [
    for (var index = 0; index < _longPlayerNames.length; index++)
      Player(id: 'p$index', name: _longPlayerNames[index]),
  ],
);

Future<void> _golden(
  WidgetTester tester, {
  required String name,
  required int players,
  required Locale locale,
  Size size = const Size(390, 844),
  double scale = 1,
  bool fourLongNames = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialGameSessionProvider.overrideWithValue(
          fourLongNames ? _fourLongNameSession() : _session(players),
        ),
        gameRepositoryProvider.overrideWithValue(_NoopRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: modernTabletopTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const GameScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  if (fourLongNames) {
    for (var index = 0; index < 4; index++) {
      final player = find.byKey(Key('player-column-p$index'));
      expect(player, findsWidgets);
      expect(
        tester.getSemantics(player.first).label,
        index == 0
            ? 'active player: ${_longPlayerNames[index]}'
            : _longPlayerNames[index],
      );
    }
  }
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('baselines/$name.png'),
  );
}

void main() {
  testWidgets(
    'solo Polish portrait',
    (tester) => _golden(
      tester,
      name: 'solo-pl',
      players: 1,
      locale: const Locale('pl'),
    ),
  );
  testWidgets(
    'two-player English portrait',
    (tester) => _golden(
      tester,
      name: 'two-player-en',
      players: 2,
      locale: const Locale('en'),
    ),
  );
  testWidgets(
    'four-player Polish portrait',
    (tester) => _golden(
      tester,
      name: 'four-player-pl',
      players: 4,
      locale: const Locale('pl'),
    ),
  );
  testWidgets(
    'English solo portrait',
    (tester) => _golden(
      tester,
      name: 'solo-en',
      players: 1,
      locale: const Locale('en'),
    ),
  );
  testWidgets(
    'large text constrained portrait',
    (tester) => _golden(
      tester,
      name: 'two-player-large-text',
      players: 2,
      locale: const Locale('pl'),
      size: const Size(320, 700),
      scale: 2,
    ),
  );
  testWidgets(
    'four long names at large text on constrained portrait',
    (tester) => _golden(
      tester,
      name: 'four-player-long-names-large-text',
      players: 4,
      locale: const Locale('en'),
      size: const Size(360, 780),
      scale: 2,
      fourLongNames: true,
    ),
  );
}
