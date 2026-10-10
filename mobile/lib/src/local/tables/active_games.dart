import 'package:drift/drift.dart';

class ActiveGames extends Table {
  TextColumn get gameId => text()();
  TextColumn get snapshotJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {gameId};
}
