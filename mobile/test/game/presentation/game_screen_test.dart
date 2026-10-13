import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';
import 'package:mobile_yatzee/src/game/application/providers.dart';
import 'package:mobile_yatzee/src/game/data/game_repository.dart';
import 'package:mobile_yatzee/src/game/domain/completed_game.dart';
import 'package:mobile_yatzee/src/game/domain/score_sheet.dart';
import 'package:mobile_yatzee/src/game/presentation/game_screen.dart';
import 'package:mobile_yatzee/src/game/session/dice_roller.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_command.dart';
import 'package:mobile_yatzee/src/game/session/game_reducer.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';

final class _MemoryRepository implements GameRepository {
  bool failNext = false;
  GameSession? saved;

  @override
  Future<void> saveActive(GameSession session) async {
    if (failNext) {
      failNext = false;
      throw StateError('offline');
    }
    saved = session;
  }

  @override
  Future<void> complete(GameSession session) async => saved = session;
  @override
  Future<GameSession?> loadActive(String gameId) async => saved;
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

final class _SequenceRoller implements DiceRoller {
  _SequenceRoller(this.faces);
  final List<int> faces;
  @override
  List<int> roll(int count) => faces.take(count).toList();
}

final class _BlockingRepository extends _MemoryRepository {
  final gate = Completer<void>();
  @override
  Future<void> saveActive(GameSession session) async {
    await gate.future;
    await super.saveActive(session);
  }
}

GameSession _session({int players = 2}) => GameSession.start(
  gameId: 'ui-game',
  rulesetId: 'polish-general',
  rulesetVersion: 1,
  mode: players == 1 ? GameMode.solo : GameMode.passAndPlay,
  players: [
    for (var i = 0; i < players; i++)
      Player(id: 'p$i', name: 'Bardzo długie imię gracza ${i + 1}'),
  ],
);

Future<void> _pumpGame(
  WidgetTester tester, {
  Locale locale = const Locale('pl'),
  int players = 2,
  _MemoryRepository? repository,
  GameSession? session,
  List<int> dice = const [6, 6, 6, 6, 6],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialGameSessionProvider.overrideWithValue(
          session ?? _session(players: players),
        ),
        gameRepositoryProvider.overrideWithValue(
          repository ?? _MemoryRepository(),
        ),
        diceRollerProvider.overrideWithValue(_SequenceRoller(dice)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const GameScreen(),
      ),
    ),
  );
}

GameSession _classicForcedPlacementSession() => GameSession.restore(
  gameId: 'classic-preview',
  rulesetId: 'classic-yahtzee',
  rulesetVersion: 1,
  mode: GameMode.solo,
  players: [
    Player(
      id: 'p0',
      name: 'Ada',
      scoreSheet: ScoreSheet(scores: const {'yahtzee': 50}),
    ),
  ],
  activePlayerIndex: 0,
  round: 2,
  dice: null,
  held: const [false, false, false, false, false],
  rollCount: 0,
);

GameSession _completedSession() {
  var game = _session(players: 1);
  final reducer = GameReducer();
  final roller = _SequenceRoller(const [6, 6, 6, 6, 6]);
  for (final category in [
    'ones',
    'twos',
    'threes',
    'fours',
    'fives',
    'sixes',
    'three-kind',
    'four-kind',
    'full-house',
    'small-straight',
    'large-straight',
    'general',
    'chance',
  ]) {
    game = reducer.apply(game, const RollDice(), roller);
    game = reducer.apply(
      game,
      SelectCategory(category, confirmZero: true),
      roller,
    );
  }
  return game;
}

void main() {
  testWidgets('shows Polish and English game actions', (tester) async {
    await _pumpGame(tester);
    expect(find.text('Rzuć kośćmi'), findsOneWidget);

    await _pumpGame(tester, locale: const Locale('en'));
    expect(find.text('Roll dice'), findsOneWidget);
  });

  testWidgets('shows all four score columns and marks the active one', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpGame(tester, players: 4);

    for (var index = 0; index < 4; index++) {
      expect(find.byKey(Key('player-column-p$index')), findsWidgets);
    }
    final semantics = tester.getSemantics(
      find.byKey(const Key('player-column-p0')).first,
    );
    expect(semantics.label, contains('aktywny gracz'));
    final active = tester.widget<Container>(
      find.byKey(const Key('player-column-p0')).first,
    );
    expect(active.color, const Color(0x33C99A2E));
  });

  testWidgets('dice announce face and held state and stop after three rolls', (
    tester,
  ) async {
    await _pumpGame(tester);
    final roll = find.byKey(const Key('roll-dice'));
    await tester.tap(roll);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const Key('die-0'))).label,
      contains('6'),
    );

    await tester.tap(find.byKey(const Key('die-0')));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const Key('die-0'))).label,
      contains('zatrzymana'),
    );
    await tester.tap(roll);
    await tester.pumpAndSettle();
    await tester.tap(roll);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(roll).onPressed, isNull);
  });

  testWidgets(
    'shows projected scores only for the active player after a roll',
    (tester) async {
      await _pumpGame(tester);

      await tester.tap(find.byKey(const Key('roll-dice')));
      await tester.pumpAndSettle();

      final positive = find.byKey(const Key('score-sixes-p0-value'));
      final zero = find.byKey(const Key('score-ones-p0-value'));
      final inactive = find.byKey(const Key('score-sixes-p1-value'));
      expect(
        find.descendant(of: positive, matching: find.text('30')),
        findsOne,
      );
      expect(find.descendant(of: zero, matching: find.text('0')), findsOne);
      expect(find.descendant(of: inactive, matching: find.text('—')), findsOne);
      expect(
        tester.getSemantics(find.byKey(const Key('score-sixes-p0'))).label,
        allOf(contains('Dostępne: 30 pkt'), contains('aktywny gracz')),
      );
      expect(
        tester.getSemantics(find.byKey(const Key('score-sixes-p1'))).label,
        allOf(contains('brak wyniku'), contains('gracz nieaktywny')),
      );
    },
  );

  testWidgets('announces English score availability and active state', (
    tester,
  ) async {
    await _pumpGame(tester, locale: const Locale('en'));

    await tester.tap(find.byKey(const Key('roll-dice')));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(const Key('score-sixes-p0'))).label,
      allOf(contains('30 points available'), contains('active player')),
    );
  });

  testWidgets('marks recorded and forced-placement cells without color alone', (
    tester,
  ) async {
    await _pumpGame(tester, session: _classicForcedPlacementSession());

    await tester.tap(find.byKey(const Key('roll-dice')));
    await tester.pumpAndSettle();

    final recorded = find.byKey(const Key('score-yahtzee-p0-value'));
    final available = find.byKey(const Key('score-sixes-p0-value'));
    final unavailable = find.byKey(const Key('score-chance-p0-value'));
    expect(find.descendant(of: recorded, matching: find.text('50')), findsOne);
    expect(find.descendant(of: available, matching: find.text('30')), findsOne);
    expect(
      find.descendant(of: unavailable, matching: find.text('0')),
      findsOne,
    );
    expect(
      find.descendant(of: recorded, matching: find.byIcon(Icons.check)),
      findsOne,
    );
    expect(
      find.descendant(
        of: available,
        matching: find.byIcon(Icons.add_circle_outline),
      ),
      findsOne,
    );
    expect(
      find.descendant(of: unavailable, matching: find.byIcon(Icons.block)),
      findsOne,
    );
    expect(
      tester.getSemantics(find.byKey(const Key('score-yahtzee-p0'))).label,
      contains('Zapisano: 50 pkt'),
    );
    expect(
      tester.getSemantics(find.byKey(const Key('score-chance-p0'))).label,
      contains('Niedostępne: 0 pkt'),
    );
  });

  testWidgets(
    'requires confirmation before recording zero and cancel is inert',
    (tester) async {
      await _pumpGame(tester);
      await tester.tap(find.byKey(const Key('roll-dice')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('score-small-straight')));
      await tester.tap(find.byKey(const Key('score-small-straight')));
      await tester.pumpAndSettle();
      expect(find.text('Wpisać 0 punktów?'), findsOneWidget);
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(find.text('Wpisać 0 punktów?'), findsNothing);
      final scoreValue = find.byKey(const Key('score-small-straight-p0-value'));
      expect(
        find.descendant(of: scoreValue, matching: find.text('0')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('score-small-straight')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wpisz 0'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: scoreValue, matching: find.text('0')),
        findsOneWidget,
      );
    },
  );

  testWidgets('also confirms a zero in an upper category', (tester) async {
    await _pumpGame(tester);
    await tester.tap(find.byKey(const Key('roll-dice')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('score-ones')));
    await tester.pumpAndSettle();
    expect(find.text('Wpisać 0 punktów?'), findsOneWidget);
  });

  testWidgets('persistence error keeps state and exposes retry', (
    tester,
  ) async {
    final repository = _MemoryRepository()..failNext = true;
    await _pumpGame(tester, repository: repository);
    await tester.tap(find.byKey(const Key('roll-dice')));
    await tester.pumpAndSettle();
    expect(find.text('Nie udało się zapisać gry.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('retry-persistence')));
    await tester.pumpAndSettle();
    expect(find.text('Nie udało się zapisać gry.'), findsNothing);
    expect(repository.saved?.rollCount, 1);
  });

  testWidgets('a failed later save leaves retry as the only action', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    await _pumpGame(tester, repository: repository);
    final roll = find.byKey(const Key('roll-dice'));
    await tester.tap(roll);
    await tester.pumpAndSettle();
    repository.failNext = true;
    await tester.tap(roll);
    await tester.pumpAndSettle();

    expect(find.text('Nie udało się zapisać gry.'), findsOneWidget);
    expect(tester.widget<FilledButton>(roll).onPressed, isNull);
    expect(
      tester.widget<InkWell>(find.byKey(const Key('die-0'))).onTap,
      isNull,
    );
    expect(
      tester.widget<TextButton>(find.byKey(const Key('score-ones'))).onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('retry-persistence')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(roll).onPressed, isNotNull);
    expect(
      tester.widget<InkWell>(find.byKey(const Key('die-0'))).onTap,
      isNotNull,
    );
    expect(
      tester.widget<TextButton>(find.byKey(const Key('score-ones'))).onPressed,
      isNotNull,
    );
  });

  testWidgets('announces a completed game', (tester) async {
    await _pumpGame(tester, session: _completedSession());
    expect(find.text('Gra zakończona'), findsOneWidget);
    final player = find.byKey(const Key('player-column-p0')).first;
    expect(tester.getSemantics(player).label, isNot(contains('aktywny gracz')));
    expect(tester.widget<Container>(player).color, Colors.transparent);
  });

  testWidgets('disables commands while a save is pending', (tester) async {
    final repository = _BlockingRepository();
    await _pumpGame(tester, repository: repository);
    final roll = find.byKey(const Key('roll-dice'));
    await tester.tap(roll);
    await tester.pump();
    expect(tester.widget<FilledButton>(roll).onPressed, isNull);
    expect(find.byKey(const Key('persistence-progress')), findsOneWidget);
    repository.gate.complete();
    await tester.pumpAndSettle();
  });
}
