import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/game_command.dart';
import '../session/game_reducer.dart';
import '../session/game_session.dart';
import 'providers.dart';

final class GameController extends Notifier<AsyncValue<GameSession>> {
  GameSession? _pending;
  Future<void>? _persistenceInFlight;
  late GameSession _lastPublished;
  final GameReducer _reducer = GameReducer();

  @override
  AsyncValue<GameSession> build() {
    final initial = ref.watch(initialGameSessionProvider);
    _lastPublished = initial;
    return AsyncData(initial);
  }

  /// Last successful public state, retained if the next write fails.
  GameSession get lastPublished => _lastPublished;

  /// Transition held after a write failure; retryPersistence writes it unchanged.
  GameSession? get pending => _pending;

  Future<void> apply(GameCommand command) async {
    if (_pending != null) {
      throw StateError('Retry the pending transition before another command');
    }
    final next = _reducer.apply(
      state.requireValue,
      command,
      ref.read(diceRollerProvider),
    );
    _pending = next;
    await retryPersistence();
  }

  Future<void> retryPersistence() {
    final ongoing = _persistenceInFlight;
    if (ongoing != null) return ongoing;
    final next = _pending;
    if (next == null) return Future.error(StateError('No pending transition'));
    final attempt = _persistPending(next);
    _persistenceInFlight = attempt;
    return attempt.whenComplete(() {
      if (identical(_persistenceInFlight, attempt)) {
        _persistenceInFlight = null;
      }
    });
  }

  Future<void> _persistPending(GameSession next) async {
    try {
      final repository = ref.read(gameRepositoryProvider);
      if (next.isComplete) {
        await repository.complete(next);
      } else {
        await repository.saveActive(next);
      }
      _lastPublished = next;
      _pending = null;
      state = AsyncData(next);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
