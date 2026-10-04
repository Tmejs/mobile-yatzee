import 'dart:convert';

import '../game/domain/score_sheet.dart';
import '../game/session/game_mode.dart';
import '../game/session/game_session.dart';
import '../game/session/player.dart';

final class GameSnapshotCodec {
  static const snapshotVersion = 1;

  String encode(GameSession session) => jsonEncode({
    'snapshotVersion': snapshotVersion,
    'gameId': session.gameId,
    'rankedIntent': session.rankedIntent,
    'rulesetId': session.rulesetId,
    'rulesetVersion': session.rulesetVersion,
    'mode': session.mode.name,
    'players': [
      for (final player in session.players)
        {
          'id': player.id,
          'name': player.name,
          'scores': player.scoreSheet.scores,
          'repeatedFiveOfAKindBonusTotal':
              player.scoreSheet.repeatedFiveOfAKindBonusTotal,
        },
    ],
    'activePlayerIndex': session.activePlayerIndex,
    'round': session.round,
    'rollCount': session.rollCount,
    'dice': session.dice,
    'held': session.held,
  });

  GameSession decode(String snapshot) {
    final object = jsonDecode(snapshot);
    if (object is! Map<String, dynamic>) {
      throw const FormatException('Snapshot must be an object');
    }
    if (object['snapshotVersion'] != snapshotVersion) {
      throw UnsupportedError('Unsupported snapshot version');
    }
    try {
      final playersJson = object['players'] as List<dynamic>;
      return GameSession.restore(
        gameId: object['gameId'] as String,
        rankedIntent: object['rankedIntent'] as bool,
        rulesetId: object['rulesetId'] as String,
        rulesetVersion: object['rulesetVersion'] as int,
        mode: GameMode.values.byName(object['mode'] as String),
        players: [
          for (final item in playersJson)
            Player(
              id: (item as Map<String, dynamic>)['id'] as String,
              name: item['name'] as String,
              scoreSheet: ScoreSheet(
                scores: Map<String, int>.from(item['scores'] as Map),
                repeatedFiveOfAKindBonusTotal:
                    item['repeatedFiveOfAKindBonusTotal'] as int,
              ),
            ),
        ],
        activePlayerIndex: object['activePlayerIndex'] as int,
        round: object['round'] as int,
        dice: (object['dice'] as List<dynamic>?)?.cast<int>(),
        held: (object['held'] as List<dynamic>).cast<bool>(),
        rollCount: object['rollCount'] as int,
      );
    } on TypeError catch (error) {
      throw FormatException('Malformed snapshot: $error');
    }
  }
}
