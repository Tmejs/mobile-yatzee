import 'category.dart';

final class ScoreSheet {
  ScoreSheet({
    Map<CategoryId, int> scores = const {},
    this.repeatedFiveOfAKindBonusTotal = 0,
  }) : scores = Map.unmodifiable(scores) {
    if (scores.values.any((score) => score < 0) ||
        repeatedFiveOfAKindBonusTotal < 0) {
      throw ArgumentError('Scores and bonus must be nonnegative');
    }
  }

  final Map<CategoryId, int> scores;
  final int repeatedFiveOfAKindBonusTotal;

  ScoreSheet withScore(CategoryId category, int score, {int bonusDelta = 0}) {
    if (scores.containsKey(category)) {
      throw StateError('Category already scored: $category');
    }
    if (score < 0 || bonusDelta < 0) {
      throw ArgumentError('Score and bonus must be nonnegative');
    }
    return ScoreSheet(
      scores: {...scores, category: score},
      repeatedFiveOfAKindBonusTotal: repeatedFiveOfAKindBonusTotal + bonusDelta,
    );
  }
}

final class ScoreTotals {
  const ScoreTotals({
    required this.upperSubtotal,
    required this.upperBonus,
    required this.lowerSubtotal,
    required this.repeatedFiveOfAKindBonusTotal,
    required this.finalTotal,
  });

  final int upperSubtotal;
  final int upperBonus;
  final int lowerSubtotal;
  final int repeatedFiveOfAKindBonusTotal;
  final int finalTotal;
}
