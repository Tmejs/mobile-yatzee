import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/game_command.dart';
import '../session/game_reducer.dart';
import '../session/game_session.dart';
import 'providers.dart';

final class GameController extends Notifier<AsyncValue<GameSession>> {
  GameSession? _pending;
  Future<void>? _persistenceInFlight;
  int _generation = 0;
  late GameSession _lastPublished;
  final GameReducer _reducer = GameReducer();

  @override
  AsyncValue<GameSession> build() {
    final generation = ++_generation;
    _pending = null;
    _persistenceInFlight = null;
    ref.onDispose(() {
      if (_generation == generation) {
        _generation++;
        _pending = null;
        _persistenceInFlight = null;
      }
    });
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
    final generation = _generation;
    final attempt = Future<void>.microtask(
      () => _persistPending(next, generation),
    );
    _persistenceInFlight = attempt;
    return attempt;
  }

  bool _ownsPending(GameSession next, int generation) =>
      ref.mounted && generation == _generation && identical(_pending, next);

  Future<void> _persistPending(GameSession next, int generation) async {
    if (!_ownsPending(next, generation)) return;
    try {
      final repository = ref.read(gameRepositoryProvider);
      if (next.isComplete) {
        await repository.complete(next);
      } else {
        await repository.saveActive(next);
      }
    } catch (error, stackTrace) {
      if (!_ownsPending(next, generation)) return;
      _persistenceInFlight = null;
      state = AsyncError(error, stackTrace);
      return;
    }
    if (!_ownsPending(next, generation)) return;
    _lastPublished = next;
    _pending = null;
    _persistenceInFlight = null;
    state = AsyncData(next);
  }
}
