import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/game/presentation/widgets/scorecard.dart';
import 'package:mobile_yatzee/src/game/rules/ruleset_registry.dart';
import 'package:mobile_yatzee/src/game/session/game_mode.dart';
import 'package:mobile_yatzee/src/game/session/game_session.dart';
import 'package:mobile_yatzee/src/game/session/player.dart';

void main() {
  testWidgets(
    'score cells retain player and category semantics at large text',
    (tester) async {
      final state = GameSession.start(
        gameId: 'a11y',
        rulesetId: 'polish-general',
        rulesetVersion: 1,
        mode: GameMode.passAndPlay,
        players: [
          Player(id: 'p1', name: 'Aleksandra Bardzo Długa'),
          Player(id: 'p2', name: 'Konstanty Jeszcze Dłuższy'),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Scorecard(
                  state: state,
                  categories: RulesetRegistry()
                      .require('polish-general', 1)
                      .categories,
                  categoryLabel: (id) => id,
                  activePlayerLabel: (name) => 'active player $name',
                  scoreLabel: (category, player, score) =>
                      '$category, $player, ${score ?? 'not scored'}',
                  isCategorySelectable: (_) => true,
                  onCategorySelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.byKey(const Key('score-ones-p1'))).label,
        contains('ones, Aleksandra Bardzo Długa'),
      );
    },
  );
}
