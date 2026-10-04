import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/data/drift_game_repository.dart';
import 'package:mobile_yatzee/src/game/rules/ruleset_registry.dart';
import 'package:mobile_yatzee/src/game/session/dice_roller.dart';
import 'package:mobile_yatzee/src/game/session/game_command.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_reducer.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';
import 'package:mobile_yatzee/src/local/app_database.dart';
import 'package:mobile_yatzee/src/local/game_snapshot_codec.dart';

final class FixedRoller implements DiceRoller {
  const FixedRoller(this.face);
  final int face;
  @override
  List<int> roll(int count) => List.filled(count, face);
}

GameSession game(
  String id, {
  String ruleset = 'polish-general',
  bool ranked = false,
  GameMode mode = GameMode.solo,
}) => GameSession.start(
  gameId: id,
  rankedIntent: ranked,
  rulesetId: ruleset,
  rulesetVersion: 1,
  mode: mode,
  players: mode == GameMode.solo
      ? [Player(id: 'p1', name: 'Ada')]
      : [Player(id: 'p1', name: 'Ada'), Player(id: 'p2', name: 'Bea')],
);

GameSession finish(GameSession session, {int face = 6}) {
  final reducer = GameReducer();
  final categories = RulesetRegistry().require(session.rulesetId, 1).categories;
  var current = session;
  while (!current.isComplete) {
    current = reducer.apply(current, const RollDice(), FixedRoller(face));
    final category = categories[current.round - 1].id;
    current = reducer.apply(
      current,
      SelectCategory(category, confirmZero: true),
      const FixedRoller(6),
    );
  }
  return current;
}

void main() {
  late AppDatabase db;
  late DriftGameRepository repository;
  final completedAt = DateTime.utc(2026, 10, 4, 12);
  late DateTime now;
  setUp(() {
    now = completedAt;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftGameRepository(
      db,
      codec: GameSnapshotCodec(),
      clock: () => now,
    );
  });
  tearDown(() async => db.close());

  test('upserts active snapshot by game ID and watches changes', () async {
    final initial = game('g1', ranked: true);
    await repository.saveActive(initial);
    final rolled = GameReducer().apply(
      initial,
      const RollDice(),
      const FixedRoller(6),
    );
    await repository.saveActive(rolled);
    expect((await repository.watchActive().first).map((s) => s.gameId), ['g1']);
    final loaded = await repository.loadActive('g1');
    expect(loaded?.gameId, 'g1');
    expect(loaded?.rankedIntent, true);
    expect(loaded?.dice, [6, 6, 6, 6, 6]);
    expect(loaded?.rollCount, 1);
    expect(await repository.loadActive('missing'), isNull);
  });

  test(
    'completion stores immutable result and deletes active row atomically',
    () async {
      final finished = finish(game('g1', ranked: true));
      await repository.saveActive(game('g1', ranked: true));
      await repository.complete(finished);
      expect(await repository.loadActive('g1'), isNull);
      final result = (await repository.watchCompleted().first).single;
      expect(result.gameId, 'g1');
      expect(result.mode, GameMode.solo);
      expect(result.rulesetId, 'polish-general');
      expect(result.rulesetVersion, 1);
      expect(result.rankedIntent, true);
      expect(result.completedAt, completedAt);
      expect(result.players.single.id, 'p1');
      expect(result.players.single.name, 'Ada');
      expect(result.players.single.scoreSheet.scores.length, 13);
      expect(
        result.players.single.totals.finalTotal,
        finished.totalsFor(0).finalTotal,
      );
      await expectLater(repository.complete(finished), throwsStateError);
      expect((await repository.watchCompleted().first).length, 1);
      await expectLater(repository.saveActive(game('g1')), throwsStateError);
      expect(await repository.loadActive('g1'), isNull);
    },
  );

  test(
    'rejects premature completion without deleting the active game',
    () async {
      final initial = game('g1');
      await repository.saveActive(initial);
      await expectLater(repository.complete(initial), throwsStateError);
      expect((await repository.loadActive('g1'))?.gameId, 'g1');
      expect(await repository.watchCompleted().first, isEmpty);
    },
  );

  test(
    'history order and ruleset filter use stable newest-first ordering',
    () async {
      for (final (id, ruleset) in [
        ('b', 'polish-general'),
        ('a', 'polish-general'),
        ('c', 'classic-yahtzee'),
      ]) {
        await repository.complete(finish(game(id, ruleset: ruleset)));
      }
      expect((await repository.watchCompleted().first).map((g) => g.gameId), [
        'a',
        'b',
        'c',
      ]);
      expect(
        (await repository.watchCompleted(rulesetId: 'polish-general').first)
            .map((g) => g.gameId),
        ['a', 'b'],
      );
    },
  );

  test(
    'latest ten solo average excludes older and pass-and-play games',
    () async {
      expect(
        await repository.latestTenSoloAverage(
          rulesetId: 'polish-general',
          rulesetVersion: 1,
        ),
        isNull,
      );
      for (var i = 0; i < 11; i++) {
        now = completedAt.add(Duration(seconds: i));
        await repository.complete(
          finish(
            game('solo-${i.toString().padLeft(2, '0')}', ranked: i.isEven),
            face: i == 0 ? 1 : 6,
          ),
        );
      }
      await repository.complete(
        finish(game('pass', mode: GameMode.passAndPlay)),
      );
      await repository.complete(
        finish(game('other', ruleset: 'classic-yahtzee')),
      );
      final expected = finish(game('expected'))
          .totalsFor(0)
          .finalTotal
          .toDouble();
      expect(
        await repository.latestTenSoloAverage(
          rulesetId: 'polish-general',
          rulesetVersion: 1,
        ),
        expected,
      );
    },
  );
}
