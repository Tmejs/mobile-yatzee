import '../domain/dice.dart';
import '../rules/ruleset_registry.dart';
import 'dice_roller.dart';
import 'game_command.dart';
import 'game_session.dart';

final class GameReducer {
  GameReducer({RulesetRegistry? registry})
    : _registry = registry ?? RulesetRegistry();
  final RulesetRegistry _registry;

  GameSession apply(GameSession state, GameCommand command, DiceRoller roller) {
    if (state.isComplete) throw StateError('Game is complete');
    final ruleset = _registry.require(state.rulesetId, state.rulesetVersion);
    var players = state.players;
    var active = state.activePlayerIndex;
    var round = state.round;
    var dice = state.dice;
    var held = state.held;
    var rollCount = state.rollCount;

    switch (command) {
      case RollDice():
        if (rollCount >= 3) throw StateError('No rolls remaining');
        final indexes = [
          for (var i = 0; i < 5; i++)
            if (!held[i]) i,
        ];
        final rolled = roller.roll(indexes.length);
        if (rolled.length != indexes.length ||
            rolled.any((face) => face < 1 || face > 6)) {
          throw ArgumentError(
            'Roller must return one valid face per unheld die',
          );
        }
        final next = dice == null ? List<int>.filled(5, 0) : [...dice];
        for (var i = 0; i < indexes.length; i++) {
          next[indexes[i]] = rolled[i];
        }
        dice = next;
        rollCount++;
      case ToggleHold(:final index):
        if (rollCount == 0) throw StateError('Roll before holding dice');
        if (index < 0 || index >= 5) throw RangeError.index(index, held);
        held = [...held]..[index] = !held[index];
      case SelectCategory(:final category, :final confirmZero):
        if (rollCount == 0 || dice == null) {
          throw StateError('Roll before scoring');
        }
        if (!ruleset.categories.any(
          (definition) => definition.id == category,
        )) {
          throw ArgumentError.value(category, 'category', 'Unknown category');
        }
        final player = players[active];
        if (player.scoreSheet.scores.containsKey(category)) {
          throw StateError('Category already used');
        }
        final evaluation = ruleset.evaluate(
          category,
          DiceRoll(dice),
          player.scoreSheet,
        );
        if (!evaluation.selectable) {
          throw StateError('Category cannot be selected for this roll');
        }
        if (!evaluation.qualifies && evaluation.score == 0 && !confirmZero) {
          throw StateError('Confirm zero score');
        }
        players = [...players];
        players[active] = player.withScoreSheet(
          player.scoreSheet.withScore(
            category,
            evaluation.score,
            bonusDelta: evaluation.bonusDelta,
          ),
        );
        dice = null;
        held = const [false, false, false, false, false];
        rollCount = 0;
        final complete = players.every(
          (candidate) =>
              candidate.scoreSheet.scores.length == ruleset.categories.length,
        );
        if (complete) {
          active = 0;
        } else if (active == players.length - 1) {
          active = 0;
          round++;
        } else {
          active++;
        }
    }
    return GameSession.restore(
      rulesetId: state.rulesetId,
      rulesetVersion: state.rulesetVersion,
      mode: state.mode,
      players: players,
      activePlayerIndex: active,
      round: round,
      dice: dice,
      held: held,
      rollCount: rollCount,
    );
  }
}
