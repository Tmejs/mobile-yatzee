import 'package:drift/drift.dart';

@DataClassName('CompletedGameRow')
class CompletedGames extends Table {
  TextColumn get gameId => text()();
  TextColumn get mode => text()();
  TextColumn get rulesetId => text()();
  IntColumn get rulesetVersion => integer()();
  BoolColumn get rankedIntent => boolean()();
  IntColumn get completedAtMicros => integer()();
  TextColumn get playersJson => text()();

  @override
  Set<Column> get primaryKey => {gameId};
}
