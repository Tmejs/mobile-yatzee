import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';

import '../application/game_controller.dart';
import '../application/providers.dart';
import '../domain/dice.dart';
import '../rules/ruleset_registry.dart';
import '../session/game_command.dart';
import '../session/game_session.dart';
import '../../theme/modern_tabletop_theme.dart';
import 'widgets/dice_tray.dart';
import 'widgets/scorecard.dart';
import 'zero_score_dialog.dart';

final class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

final class _GameScreenState extends ConsumerState<GameScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<TabletopTheme>() ?? TabletopTheme.standard;
    if (value.isLoading) {
      return Scaffold(
        body: Center(
          child: Semantics(
            label: l10n.loading,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
    final state = value.hasError
        ? controller.lastPublished
        : value.requireValue;
    final ruleset = RulesetRegistry().require(
      state.rulesetId,
      state.rulesetVersion,
    );
    ScorecardPreview? previewForCategory(String category) {
      final dice = state.dice;
      if (dice == null) return null;
      final evaluation = ruleset.evaluate(
        category,
        DiceRoll(dice),
        state.players[state.activePlayerIndex].scoreSheet,
      );
      return ScorecardPreview(
        score: evaluation.score,
        selectable: evaluation.selectable,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.round(state.round)),
        backgroundColor: tokens.ivory,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (value.hasError)
              MaterialBanner(
                content: Text(l10n.saveFailed),
                actions: [
                  TextButton(
                    key: const Key('retry-persistence'),
                    onPressed: _busy ? null : () => _retry(controller),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            if (_busy)
              const LinearProgressIndicator(key: Key('persistence-progress')),
            if (state.isComplete)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: EdgeInsets.only(top: tokens.spacing),
                  child: Chip(
                    avatar: const Icon(Icons.emoji_events_outlined),
                    label: Text(l10n.gameComplete),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(tokens.spacing),
              child: DiceTray(
                dice: state.dice,
                held: state.held,
                canHold:
                    !_busy &&
                    !value.hasError &&
                    state.rollCount > 0 &&
                    state.rollCount < 3,
                faceLabel: (index, face, held) =>
                    '${face == null ? l10n.dieNotRolled(index + 1) : l10n.dieFace(index + 1, face)}, ${held ? l10n.held : l10n.notHeld}',
                onToggleHold: (index) => _apply(controller, ToggleHold(index)),
              ),
            ),
            Text(l10n.rolls(state.rollCount)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing * 2 / 3),
              child: FilledButton.icon(
                key: const Key('roll-dice'),
                onPressed:
                    _busy ||
                        value.hasError ||
                        state.rollCount >= 3 ||
                        state.isComplete
                    ? null
                    : () => _apply(controller, const RollDice()),
                icon: const Icon(Icons.casino_outlined),
                label: Text(
                  state.rollCount == 0 ? l10n.rollDice : l10n.rollAgain,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Scorecard(
                  state: state,
                  categories: ruleset.categories,
                  categoryLabel: (id) => _categoryLabel(l10n, id),
                  activePlayerLabel: l10n.activePlayer,
                  scoreLabel: (category, player, score, status, active) {
                    final scoreState = switch (status) {
                      ScoreCellStatus.recorded => l10n.scoreRecorded(score!),
                      ScoreCellStatus.available => l10n.scoreAvailable(score!),
                      ScoreCellStatus.unavailable => l10n.scoreUnavailable(
                        score!,
                      ),
                      ScoreCellStatus.empty => l10n.notScored,
                    };
                    final activeState = active
                        ? l10n.activeScoreCell
                        : l10n.inactiveScoreCell;
                    return '${l10n.scoreCell(category, player, scoreState)}, $activeState';
                  },
                  previewForCategory: previewForCategory,
                  isCategorySelectable: (category) =>
                      !_busy &&
                      !value.hasError &&
                      (previewForCategory(category)?.selectable ?? false),
                  totalLabel: l10n.total,
                  onCategorySelected: (category) => _selectCategory(
                    context,
                    controller,
                    state,
                    category,
                    l10n,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCategory(
    BuildContext context,
    GameController controller,
    GameSession state,
    String category,
    AppLocalizations l10n,
  ) async {
    final ruleset = RulesetRegistry().require(
      state.rulesetId,
      state.rulesetVersion,
    );
    final evaluation = ruleset.evaluate(
      category,
      DiceRoll(state.dice!),
      state.players[state.activePlayerIndex].scoreSheet,
    );
    var confirmed = false;
    if (evaluation.score == 0) {
      if (!context.mounted) return;
      confirmed = await showZeroScoreDialog(
        context,
        title: l10n.zeroScoreTitle,
        message: l10n.zeroScoreMessage,
        cancel: l10n.cancel,
        confirm: l10n.confirmZero,
      );
      if (!confirmed) return;
    }
    await _apply(controller, SelectCategory(category, confirmZero: confirmed));
  }

  Future<void> _apply(GameController controller, GameCommand command) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await controller.apply(command);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _retry(GameController controller) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await controller.retryPersistence();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

String _categoryLabel(AppLocalizations l10n, String id) => switch (id) {
  'ones' => l10n.categoryOnes,
  'twos' => l10n.categoryTwos,
  'threes' => l10n.categoryThrees,
  'fours' => l10n.categoryFours,
  'fives' => l10n.categoryFives,
  'sixes' => l10n.categorySixes,
  'three-kind' => l10n.categoryThreeKind,
  'four-kind' => l10n.categoryFourKind,
  'full-house' => l10n.categoryFullHouse,
  'small-straight' => l10n.categorySmallStraight,
  'large-straight' => l10n.categoryLargeStraight,
  'general' => l10n.categoryGeneral,
  'chance' => l10n.categoryChance,
  'yahtzee' => l10n.categoryYahtzee,
  'yatzy' => l10n.categoryYatzy,
  'one-pair' => l10n.categoryOnePair,
  'two-pairs' => l10n.categoryTwoPairs,
  _ => id,
};
