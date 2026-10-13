import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/app.dart';
import 'package:mobile_yatzee/src/game/application/providers.dart';
import 'package:mobile_yatzee/src/game/data/game_repository.dart';
import 'package:mobile_yatzee/src/game/domain/completed_game.dart';
import 'package:mobile_yatzee/src/game/session/dice_roller.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';

final class _FlowRepository implements GameRepository {
  GameSession? saved;

  @override
  Future<void> saveActive(GameSession session) async => saved = session;
  @override
  Future<void> complete(GameSession session) async => saved = session;
  @override
  Future<GameSession?> loadActive(String gameId) async => saved;
  @override
  Stream<List<GameSession>> watchActive() => const Stream.empty();
  @override
  Stream<List<CompletedGame>> watchCompleted({String? rulesetId}) =>
      const Stream.empty();
  @override
  Future<double?> latestTenSoloAverage({
    required String rulesetId,
    required int rulesetVersion,
  }) async => null;
}

final class _FixedRoller implements DiceRoller {
  @override
  List<int> roll(int count) => List.filled(count, 4);
}

void main() {
  testWidgets('real home setup flow starts and plays a scoped local game', (
    tester,
  ) async {
    final repository = _FlowRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWithValue(repository),
          diceRollerProvider.overrideWithValue(_FixedRoller()),
        ],
        child: const MobileYatzeeApp(),
      ),
    );

    await tester.tap(find.text('Nowa gra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rozpocznij grę'));
    await tester.pumpAndSettle();

    expect(find.text('Rzuć kośćmi'), findsOneWidget);
    await tester.tap(find.text('Rzuć kośćmi'));
    await tester.pumpAndSettle();
    expect(repository.saved?.rollCount, 1);
    expect(tester.takeException(), isNull);
  });
}
