import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/session/dice_roller.dart';
import 'package:mobile_yatzee/src/game/session/game_command.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_reducer.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';

final class QueueRoller implements DiceRoller {
  QueueRoller(this.values);
  final List<int> values;
  @override
  List<int> roll(int count) => [
    for (var i = 0; i < count; i++) values.removeAt(0),
  ];
}

void main() {
  final reducer = GameReducer();
  GameSession solo({String ruleset = 'polish-general'}) => GameSession.start(
    gameId: 'session-test',
    rulesetId: ruleset,
    rulesetVersion: 1,
    mode: GameMode.solo,
    players: [Player(id: 'p1', name: 'Ada')],
  );

  test('validates mode, identities, and ruleset', () {
    expect(
      () => GameSession.start(
        gameId: 'session-test',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.solo,
        players: [],
      ),
      throwsArgumentError,
    );
    expect(
      () => GameSession.start(
        gameId: 'session-test',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.passAndPlay,
        players: [Player(id: 'a', name: 'A')],
      ),
      throwsArgumentError,
    );
    expect(
      () => GameSession.start(
        gameId: 'session-test',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.passAndPlay,
        players: [for (var i = 0; i < 5; i++) Player(id: '$i', name: '$i')],
      ),
      throwsArgumentError,
    );
    expect(
      () => GameSession.start(
        gameId: 'session-test',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.passAndPlay,
        players: [
          Player(id: 'a', name: 'A'),
          Player(id: 'a', name: 'B'),
        ],
      ),
      throwsArgumentError,
    );
    expect(() => solo(ruleset: 'unknown'), throwsUnsupportedError);
  });

  test('rolls five dice, preserves holds, and rejects fourth roll', () {
    final original = solo();
    expect(
      () => reducer.apply(original, const ToggleHold(0), QueueRoller([])),
      throwsStateError,
    );
    final roller = QueueRoller([1, 2, 3, 4, 5, 6, 6, 6, 6, 2, 2, 2, 2]);
    var game = reducer.apply(original, const RollDice(), roller);
    expect(original.dice, isNull);
    expect(game.dice, [1, 2, 3, 4, 5]);
    expect(
      () => reducer.apply(game, const ToggleHold(-1), roller),
      throwsRangeError,
    );
    expect(
      () => reducer.apply(game, const ToggleHold(5), roller),
      throwsRangeError,
    );
    game = reducer.apply(game, const ToggleHold(0), roller);
    game = reducer.apply(game, const RollDice(), roller);
    expect(game.dice, [1, 6, 6, 6, 6]);
    game = reducer.apply(game, const RollDice(), roller);
    expect(game.dice, [1, 2, 2, 2, 2]);
    expect(game.rollCount, 3);
    expect(
      () => reducer.apply(game, const RollDice(), roller),
      throwsStateError,
    );
    expect(roller.values, isEmpty);
  });

  test('rejects bad roller output without changing input', () {
    final game = solo();
    expect(
      () => reducer.apply(game, const RollDice(), QueueRoller([0, 2, 3, 4, 5])),
      throwsArgumentError,
    );
    expect(game.rollCount, 0);
  });

  test('selection validates roll and category and resets turn', () {
    var game = solo();
    expect(
      () => reducer.apply(game, const SelectCategory('ones'), QueueRoller([])),
      throwsStateError,
    );
    game = reducer.apply(game, const RollDice(), QueueRoller([1, 1, 1, 1, 1]));
    expect(
      () => reducer.apply(game, const SelectCategory('bogus'), QueueRoller([])),
      throwsArgumentError,
    );
    game = reducer.apply(game, const SelectCategory('ones'), QueueRoller([]));
    expect(game.players.single.scoreSheet.scores['ones'], 5);
    expect(game.dice, isNull);
    expect(game.held, [false, false, false, false, false]);
    expect(game.rollCount, 0);
    expect(game.round, 2);
    game = reducer.apply(game, const RollDice(), QueueRoller([1, 1, 1, 1, 1]));
    expect(
      () => reducer.apply(game, const SelectCategory('ones'), QueueRoller([])),
      throwsStateError,
    );
  });

  test('nonqualifying zero needs confirmation; upper zero does not', () {
    var game = reducer.apply(
      solo(),
      const RollDice(),
      QueueRoller([1, 2, 3, 4, 5]),
    );
    expect(
      () =>
          reducer.apply(game, const SelectCategory('general'), QueueRoller([])),
      throwsStateError,
    );
    game = reducer.apply(
      game,
      const SelectCategory('general', confirmZero: true),
      QueueRoller([]),
    );
    expect(game.players.single.scoreSheet.scores['general'], 0);
    game = reducer.apply(game, const RollDice(), QueueRoller([1, 1, 1, 1, 1]));
    game = reducer.apply(game, const SelectCategory('sixes'), QueueRoller([]));
    expect(game.players.single.scoreSheet.scores['sixes'], 0);
  });

  test('repeat Yahtzee placement obeys selectable policy and bonus delta', () {
    var game = solo(ruleset: 'classic-yahtzee');
    game = reducer.apply(game, const RollDice(), QueueRoller([6, 6, 6, 6, 6]));
    game = reducer.apply(
      game,
      const SelectCategory('yahtzee'),
      QueueRoller([]),
    );
    game = reducer.apply(game, const RollDice(), QueueRoller([6, 6, 6, 6, 6]));
    expect(
      () =>
          reducer.apply(game, const SelectCategory('chance'), QueueRoller([])),
      throwsStateError,
    );
    game = reducer.apply(game, const SelectCategory('sixes'), QueueRoller([]));
    expect(game.players.single.scoreSheet.repeatedFiveOfAKindBonusTotal, 100);
    expect(game.players.single.scoreSheet.scores['sixes'], 30);
    expect(game.totalsFor(0).finalTotal, 180);
  });
}
