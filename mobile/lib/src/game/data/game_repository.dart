import '../domain/completed_game.dart';
import '../session/game_session.dart';

abstract interface class GameRepository {
  Future<void> saveActive(GameSession session);
  Future<GameSession?> loadActive(String gameId);
  Stream<List<GameSession>> watchActive();
  Future<void> complete(GameSession session);
  Stream<List<CompletedGame>> watchCompleted({String? rulesetId});

  /// Newest ten local solo results for one ruleset version; null if empty.
  Future<double?> latestTenSoloAverage({
    required String rulesetId,
    required int rulesetVersion,
  });
}
