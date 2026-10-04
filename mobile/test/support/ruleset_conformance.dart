import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/domain/dice.dart';
import 'package:mobile_yatzee/src/game/domain/score_sheet.dart';
import 'package:mobile_yatzee/src/game/rules/ruleset.dart';

import 'conformance_fixture.dart';

void expectRulesetConformance(Ruleset rules, String fileName) {
  final fixture = loadConformanceFixture(fileName);
  expect(fixture.ruleset, rules.id);
  expect(fixture.version, rules.version);
  expect(fixture.cases, isNotEmpty);
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
    final resultSheet = evaluation.selectable
        ? sheet.withScore(
            testCase.category,
            evaluation.score,
            bonusDelta: evaluation.bonusDelta,
          )
        : sheet;
    final totals = rules.totals(resultSheet);
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
}
