import 'classic_yahtzee_ruleset.dart';
import 'polish_general_ruleset.dart';
import 'ruleset.dart';
import 'scandinavian_yatzy_ruleset.dart';

final class RulesetRegistry {
  RulesetRegistry()
    : _rulesets = Map.unmodifiable({
        for (final ruleset in <Ruleset>[
          PolishGeneralRuleset(),
          ClassicYahtzeeRuleset(),
          ScandinavianYatzyRuleset(),
        ])
          '${ruleset.id}:v${ruleset.version}': ruleset,
      });

  final Map<String, Ruleset> _rulesets;

  Ruleset require(String id, int version) {
    final ruleset = _rulesets['$id:v$version'];
    if (ruleset == null) {
      throw UnsupportedError('Unknown ruleset version: $id:v$version');
    }
    return ruleset;
  }
}
