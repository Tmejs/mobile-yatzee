import 'package:drift/drift.dart';

@DataClassName('CompletedGameRow')
class CompletedGames extends Table {
  TextColumn get gameId => text()();
  TextColumn get mode => text()();
  TextColumn get rulesetId => text()();
  IntColumn get rulesetVersion => integer()();
  BoolColumn get rankedIntent => boolean()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get playersJson => text()();

  @override
  Set<Column> get primaryKey => {gameId};
}
