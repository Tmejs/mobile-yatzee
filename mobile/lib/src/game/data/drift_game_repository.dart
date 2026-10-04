import 'dart:convert';

import 'package:drift/drift.dart';

import '../../local/app_database.dart';
import '../../local/game_snapshot_codec.dart';
import '../domain/completed_game.dart';
import '../domain/score_sheet.dart';
import '../session/game_mode.dart';
import '../session/game_session.dart';
import 'game_repository.dart';

final class DriftGameRepository implements GameRepository {
  DriftGameRepository(
    this._db, {
    GameSnapshotCodec? codec,
    DateTime Function()? clock,
  }) : _codec = codec ?? GameSnapshotCodec(),
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final GameSnapshotCodec _codec;
  final DateTime Function() _clock;

  @override
  Future<void> saveActive(GameSession session) async {
    if (session.isComplete) {
      throw StateError('Completed games belong in history');
    }
    await _db.transaction(() async {
      final completed = await (_db.select(
        _db.completedGames,
      )..where((row) => row.gameId.equals(session.gameId))).getSingleOrNull();
      if (completed != null) throw StateError('Game already completed');
      await _db
          .into(_db.activeGames)
          .insertOnConflictUpdate(
            ActiveGamesCompanion.insert(
              gameId: session.gameId,
              snapshotJson: _codec.encode(session),
              updatedAt: _clock().toUtc(),
            ),
          );
    });
  }

  @override
  Future<GameSession?> loadActive(String gameId) async {
    final query = _db.select(_db.activeGames)
      ..where((row) => row.gameId.equals(gameId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _codec.decode(row.snapshotJson);
  }

  @override
  Stream<List<GameSession>> watchActive() {
    final query = _db.select(_db.activeGames)
      ..orderBy([(row) => OrderingTerm.asc(row.gameId)]);
    return query.watch().map(
      (rows) =>
          List.unmodifiable(rows.map((row) => _codec.decode(row.snapshotJson))),
    );
  }

  @override
  Future<void> complete(GameSession session) async {
    if (!session.isComplete) throw StateError('Game is not complete');
    final result = CompletedGame.fromSession(session, _clock().toUtc());
    await _db.transaction(() async {
      final existing = await (_db.select(
        _db.completedGames,
      )..where((row) => row.gameId.equals(session.gameId))).getSingleOrNull();
      if (existing != null) throw StateError('Game already completed');
      await _db
          .into(_db.completedGames)
          .insert(
            CompletedGamesCompanion.insert(
              gameId: result.gameId,
              mode: result.mode.name,
              rulesetId: result.rulesetId,
              rulesetVersion: result.rulesetVersion,
              rankedIntent: result.rankedIntent,
              completedAt: result.completedAt,
              playersJson: _playersJson(result.players),
            ),
          );
      await (_db.delete(
        _db.activeGames,
      )..where((row) => row.gameId.equals(session.gameId))).go();
    });
  }

  @override
  Stream<List<CompletedGame>> watchCompleted({String? rulesetId}) {
    final query = _db.select(_db.completedGames);
    if (rulesetId != null) {
      query.where((row) => row.rulesetId.equals(rulesetId));
    }
    query.orderBy([
      (row) => OrderingTerm.desc(row.completedAt),
      (row) => OrderingTerm.asc(row.gameId),
    ]);
    return query.watch().map(
      (rows) => List.unmodifiable(rows.map(_decodeCompleted)),
    );
  }

  @override
  Future<double?> latestTenSoloAverage({
    required String rulesetId,
    required int rulesetVersion,
  }) async {
    final query = _db.select(_db.completedGames)
      ..where(
        (row) =>
            row.rulesetId.equals(rulesetId) &
            row.rulesetVersion.equals(rulesetVersion) &
            row.mode.equals(GameMode.solo.name),
      )
      ..orderBy([
        (row) => OrderingTerm.desc(row.completedAt),
        (row) => OrderingTerm.asc(row.gameId),
      ])
      ..limit(10);
    final games = await query.get();
    if (games.isEmpty) return null;
    final total = games
        .map(_decodeCompleted)
        .fold<int>(
          0,
          (sum, game) => sum + game.players.single.totals.finalTotal,
        );
    return total / games.length;
  }

  String _playersJson(List<CompletedPlayer> players) => jsonEncode([
    for (final player in players)
      {
        'id': player.id,
        'name': player.name,
        'scores': player.scoreSheet.scores,
        'repeatedFiveOfAKindBonusTotal':
            player.scoreSheet.repeatedFiveOfAKindBonusTotal,
        'totals': {
          'upperSubtotal': player.totals.upperSubtotal,
          'upperBonus': player.totals.upperBonus,
          'lowerSubtotal': player.totals.lowerSubtotal,
          'repeatedFiveOfAKindBonusTotal':
              player.totals.repeatedFiveOfAKindBonusTotal,
          'finalTotal': player.totals.finalTotal,
        },
      },
  ]);

  CompletedGame _decodeCompleted(CompletedGameRow row) {
    final playersJson = jsonDecode(row.playersJson) as List<dynamic>;
    return CompletedGame(
      gameId: row.gameId,
      mode: GameMode.values.byName(row.mode),
      rulesetId: row.rulesetId,
      rulesetVersion: row.rulesetVersion,
      rankedIntent: row.rankedIntent,
      completedAt: row.completedAt.toUtc(),
      players: [
        for (final value in playersJson)
          _decodePlayer(value as Map<String, dynamic>),
      ],
    );
  }

  CompletedPlayer _decodePlayer(Map<String, dynamic> value) {
    final totals = value['totals'] as Map<String, dynamic>;
    return CompletedPlayer(
      id: value['id'] as String,
      name: value['name'] as String,
      scoreSheet: ScoreSheet(
        scores: Map<String, int>.from(value['scores'] as Map),
        repeatedFiveOfAKindBonusTotal:
            value['repeatedFiveOfAKindBonusTotal'] as int,
      ),
      totals: ScoreTotals(
        upperSubtotal: totals['upperSubtotal'] as int,
        upperBonus: totals['upperBonus'] as int,
        lowerSubtotal: totals['lowerSubtotal'] as int,
        repeatedFiveOfAKindBonusTotal:
            totals['repeatedFiveOfAKindBonusTotal'] as int,
        finalTotal: totals['finalTotal'] as int,
      ),
    );
  }
}
