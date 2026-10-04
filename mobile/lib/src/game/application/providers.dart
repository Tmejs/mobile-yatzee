import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/app_database.dart';
import '../data/drift_game_repository.dart';
import '../data/game_repository.dart';
import '../session/dice_roller.dart';
import '../session/game_session.dart';
import 'game_controller.dart';

final gameDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => DriftGameRepository(ref.watch(gameDatabaseProvider)),
);

final initialGameSessionProvider = Provider<GameSession>(
  (ref) => throw StateError('Provide an initial or restored game session'),
);

final diceRollerProvider = Provider<DiceRoller>((ref) => SecureDiceRoller());

final gameControllerProvider =
    NotifierProvider<GameController, AsyncValue<GameSession>>(
      GameController.new,
    );
