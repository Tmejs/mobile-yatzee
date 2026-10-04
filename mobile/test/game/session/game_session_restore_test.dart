import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/domain/score_sheet.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';

void main() {
  GameSession restore(
    String rulesetId,
    Map<String, int> scores, {
    int bonus = 0,
  }) {
    return GameSession.restore(
      rulesetId: rulesetId,
      rulesetVersion: 1,
      mode: GameMode.solo,
      players: [
        Player(
          id: 'p1',
          name: 'Ada',
          scoreSheet: ScoreSheet(
            scores: scores,
            repeatedFiveOfAKindBonusTotal: bonus,
          ),
        ),
      ],
      activePlayerIndex: 0,
      round: scores.length + 1,
      dice: null,
      held: const [false, false, false, false, false],
      rollCount: 0,
    );
  }

  test('rejects recorded scores no roll can produce in each ruleset', () {
    for (final (ruleset, scores) in [
      ('polish-general', {'ones': 999}),
      ('polish-general', {'three-kind': 999}),
      ('classic-yahtzee', {'chance': 0}),
      ('classic-yahtzee', {'full-house': 26}),
      ('scandinavian-yatzy', {'one-pair': 13}),
      ('scandinavian-yatzy', {'yatzy': 51}),
    ]) {
      expect(
        () => restore(ruleset, scores),
        throwsArgumentError,
        reason: '$ruleset $scores',
      );
    }
  });

  test('rejects repeat bonus in rulesets without repeat awards', () {
    for (final ruleset in ['polish-general', 'scandinavian-yatzy']) {
      expect(
        () => restore(ruleset, {'ones': 0}, bonus: 100),
        throwsArgumentError,
      );
    }
  });

  test('Classic repeat bonus requires whole 100-point awards', () {
    expect(
      () => restore('classic-yahtzee', {'yahtzee': 50, 'sixes': 30}, bonus: 50),
      throwsArgumentError,
    );
  });

  test('Classic repeat bonus requires Yahtzee scored 50', () {
    expect(
      () => restore('classic-yahtzee', {'ones': 0, 'twos': 0}, bonus: 100),
      throwsArgumentError,
    );
    expect(
      () => restore('classic-yahtzee', {'yahtzee': 0, 'twos': 0}, bonus: 100),
      throwsArgumentError,
    );
  });

  test('Classic repeat bonus cannot exceed other filled turns', () {
    expect(
      () =>
          restore('classic-yahtzee', {'yahtzee': 50, 'sixes': 30}, bonus: 200),
      throwsArgumentError,
    );
  });

  test('preserves valid in-progress score and repeat award', () {
    final game = restore('classic-yahtzee', {
      'yahtzee': 50,
      'sixes': 30,
    }, bonus: 100);
    expect(game.round, 3);
    expect(game.totalsFor(0).finalTotal, 180);
  });
}
