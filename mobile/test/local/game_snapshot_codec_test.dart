import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/domain/score_sheet.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';
import 'package:mobile_yatzee/src/local/game_snapshot_codec.dart';

void main() {
  final codec = GameSnapshotCodec();

  test(
    'round trip retains every restorable field and isolated player data',
    () {
      final original = GameSession.restore(
        gameId: 'game-1',
        rankedIntent: true,
        rulesetId: 'classic-yahtzee',
        rulesetVersion: 1,
        mode: GameMode.passAndPlay,
        players: [
          Player(
            id: 'p1',
            name: 'Ada',
            scoreSheet: ScoreSheet(
              scores: {'yahtzee': 50, 'sixes': 30},
              repeatedFiveOfAKindBonusTotal: 100,
            ),
          ),
          Player(
            id: 'p2',
            name: 'Bea',
            scoreSheet: ScoreSheet(scores: {'chance': 22, 'ones': 2}),
          ),
        ],
        activePlayerIndex: 0,
        round: 3,
        dice: [6, 6, 3, 2, 1],
        held: [true, true, false, false, false],
        rollCount: 3,
      );
      final encoded = codec.encode(original);
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      expect(json['snapshotVersion'], 1);
      final restored = codec.decode(encoded);
      expect(restored.gameId, 'game-1');
      expect(restored.rankedIntent, true);
      expect(restored.rulesetId, 'classic-yahtzee');
      expect(restored.rulesetVersion, 1);
      expect(restored.mode, GameMode.passAndPlay);
      expect(restored.players.map((p) => [p.id, p.name]), [
        ['p1', 'Ada'],
        ['p2', 'Bea'],
      ]);
      expect(restored.players[0].scoreSheet.scores, {
        'yahtzee': 50,
        'sixes': 30,
      });
      expect(restored.players[0].scoreSheet.repeatedFiveOfAKindBonusTotal, 100);
      expect(restored.players[1].scoreSheet.scores, {'chance': 22, 'ones': 2});
      expect(restored.players[1].scoreSheet.repeatedFiveOfAKindBonusTotal, 0);
      expect(restored.activePlayerIndex, 0);
      expect(restored.round, 3);
      expect(restored.dice, [6, 6, 3, 2, 1]);
      expect(restored.held, [true, true, false, false, false]);
      expect(restored.rollCount, 3);
    },
  );

  test('rejects unknown snapshot version and malformed state', () {
    final valid = codec.encode(
      GameSession.start(
        gameId: 'game-1',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.solo,
        players: [Player(id: 'p1', name: 'Ada')],
      ),
    );
    final json = jsonDecode(valid) as Map<String, dynamic>;
    expect(
      () => codec.decode(jsonEncode({...json, 'snapshotVersion': 2})),
      throwsUnsupportedError,
    );
    expect(
      () => codec.decode(
        jsonEncode({
          ...json,
          'held': [true, false, false, false, false],
        }),
      ),
      throwsArgumentError,
    );
    expect(
      () => codec.decode(jsonEncode({...json, 'players': []})),
      throwsArgumentError,
    );
    expect(() => codec.decode('{broken'), throwsFormatException);
  });

  test('requires a nonblank immutable game identifier', () {
    expect(
      () => GameSession.start(
        gameId: '   ',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.solo,
        players: [Player(id: 'p1', name: 'Ada')],
      ),
      throwsArgumentError,
    );
  });
}
