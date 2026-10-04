import '../domain/category.dart';
import '../domain/dice.dart';
import '../domain/score_sheet.dart';
import 'ruleset.dart';
import 'score_evaluation.dart';

final class ClassicYahtzeeRuleset implements Ruleset {
  static const _upper = <CategoryId>[
    'ones',
    'twos',
    'threes',
    'fours',
    'fives',
    'sixes',
  ];
  static const _lower = <CategoryId>[
    'three-kind',
    'four-kind',
    'full-house',
    'small-straight',
    'large-straight',
    'yahtzee',
    'chance',
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
  String get id => 'classic-yahtzee';

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
    final fiveKindFace = counts.entries
        .where((entry) => entry.value == 5)
        .map((entry) => entry.key)
        .firstOrNull;
    final repeat = fiveKindFace != null && sheet.scores['yahtzee'] == 50;
    if (repeat) {
      final matchingUpper = _upper[fiveKindFace - 1];
      if (!sheet.scores.containsKey(matchingUpper)) {
        if (category != matchingUpper) return _notSelectable;
      } else if (_lower.any((id) => !sheet.scores.containsKey(id))) {
        if (!_lower.contains(category)) return _notSelectable;
      } else {
        if (!_upper.contains(category)) return _notSelectable;
        return const ScoreEvaluation(
          selectable: true,
          qualifies: false,
          score: 0,
          bonusDelta: 100,
        );
      }
    }

    final upperIndex = _upper.indexOf(category);
    if (upperIndex >= 0) {
      final face = upperIndex + 1;
      return ScoreEvaluation(
        selectable: true,
        qualifies: true,
        score: face * (counts[face] ?? 0),
        bonusDelta: repeat ? 100 : 0,
      );
    }

    final joker = repeat && sheet.scores.containsKey(_upper[fiveKindFace - 1]);
    final score = switch (category) {
      'three-kind' => counts.values.any((count) => count >= 3) ? roll.sum : 0,
      'four-kind' => counts.values.any((count) => count >= 4) ? roll.sum : 0,
      'full-house' =>
        joker || (counts.values.contains(3) && counts.values.contains(2))
            ? 25
            : 0,
      'small-straight' => joker || _hasRun(counts, 4) ? 30 : 0,
      'large-straight' => joker || _hasRun(counts, 5) ? 40 : 0,
      'yahtzee' => fiveKindFace != null ? 50 : 0,
      'chance' => roll.sum,
      _ => throw StateError('Unreachable category'),
    };
    return ScoreEvaluation(
      selectable: true,
      qualifies: score > 0 || category == 'chance',
      score: score,
      bonusDelta: repeat ? 100 : 0,
    );
  }

  static const _notSelectable = ScoreEvaluation(
    selectable: false,
    qualifies: false,
    score: 0,
  );

  static bool _hasRun(Map<int, int> counts, int length) {
    for (var start = 1; start <= 7 - length; start++) {
      if ([for (var face = start; face < start + length; face++) face]
          .every(counts.containsKey)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool isValidRepeatedBonusState(ScoreSheet sheet) {
    final bonus = sheet.repeatedFiveOfAKindBonusTotal;
    if (bonus == 0) return true;
    return bonus % 100 == 0 &&
        sheet.scores['yahtzee'] == 50 &&
        bonus ~/ 100 <= sheet.scores.length - 1;
  }

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
    final bonus = upper >= 63 ? 35 : 0;
    return ScoreTotals(
      upperSubtotal: upper,
      upperBonus: bonus,
      lowerSubtotal: lower,
      repeatedFiveOfAKindBonusTotal: sheet.repeatedFiveOfAKindBonusTotal,
      finalTotal: upper + bonus + lower + sheet.repeatedFiveOfAKindBonusTotal,
    );
  }
}
