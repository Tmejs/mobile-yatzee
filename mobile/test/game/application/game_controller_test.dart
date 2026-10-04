import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/application/game_controller.dart';
import 'package:mobile_yatzee/src/game/application/providers.dart';
import 'package:mobile_yatzee/src/game/data/drift_game_repository.dart';
import 'package:mobile_yatzee/src/game/data/game_repository.dart';
import 'package:mobile_yatzee/src/game/domain/completed_game.dart';
import 'package:mobile_yatzee/src/game/rules/ruleset_registry.dart';
import 'package:mobile_yatzee/src/game/session/dice_roller.dart';
import 'package:mobile_yatzee/src/game/session/game_command.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';
import 'package:mobile_yatzee/src/local/app_database.dart';

final class FixedRoller implements DiceRoller {
  const FixedRoller(this.face);
  final int face;
  @override
  List<int> roll(int count) => List.filled(count, face);
}

final class FailOnceRepository implements GameRepository {
  FailOnceRepository(this.inner, {this.fail = true, this.beforeSave});
  final GameRepository inner;
  bool fail;
  final Completer<void>? beforeSave;
  @override
  Future<void> saveActive(GameSession session) async {
    await beforeSave?.future;
    if (fail) {
      fail = false;
      throw StateError('simulated write failure');
    }
    await inner.saveActive(session);
  }

  @override
  Future<GameSession?> loadActive(String gameId) => inner.loadActive(gameId);
  @override
  Stream<List<GameSession>> watchActive() => inner.watchActive();
  @override
  Future<void> complete(GameSession session) => inner.complete(session);
  @override
  Stream<List<CompletedGame>> watchCompleted({String? rulesetId}) =>
      inner.watchCompleted(rulesetId: rulesetId);
  @override
  Future<double?> latestTenSoloAverage({
    required String rulesetId,
    required int rulesetVersion,
  }) => inner.latestTenSoloAverage(
    rulesetId: rulesetId,
    rulesetVersion: rulesetVersion,
  );
}

GameSession initial({GameMode mode = GameMode.solo}) => GameSession.start(
  gameId: 'controller-game',
  rankedIntent: true,
  rulesetId: 'polish-general',
  rulesetVersion: 1,
  mode: mode,
  players: mode == GameMode.solo
      ? [Player(id: 'p1', name: 'Ada')]
      : [Player(id: 'p1', name: 'Ada'), Player(id: 'p2', name: 'Bea')],
);

Map<String, Object?> fields(GameSession game) => {
  'gameId': game.gameId,
  'rankedIntent': game.rankedIntent,
  'rulesetId': game.rulesetId,
  'rulesetVersion': game.rulesetVersion,
  'mode': game.mode,
  'players': [
    for (final p in game.players)
      {
        'id': p.id,
        'name': p.name,
        'scores': p.scoreSheet.scores,
        'bonus': p.scoreSheet.repeatedFiveOfAKindBonusTotal,
      },
  ],
  'activePlayerIndex': game.activePlayerIndex,
  'round': game.round,
  'dice': game.dice,
  'held': game.held,
  'rollCount': game.rollCount,
};

void main() {
  test('each command survives database and controller recreation', () async {
    final directory = await Directory.systemTemp.createTemp('game-controller-');
    final file = File('${directory.path}/game.sqlite');
    AppDatabase? db;
    ProviderContainer? container;
    DriftGameRepository? repository;
    Future<GameController> open(
      GameSession state, {
      bool recover = false,
    }) async {
      db = AppDatabase.forTesting(NativeDatabase(file));
      repository = DriftGameRepository(db!);
      final restored = recover
          ? await repository!.loadActive(state.gameId)
          : state;
      expect(restored, isNotNull);
      if (recover) expect(fields(restored!), fields(state));
      container = ProviderContainer(
        overrides: [
          gameRepositoryProvider.overrideWithValue(repository!),
          initialGameSessionProvider.overrideWithValue(restored!),
          diceRollerProvider.overrideWithValue(const FixedRoller(6)),
        ],
      );
      return container!.read(gameControllerProvider.notifier);
    }

    Future<GameController> restart(GameSession state) async {
      container!.dispose();
      await db!.close();
      return open(state, recover: true);
    }

    try {
      var current = initial(mode: GameMode.passAndPlay);
      var controller = await open(current);
      await controller.apply(const RollDice());
      current = container!.read(gameControllerProvider).requireValue;
      controller = await restart(current);
      await controller.apply(const ToggleHold(0));
      current = container!.read(gameControllerProvider).requireValue;
      expect(current.held.first, true);
      controller = await restart(current);
      await controller.apply(const RollDice());
      current = container!.read(gameControllerProvider).requireValue;
      controller = await restart(current);
      await controller.apply(const RollDice());
      current = container!.read(gameControllerProvider).requireValue;
      expect(current.rollCount, 3);
      controller = await restart(current);
      await controller.apply(
        const SelectCategory('small-straight', confirmZero: true),
      );
      current = container!.read(gameControllerProvider).requireValue;
      expect(current.players.first.scoreSheet.scores['small-straight'], 0);
      expect(current.activePlayerIndex, 1);
      controller = await restart(current);
      await controller.apply(const RollDice());
      await controller.apply(const SelectCategory('ones'));
      current = container!.read(gameControllerProvider).requireValue;
      expect(current.activePlayerIndex, 0);
      expect(current.round, 2);
      await restart(current);
    } finally {
      container?.dispose();
      await db?.close();
      await directory.delete(recursive: true);
    }
  });

  test('completion removes active snapshot and records history', () async {
    final directory = await Directory.systemTemp.createTemp('game-completion-');
    final file = File('${directory.path}/game.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    final repository = DriftGameRepository(db);
    var originalClosed = false;
    final container = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(repository),
        initialGameSessionProvider.overrideWithValue(initial()),
        diceRollerProvider.overrideWithValue(const FixedRoller(6)),
      ],
    );
    try {
      final controller = container.read(gameControllerProvider.notifier);
      for (final category
          in RulesetRegistry().require('polish-general', 1).categories) {
        await controller.apply(const RollDice());
        await controller.apply(SelectCategory(category.id, confirmZero: true));
      }
      final completed = container.read(gameControllerProvider).requireValue;
      expect(completed.isComplete, true);
      expect(await repository.loadActive(completed.gameId), isNull);
      expect(
        (await repository.watchCompleted().first).single.gameId,
        completed.gameId,
      );
      container.dispose();
      await db.close();
      originalClosed = true;
      final reopened = AppDatabase.forTesting(NativeDatabase(file));
      try {
        final recovered = DriftGameRepository(reopened);
        expect(await recovered.loadActive(completed.gameId), isNull);
        final history = (await recovered.watchCompleted().first).single;
        expect(history.gameId, completed.gameId);
        expect(history.rankedIntent, completed.rankedIntent);
        expect(
          history.players.single.scoreSheet.scores,
          completed.players.single.scoreSheet.scores,
        );
        expect(
          history.players.single.totals.finalTotal,
          completed.totalsFor(0).finalTotal,
        );
      } finally {
        await reopened.close();
      }
    } finally {
      container.dispose();
      if (!originalClosed) await db.close();
      await directory.delete(recursive: true);
    }
  });

  test('persistence error retains pending transition for retry', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = FailOnceRepository(DriftGameRepository(db));
    final container = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(repository),
        initialGameSessionProvider.overrideWithValue(initial()),
        diceRollerProvider.overrideWithValue(const FixedRoller(6)),
      ],
    );
    try {
      final controller = container.read(gameControllerProvider.notifier);
      await controller.apply(const RollDice());
      expect(container.read(gameControllerProvider).hasError, true);
      expect(controller.lastPublished.rollCount, 0);
      expect(controller.pending?.rollCount, 1);
      await expectLater(
        controller.apply(const ToggleHold(0)),
        throwsStateError,
      );
      await controller.retryPersistence();
      expect(container.read(gameControllerProvider).requireValue.rollCount, 1);
      expect((await repository.loadActive('controller-game'))?.rollCount, 1);
    } finally {
      container.dispose();
      await db.close();
    }
  });

  test('does not publish a roll until the save has finished', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final gate = Completer<void>();
    final repository = FailOnceRepository(
      DriftGameRepository(db),
      fail: false,
      beforeSave: gate,
    );
    final container = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(repository),
        initialGameSessionProvider.overrideWithValue(initial()),
        diceRollerProvider.overrideWithValue(const FixedRoller(6)),
      ],
    );
    try {
      final controller = container.read(gameControllerProvider.notifier);
      final saving = controller.apply(const RollDice());
      expect(container.read(gameControllerProvider).requireValue.rollCount, 0);
      gate.complete();
      await saving;
      expect(container.read(gameControllerProvider).requireValue.rollCount, 1);
    } finally {
      container.dispose();
      await db.close();
    }
  });
}
