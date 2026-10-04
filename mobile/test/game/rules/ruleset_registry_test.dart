import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/rules/classic_yahtzee_ruleset.dart';
import 'package:mobile_yatzee/src/game/rules/polish_general_ruleset.dart';
import 'package:mobile_yatzee/src/game/rules/ruleset_registry.dart';
import 'package:mobile_yatzee/src/game/rules/scandinavian_yatzy_ruleset.dart';

void main() {
  test('resolves exactly the three immutable v1 rulesets', () {
    final registry = RulesetRegistry();
    expect(registry.require('polish-general', 1), isA<PolishGeneralRuleset>());
    expect(
      registry.require('classic-yahtzee', 1),
      isA<ClassicYahtzeeRuleset>(),
    );
    expect(
      registry.require('scandinavian-yatzy', 1),
      isA<ScandinavianYatzyRuleset>(),
    );
    expect(registry.require('polish-general', 1).categories, hasLength(13));
    expect(registry.require('classic-yahtzee', 1).categories, hasLength(13));
    expect(registry.require('scandinavian-yatzy', 1).categories, hasLength(15));
    expect(
      () => registry.require('classic-yahtzee', 2),
      throwsUnsupportedError,
    );
    expect(() => registry.require('unknown', 1), throwsUnsupportedError);
    expect(
      () => registry.require('classic-yahtzee:v1', 1),
      throwsUnsupportedError,
    );
  });
}
