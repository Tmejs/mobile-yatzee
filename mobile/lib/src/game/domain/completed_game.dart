import '../domain/score_sheet.dart';
import '../session/game_mode.dart';
import '../session/game_session.dart';

final class CompletedPlayer {
  const CompletedPlayer({
    required this.id,
    required this.name,
    required this.scoreSheet,
    required this.totals,
  });

  final String id;
  final String name;
  final ScoreSheet scoreSheet;
  final ScoreTotals totals;
}

final class CompletedGame {
  CompletedGame({
    required this.gameId,
    required this.mode,
    required this.rulesetId,
    required this.rulesetVersion,
    required List<CompletedPlayer> players,
    required this.completedAt,
    required this.rankedIntent,
  }) : players = List.unmodifiable(players);

  factory CompletedGame.fromSession(GameSession session, DateTime completedAt) {
    if (!session.isComplete) throw StateError('Cannot complete an active game');
    return CompletedGame(
      gameId: session.gameId,
      mode: session.mode,
      rulesetId: session.rulesetId,
      rulesetVersion: session.rulesetVersion,
      players: [
        for (var i = 0; i < session.players.length; i++)
          CompletedPlayer(
            id: session.players[i].id,
            name: session.players[i].name,
            scoreSheet: session.players[i].scoreSheet,
            totals: session.totalsFor(i),
          ),
      ],
      completedAt: completedAt.toUtc(),
      rankedIntent: session.rankedIntent,
    );
  }

  final String gameId;
  final GameMode mode;
  final String rulesetId;
  final int rulesetVersion;
  final List<CompletedPlayer> players;
  final DateTime completedAt;
  final bool rankedIntent;
}
