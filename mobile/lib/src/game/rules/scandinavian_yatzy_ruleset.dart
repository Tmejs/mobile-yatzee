import '../domain/category.dart';
import '../domain/dice.dart';
import '../domain/score_sheet.dart';
import 'ruleset.dart';
import 'score_evaluation.dart';

final class ScandinavianYatzyRuleset implements Ruleset {
  static const _upper = <CategoryId>[
    'ones',
    'twos',
    'threes',
    'fours',
    'fives',
    'sixes',
  ];
  static const _lower = <CategoryId>[
    'one-pair',
    'two-pairs',
    'three-kind',
    'four-kind',
    'full-house',
    'small-straight',
    'large-straight',
    'chance',
    'yatzy',
  ];

  static final List<CategoryDefinition> _categories = List.unmodifiable([
    for (var index = 0; index < _upper.length; index++)
      CategoryDefinition(
        id: _upper[index],
        labelKey: 'category.${_upper[index]}',
        section: 'upper',
        order: index,
      ),
    for (var index = 0; index < _lower.length; index++)
      CategoryDefinition(
        id: _lower[index],
        labelKey: 'category.${_lower[index]}',
        section: 'lower',
        order: index + _upper.length,
      ),
  ]);

  @override
  String get id => 'scandinavian-yatzy';

  @override
  int get version => 1;

  @override
  List<CategoryDefinition> get categories => _categories;

  @override
  ScoreEvaluation evaluate(
    CategoryId category,
    DiceRoll roll,
    ScoreSheet sheet,
  ) {
    if (!_upper.contains(category) && !_lower.contains(category)) {
      throw ArgumentError.value(category, 'category', 'Unknown category');
    }
    if (sheet.scores.containsKey(category)) {
      throw StateError('Category already scored: $category');
    }

    final counts = roll.counts;
    final upperIndex = _upper.indexOf(category);
    if (upperIndex >= 0) {
      final face = upperIndex + 1;
      return ScoreEvaluation(
        selectable: true,
        qualifies: true,
        score: face * (counts[face] ?? 0),
      );
    }

    final pairs = [
      for (var face = 6; face >= 1; face--)
        if ((counts[face] ?? 0) >= 2) face,
    ];
    final score = switch (category) {
      'one-pair' => pairs.isNotEmpty ? pairs.first * 2 : 0,
      'two-pairs' => pairs.length >= 2 ? (pairs[0] + pairs[1]) * 2 : 0,
      'three-kind' => _kindScore(counts, 3),
      'four-kind' => _kindScore(counts, 4),
      'full-house' =>
        counts.values.contains(3) && counts.values.contains(2) ? roll.sum : 0,
      'small-straight' => _straight(roll, [1, 2, 3, 4, 5]) ? 15 : 0,
      'large-straight' => _straight(roll, [2, 3, 4, 5, 6]) ? 20 : 0,
      'chance' => roll.sum,
      'yatzy' => counts.values.contains(5) ? 50 : 0,
      _ => throw StateError('Unreachable category'),
    };
    return ScoreEvaluation(
      selectable: true,
      qualifies: score > 0 || category == 'chance',
      score: score,
    );
  }

  static int _kindScore(Map<int, int> counts, int size) {
    for (var face = 6; face >= 1; face--) {
      if ((counts[face] ?? 0) >= size) return face * size;
    }
    return 0;
  }

  static bool _straight(DiceRoll roll, List<int> expected) {
    final sorted = [...roll.values]..sort();
    for (var index = 0; index < 5; index++) {
      if (sorted[index] != expected[index]) return false;
    }
    return true;
  }

  @override
  bool isValidRepeatedBonusState(ScoreSheet sheet) =>
      sheet.repeatedFiveOfAKindBonusTotal == 0;

  @override
  ScoreTotals totals(ScoreSheet sheet) {
    final upper = _upper.fold<int>(
      0,
      (sum, id) => sum + (sheet.scores[id] ?? 0),
    );
    final lower = _lower.fold<int>(
      0,
      (sum, id) => sum + (sheet.scores[id] ?? 0),
    );
    final bonus = upper >= 63 ? 50 : 0;
    return ScoreTotals(
      upperSubtotal: upper,
      upperBonus: bonus,
      lowerSubtotal: lower,
      repeatedFiveOfAKindBonusTotal: sheet.repeatedFiveOfAKindBonusTotal,
      finalTotal: upper + bonus + lower + sheet.repeatedFiveOfAKindBonusTotal,
    );
  }
}
