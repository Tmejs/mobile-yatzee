import '../domain/category.dart';
import '../domain/dice.dart';
import '../domain/score_sheet.dart';
import 'ruleset.dart';

/// Validates persisted category values against outcomes of the versioned rules.
final class ScoreSheetValidator {
  ScoreSheetValidator._();

  static final Map<(String, int), Map<CategoryId, Set<int>>> _scoreCache = {};

  static bool accepts(Ruleset ruleset, ScoreSheet sheet) {
    if (!ruleset.isValidRepeatedBonusState(sheet)) return false;
    if (sheet.scores.isEmpty) return true;
    final possible = _scoreCache.putIfAbsent((
      ruleset.id,
      ruleset.version,
    ), () => _possibleScores(ruleset));
    for (final entry in sheet.scores.entries) {
      if (!(possible[entry.key]?.contains(entry.value) ?? false)) return false;
    }
    return true;
  }

  static Map<CategoryId, Set<int>> _possibleScores(Ruleset ruleset) {
    final scores = {
      for (final category in ruleset.categories) category.id: <int>{},
    };
    final emptySheet = ScoreSheet();
    // Enumerate every ordered five-die roll. This does not assume that a
    // future ruleset is insensitive to the order of dice.
    for (var encoded = 0; encoded < 7776; encoded++) {
      var remainder = encoded;
      final faces = <int>[];
      for (var die = 0; die < 5; die++) {
        faces.add(remainder % 6 + 1);
        remainder ~/= 6;
      }
      final roll = DiceRoll(faces);
      for (final category in ruleset.categories) {
        final result = ruleset.evaluate(category.id, roll, emptySheet);
        if (result.selectable) scores[category.id]!.add(result.score);
      }
    }
    return Map.unmodifiable({
      for (final entry in scores.entries)
        entry.key: Set<int>.unmodifiable(entry.value),
    });
  }
}
