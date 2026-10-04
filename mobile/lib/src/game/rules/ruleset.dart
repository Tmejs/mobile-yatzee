import '../domain/category.dart';
import '../domain/dice.dart';
import '../domain/score_sheet.dart';
import 'score_evaluation.dart';

abstract interface class Ruleset {
  String get id;
  int get version;
  List<CategoryDefinition> get categories;
  ScoreEvaluation evaluate(
    CategoryId category,
    DiceRoll roll,
    ScoreSheet sheet,
  );
  ScoreTotals totals(ScoreSheet sheet);
  bool isValidRepeatedBonusState(ScoreSheet sheet);
}
