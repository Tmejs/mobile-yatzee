import '../domain/score_sheet.dart';

final class Player {
  Player({required this.id, required this.name, ScoreSheet? scoreSheet})
    : scoreSheet = scoreSheet ?? ScoreSheet() {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Player ID and name must not be blank');
    }
  }

  final String id;
  final String name;
  final ScoreSheet scoreSheet;

  Player withScoreSheet(ScoreSheet sheet) =>
      Player(id: id, name: name, scoreSheet: sheet);
}
