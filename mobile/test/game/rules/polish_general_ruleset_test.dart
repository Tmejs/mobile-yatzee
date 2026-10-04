import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/domain/dice.dart';
import 'package:mobile_yatzee/src/game/domain/score_sheet.dart';
import 'package:mobile_yatzee/src/game/rules/polish_general_ruleset.dart';

import '../../support/conformance_fixture.dart';

void main() {
  final rules = PolishGeneralRuleset();

  test('rejects invalid dice length and faces', () {
    for (final values in <List<int>>[
      [1, 2, 3, 4],
      [1, 2, 3, 4, 5, 6],
      [0, 1, 2, 3, 4],
      [1, 2, 3, 4, 7],
    ]) {
      expect(() => DiceRoll(values), throwsArgumentError);
    }
  });

  test('dice cannot be changed after validation', () {
    final input = [1, 1, 2, 3, 4];
    final roll = DiceRoll(input);
    input[0] = 6;
    expect(roll.values, [1, 1, 2, 3, 4]);
    expect(() => roll.values[0] = 6, throwsUnsupportedError);
    expect(roll.counts[1], 2);
    expect(roll.sum, 11);
  });

  test('all shared Polish General conformance cases', () {
    final fixture = loadConformanceFixture('polish-general-v1.json');
    expect(fixture.ruleset, rules.id);
    expect(fixture.version, rules.version);
    for (final testCase in fixture.cases) {
      final sheet = ScoreSheet(
        scores: testCase.priorScores,
        repeatedFiveOfAKindBonusTotal: testCase.priorBonus,
      );
      final evaluation = rules.evaluate(
        testCase.category,
        DiceRoll(testCase.dice),
        sheet,
      );
      expect(evaluation.selectable, testCase.selectable, reason: testCase.name);
      expect(evaluation.qualifies, testCase.valid, reason: testCase.name);
      expect(evaluation.score, testCase.score, reason: testCase.name);
      expect(evaluation.bonusDelta, testCase.bonusDelta, reason: testCase.name);
      final totals = rules.totals(
        sheet.withScore(
          testCase.category,
          evaluation.score,
          bonusDelta: evaluation.bonusDelta,
        ),
      );
      expect(
        totals.upperSubtotal,
        testCase.expectedTotals['upperSubtotal'],
        reason: testCase.name,
      );
      expect(
        totals.upperBonus,
        testCase.expectedTotals['upperBonus'],
        reason: testCase.name,
      );
      expect(
        totals.lowerSubtotal,
        testCase.expectedTotals['lowerSubtotal'],
        reason: testCase.name,
      );
      expect(
        totals.repeatedFiveOfAKindBonusTotal,
        testCase.expectedTotals['repeatedFiveOfAKindBonusTotal'],
        reason: testCase.name,
      );
      expect(
        totals.finalTotal,
        testCase.expectedTotals['finalTotal'],
        reason: testCase.name,
      );
    }
  });

  test('required scoring examples', () {
    int score(List<int> dice, String category) =>
        rules.evaluate(category, DiceRoll(dice), ScoreSheet()).score;
    expect(score([6, 6, 6, 6, 2], 'three-kind'), 18);
    expect(score([6, 6, 6, 6, 6], 'four-kind'), 24);
    expect(score([1, 2, 3, 4, 5], 'small-straight'), 15);
    expect(score([2, 3, 4, 5, 6], 'large-straight'), 20);
    expect(score([6, 6, 6, 6, 6], 'general'), 80);
  });

  test('used and unknown categories cannot be evaluated', () {
    expect(
      () => rules.evaluate(
        'chance',
        DiceRoll([1, 2, 3, 4, 5]),
        ScoreSheet(scores: {'chance': 0}),
      ),
      throwsStateError,
    );
    expect(
      () => rules.evaluate('unknown', DiceRoll([1, 2, 3, 4, 5]), ScoreSheet()),
      throwsArgumentError,
    );
  });
}
