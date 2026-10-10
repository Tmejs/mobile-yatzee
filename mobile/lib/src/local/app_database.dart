import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/active_games.dart';
import 'tables/completed_games.dart';
import 'tables/preferences.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ActiveGames, CompletedGames, Preferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'general_game'));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
