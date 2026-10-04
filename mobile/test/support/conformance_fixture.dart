import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

final class ConformanceCase {
  ConformanceCase(Map<String, dynamic> json)
    : name = json['name'] as String,
      dice = (json['dice'] as List).cast<int>(),
      category = json['category'] as String,
      priorScores = ((json['priorState'] as Map)['scores'] as Map)
          .cast<String, int>(),
      priorBonus =
          (json['priorState'] as Map)['repeatedFiveOfAKindBonusTotal'] as int,
      selectable = json['selectable'] as bool,
      valid = json['valid'] as bool,
      score = json['score'] as int,
      bonusDelta = json['bonusDelta'] as int,
      expectedTotals = (json['expectedTotals'] as Map).cast<String, int>();

  final String name;
  final List<int> dice;
  final String category;
  final Map<String, int> priorScores;
  final int priorBonus;
  final bool selectable;
  final bool valid;
  final int score;
  final int bonusDelta;
  final Map<String, int> expectedTotals;
}

final class ConformanceFixture {
  ConformanceFixture(Map<String, dynamic> json)
    : ruleset = json['ruleset'] as String,
      version = json['version'] as int,
      cases = (json['cases'] as List)
          .map(
            (value) => ConformanceCase((value as Map).cast<String, dynamic>()),
          )
          .toList();

  final String ruleset;
  final int version;
  final List<ConformanceCase> cases;
}

ConformanceFixture loadConformanceFixture(String fileName) {
  final file = File(
    path.join(Directory.current.parent.path, 'rulesets', fileName),
  );
  return ConformanceFixture(
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
  );
}
