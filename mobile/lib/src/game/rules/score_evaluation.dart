final class ScoreEvaluation {
  const ScoreEvaluation({
    required this.selectable,
    required this.qualifies,
    required this.score,
    this.bonusDelta = 0,
  });

  final bool selectable;
  final bool qualifies;
  final int score;
  final int bonusDelta;
}
