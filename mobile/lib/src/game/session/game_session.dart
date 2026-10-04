import '../domain/dice.dart';
import '../domain/score_sheet.dart';
import '../rules/ruleset_registry.dart';
import '../rules/score_sheet_validator.dart';
import 'game_mode.dart';
import 'player.dart';

final class GameStanding {
  const GameStanding({
    required this.playerIndex,
    required this.player,
    required this.totals,
    required this.rank,
  });
  final int playerIndex;
  final Player player;
  final ScoreTotals totals;
  final int rank;
}

final class GameSession {
  GameSession._({
    required this.rulesetId,
    required this.rulesetVersion,
    required this.mode,
    required List<Player> players,
    required this.activePlayerIndex,
    required this.round,
    required List<int>? dice,
    required List<bool> held,
    required this.rollCount,
  }) : players = List.unmodifiable(players),
       dice = dice == null ? null : List.unmodifiable(dice),
       held = List.unmodifiable(held);

  factory GameSession.start({
    required String rulesetId,
    required int rulesetVersion,
    required GameMode mode,
    required List<Player> players,
  }) => GameSession.restore(
    rulesetId: rulesetId,
    rulesetVersion: rulesetVersion,
    mode: mode,
    players: players,
    activePlayerIndex: 0,
    round: 1,
    dice: null,
    held: const [false, false, false, false, false],
    rollCount: 0,
  );

  /// Rebuilds and validates a versioned snapshot without carrying services in state.
  factory GameSession.restore({
    required String rulesetId,
    required int rulesetVersion,
    required GameMode mode,
    required List<Player> players,
    required int activePlayerIndex,
    required int round,
    required List<int>? dice,
    required List<bool> held,
    required int rollCount,
  }) {
    final ruleset = RulesetRegistry().require(rulesetId, rulesetVersion);
    final count = players.length;
    if ((mode == GameMode.solo && count != 1) ||
        (mode == GameMode.passAndPlay && (count < 2 || count > 4))) {
      throw ArgumentError('Invalid player count for mode');
    }
    if (players.map((player) => player.id).toSet().length != count) {
      throw ArgumentError('Player IDs must be unique');
    }
    final categories = ruleset.categories
        .map((category) => category.id)
        .toSet();
    if (players.any(
      (player) =>
          player.scoreSheet.scores.keys.any((id) => !categories.contains(id)),
    )) {
      throw ArgumentError('Score sheet contains an unknown category');
    }
    if (players.any(
      (player) => !ScoreSheetValidator.accepts(ruleset, player.scoreSheet),
    )) {
      throw ArgumentError('Score sheet has an impossible score or bonus');
    }
    if (activePlayerIndex < 0 ||
        activePlayerIndex >= count ||
        round < 1 ||
        round > categories.length ||
        held.length != 5 ||
        rollCount < 0 ||
        rollCount > 3 ||
        (rollCount == 0 && (dice != null || held.contains(true))) ||
        (rollCount > 0 && dice == null)) {
      throw ArgumentError('Invalid turn state');
    }
    if (dice != null) DiceRoll(dice);
    final complete = players.every(
      (player) => player.scoreSheet.scores.length == categories.length,
    );
    if (complete) {
      if (activePlayerIndex != 0 ||
          round != categories.length ||
          rollCount != 0) {
        throw ArgumentError('Invalid completed-game state');
      }
    } else {
      for (var index = 0; index < count; index++) {
        final expected = round - 1 + (index < activePlayerIndex ? 1 : 0);
        if (players[index].scoreSheet.scores.length != expected) {
          throw ArgumentError('Score sheets do not match turn order');
        }
      }
    }
    return GameSession._(
      rulesetId: rulesetId,
      rulesetVersion: rulesetVersion,
      mode: mode,
      players: players,
      activePlayerIndex: activePlayerIndex,
      round: round,
      dice: dice,
      held: held,
      rollCount: rollCount,
    );
  }

  final String rulesetId;
  final int rulesetVersion;
  final GameMode mode;
  final List<Player> players;
  final int activePlayerIndex;
  final int round;
  final List<int>? dice;
  final List<bool> held;
  final int rollCount;

  bool get isComplete {
    final categoryCount = RulesetRegistry()
        .require(rulesetId, rulesetVersion)
        .categories
        .length;
    return players.every(
      (player) => player.scoreSheet.scores.length == categoryCount,
    );
  }

  ScoreTotals totalsFor(int playerIndex) => RulesetRegistry()
      .require(rulesetId, rulesetVersion)
      .totals(players[playerIndex].scoreSheet);

  /// Higher totals lead; tied totals keep the original player order and share a rank.
  List<GameStanding> get standings {
    final indexes = [for (var i = 0; i < players.length; i++) i]
      ..sort((a, b) {
        final byScore = totalsFor(b).finalTotal
            .compareTo(totalsFor(a).finalTotal);
        return byScore != 0 ? byScore : a.compareTo(b);
      });
    return List.unmodifiable([
      for (var position = 0; position < indexes.length; position++)
        GameStanding(
          playerIndex: indexes[position],
          player: players[indexes[position]],
          totals: totalsFor(indexes[position]),
          rank: position == 0
              ? 1
              : 1 +
                    indexes
                        .take(position)
                        .where(
                          (index) =>
                              totalsFor(index).finalTotal >
                              totalsFor(indexes[position]).finalTotal,
                        )
                        .length,
        ),
    ]);
  }

  List<GameStanding> get winners => isComplete
      ? List.unmodifiable(standings.where((standing) => standing.rank == 1))
      : const [];
}
