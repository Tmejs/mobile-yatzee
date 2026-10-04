import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/domain/dice.dart';
import 'package:mobile_yatzee/src/game/domain/score_sheet.dart';
import 'package:mobile_yatzee/src/game/rules/scandinavian_yatzy_ruleset.dart';

import '../../support/ruleset_conformance.dart';

void main() {
  final rules = ScandinavianYatzyRuleset();

  test('all shared Scandinavian Yatzy conformance cases', () {
    expectRulesetConformance(rules, 'scandinavian-yatzy-v1.json');
  });

  test('exposes fifteen ordered and immutable category definitions', () {
    expect(rules.categories.map((category) => category.id), [
      'ones',
      'twos',
      'threes',
      'fours',
      'fives',
      'sixes',
      'one-pair',
      'two-pairs',
      'three-kind',
      'four-kind',
      'full-house',
      'small-straight',
      'large-straight',
      'chance',
      'yatzy',
    ]);
    expect(
      rules.categories.map((category) => category.order),
      List.generate(15, (index) => index),
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
