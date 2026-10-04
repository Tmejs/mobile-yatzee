import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/rules/ruleset_registry.dart';
import 'package:mobile_yatzee/src/game/session/dice_roller.dart';
import 'package:mobile_yatzee/src/game/session/game_command.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_reducer.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';

final class FixedRoller implements DiceRoller {
  FixedRoller(this.face);
  final int face;
  @override
  List<int> roll(int count) => List.filled(count, face);
}

void main() {
  final reducer = GameReducer();
  final registry = RulesetRegistry();

  for (final (id, count, total, bonus) in [
    ('polish-general', 13, 307, 50),
    ('classic-yahtzee', 13, 380, 35),
    ('scandinavian-yatzy', 15, 289, 50),
  ]) {
    test('completes every $id solo category exactly once', () {
      var game = GameSession.start(
        gameId: 'session-test',
        rulesetId: id,
        rulesetVersion: 1,
        mode: GameMode.solo,
        players: [Player(id: 'solo', name: 'Solo')],
      );
      final categories = registry.require(id, 1).categories;
      expect(categories.length, count);
      for (var turn = 0; turn < count; turn++) {
        expect(game.isComplete, isFalse);
        expect(game.round, turn + 1);
        expect(game.activePlayerIndex, 0);
        expect(game.dice, isNull);
        final category = categories[turn].id;
        final face = category == 'ones'
            ? 1
            : category == 'twos'
            ? 2
            : category == 'threes'
            ? 3
            : category == 'fours'
            ? 4
            : category == 'fives'
            ? 5
            : 6;
        game = reducer.apply(game, const RollDice(), FixedRoller(face));
        game = reducer.apply(
          game,
          SelectCategory(category, confirmZero: true),
          FixedRoller(6),
        );
        expect(game.players.single.scoreSheet.scores.length, turn + 1);
        expect(game.rollCount, 0);
        expect(game.held, [false, false, false, false, false]);
      }
      expect(game.isComplete, isTrue);
      expect(game.round, count);
      expect(game.totalsFor(0).upperSubtotal, 105);
      expect(game.totalsFor(0).upperBonus, bonus);
      expect(game.totalsFor(0).finalTotal, total);
      expect(game.winners.map((winner) => winner.player.id), ['solo']);
      expect(
        () => reducer.apply(game, const RollDice(), FixedRoller(6)),
        throwsStateError,
      );
      expect(
        () => reducer.apply(game, const ToggleHold(0), FixedRoller(6)),
        throwsStateError,
      );
      expect(
        () => reducer.apply(
          game,
          SelectCategory(categories.first.id),
          FixedRoller(6),
        ),
        throwsStateError,
      );
    });
  }

  test('four-player game rotates in order, awards upper bonus, and stably orders ties', () {
    var game = GameSession.start(
      gameId: 'session-test',
      rulesetId: 'polish-general',
      rulesetVersion: 1,
      mode: GameMode.passAndPlay,
      players: [
        for (var i = 0; i < 4; i++) Player(id: 'p$i', name: 'Player $i'),
      ],
    );
    final categories = registry.require('polish-general', 1).categories;
    for (var round = 0; round < categories.length; round++) {
      for (var player = 0; player < 4; player++) {
        expect(game.round, round + 1);
        expect(game.activePlayerIndex, player);
        final category = categories[round].id;
        final face = player == 0 && round < 6
            ? round + 1
            : player < 2
            ? 6
            : 5;
        final before = game;
        game = reducer.apply(game, const RollDice(), FixedRoller(face));
        expect(before.dice, isNull);
        game = reducer.apply(
          game,
          SelectCategory(category, confirmZero: true),
          FixedRoller(face),
        );
        expect(game.players[player].scoreSheet.scores.length, round + 1);
        expect(game.dice, isNull);
      }
    }
    expect(game.isComplete, isTrue);
    expect(game.round, 13);
    expect(
      [for (var i = 0; i < 4; i++) game.totalsFor(i).finalTotal],
      [307, 182, 160, 160],
    );
    expect(game.totalsFor(0).upperBonus, 50);
    expect(game.standings.map((standing) => standing.player.id), [
      'p0',
      'p1',
      'p2',
      'p3',
    ]);
    expect(game.standings.map((standing) => standing.rank), [1, 2, 3, 3]);
    expect(game.winners.map((winner) => winner.player.id), ['p0']);
    expect(
      () => reducer.apply(game, const RollDice(), FixedRoller(6)),
      throwsStateError,
    );
  });

  test(
    'snapshot validation rejects inconsistent turn and aliases mutable input',
    () {
      final players = [Player(id: 'a', name: 'A')];
      final game = GameSession.start(
        gameId: 'session-test',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.solo,
        players: players,
      );
      players.clear();
      expect(game.players.length, 1);
      expect(() => game.held[0] = true, throwsUnsupportedError);
      expect(
        () => GameSession.restore(
          gameId: 'session-test',
          rulesetId: 'polish-general',
          rulesetVersion: 1,
          mode: GameMode.solo,
          players: game.players,
          activePlayerIndex: 0,
          round: 2,
          dice: null,
          held: [false, false, false, false, false],
          rollCount: 0,
        ),
        throwsArgumentError,
      );
    },
  );

  test('two tied finishers remain co-winners in player order', () {
    var game = GameSession.start(
      gameId: 'session-test',
      rulesetId: 'polish-general',
      rulesetVersion: 1,
      mode: GameMode.passAndPlay,
      players: [
        Player(id: 'first', name: 'First'),
        Player(id: 'second', name: 'Second'),
      ],
    );
    for (final category in registry.require('polish-general', 1).categories) {
      for (var player = 0; player < 2; player++) {
        expect(game.activePlayerIndex, player);
        game = reducer.apply(game, const RollDice(), FixedRoller(6));
        game = reducer.apply(
          game,
          SelectCategory(category.id, confirmZero: true),
          FixedRoller(6),
        );
      }
    }
    expect(game.isComplete, isTrue);
    expect(game.winners.map((winner) => winner.player.id), ['first', 'second']);
    expect(game.standings.map((standing) => standing.rank), [1, 1]);
  });

  test('three-player pass-and-play starts with stable order', () {
    final game = GameSession.start(
      gameId: 'session-test',
      rulesetId: 'scandinavian-yatzy',
      rulesetVersion: 1,
      mode: GameMode.passAndPlay,
      players: [
        for (var i = 0; i < 3; i++) Player(id: 'p$i', name: 'Player $i'),
      ],
    );
    expect(game.players.map((player) => player.id), ['p0', 'p1', 'p2']);
    expect(game.activePlayerIndex, 0);
  });
}
