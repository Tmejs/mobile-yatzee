import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/domain/dice.dart';
import 'package:mobile_yatzee/src/game/domain/score_sheet.dart';
import 'package:mobile_yatzee/src/game/rules/classic_yahtzee_ruleset.dart';

import '../../support/ruleset_conformance.dart';

void main() {
  final rules = ClassicYahtzeeRuleset();

  test('all shared Classic Yahtzee conformance cases', () {
    expectRulesetConformance(rules, 'classic-yahtzee-v1.json');
  });

  test('exposes thirteen ordered and immutable category definitions', () {
    expect(rules.categories.map((category) => category.id), [
      'ones',
      'twos',
      'threes',
      'fours',
      'fives',
      'sixes',
      'three-kind',
      'four-kind',
      'full-house',
      'small-straight',
      'large-straight',
      'yahtzee',
      'chance',
    ]);
    expect(
      rules.categories.map((category) => category.order),
      List.generate(13, (index) => index),
    );
    expect(() => rules.categories.clear(), throwsUnsupportedError);
  });

  test('rejects used and unknown categories', () {
    final roll = DiceRoll([1, 2, 3, 4, 5]);
    expect(
      () => rules.evaluate('chance', roll, ScoreSheet(scores: {'chance': 0})),
      throwsStateError,
    );
    expect(
      () => rules.evaluate('unknown', roll, ScoreSheet()),
      throwsArgumentError,
    );
  });
}
