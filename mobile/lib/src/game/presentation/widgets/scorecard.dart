import 'package:flutter/material.dart';

import '../../domain/category.dart';
import '../../session/game_session.dart';
import '../../../theme/modern_tabletop_theme.dart';
import 'player_header.dart';

enum ScoreCellStatus { recorded, available, unavailable, empty }

final class ScorecardPreview {
  const ScorecardPreview({required this.score, required this.selectable});

  final int score;
  final bool selectable;
}

final class Scorecard extends StatelessWidget {
  const Scorecard({
    required this.state,
    required this.categories,
    required this.categoryLabel,
    required this.activePlayerLabel,
    required this.scoreLabel,
    required this.previewForCategory,
    required this.isCategorySelectable,
    required this.onCategorySelected,
    this.totalLabel = 'Total',
    super.key,
  });
  final GameSession state;
  final List<CategoryDefinition> categories;
  final String Function(String id) categoryLabel;
  final String Function(String name) activePlayerLabel;
  final String Function(
    String category,
    String player,
    int? score,
    ScoreCellStatus status,
    bool active,
  )
  scoreLabel;
  final ScorecardPreview? Function(String category) previewForCategory;
  final bool Function(String category) isCategorySelectable;
  final ValueChanged<String> onCategorySelected;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    const categoryWidth = 116.0;
    final tokens =
        Theme.of(context).extension<TabletopTheme>() ?? TabletopTheme.standard;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: categoryWidth),
              for (var index = 0; index < state.players.length; index++)
                Expanded(
                  child: PlayerHeader(
                    playerId: state.players[index].id,
                    name: state.players[index].name,
                    active:
                        !state.isComplete && index == state.activePlayerIndex,
                    activeLabel: activePlayerLabel(state.players[index].name),
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          for (final category in categories)
            _row(category, categoryWidth, tokens),
          const Divider(height: 1),
          Row(
            children: [
              SizedBox(
                width: categoryWidth,
                child: Padding(
                  padding: EdgeInsets.all(tokens.compactSpacing),
                  child: Text(
                    totalLabel,
                    style: tokens.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              for (var index = 0; index < state.players.length; index++)
                Expanded(
                  child: Container(
                    color: !state.isComplete && index == state.activePlayerIndex
                        ? tokens.gold.withValues(alpha: 0.2)
                        : null,
                    padding: EdgeInsets.all(tokens.compactSpacing),
                    alignment: Alignment.center,
                    child: Text(
                      '${state.totalsFor(index).finalTotal}',
                      style: tokens.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    CategoryDefinition category,
    double categoryWidth,
    TabletopTheme tokens,
  ) => SizedBox(
    height: 42,
    child: Row(
      children: [
        SizedBox(
          width: categoryWidth,
          child: TextButton(
            key: Key('score-${category.id}'),
            onPressed:
                state.rollCount > 0 &&
                    !state.players[state.activePlayerIndex].scoreSheet.scores
                        .containsKey(category.id) &&
                    isCategorySelectable(category.id)
                ? () => onCategorySelected(category.id)
                : null,
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: tokens.compactSpacing),
            ),
            child: Text(
              categoryLabel(category.id),
              style: tokens.bodyStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        for (var index = 0; index < state.players.length; index++)
          Expanded(child: _cell(category, index, tokens)),
      ],
    ),
  );

  Widget _cell(
    CategoryDefinition category,
    int playerIndex,
    TabletopTheme tokens,
  ) {
    final player = state.players[playerIndex];
    final recorded = player.scoreSheet.scores[category.id];
    final active = !state.isComplete && playerIndex == state.activePlayerIndex;
    final preview = active && recorded == null
        ? previewForCategory(category.id)
        : null;
    final status = recorded != null
        ? ScoreCellStatus.recorded
        : preview == null
        ? ScoreCellStatus.empty
        : preview.selectable
        ? ScoreCellStatus.available
        : ScoreCellStatus.unavailable;
    final shownScore = recorded ?? preview?.score;
    final icon = switch (status) {
      ScoreCellStatus.recorded => Icons.check,
      ScoreCellStatus.available => Icons.add_circle_outline,
      ScoreCellStatus.unavailable => Icons.block,
      ScoreCellStatus.empty => null,
    };

    return Semantics(
      key: Key('score-${category.id}-${player.id}'),
      label: scoreLabel(
        categoryLabel(category.id),
        player.name,
        shownScore,
        status,
        active,
      ),
      excludeSemantics: true,
      child: Container(
        key: Key('score-${category.id}-p$playerIndex-value'),
        color: active ? tokens.gold.withValues(alpha: 0.2) : null,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                shownScore?.toString() ?? '—',
                style: tokens.bodyStyle.copyWith(
                  fontWeight: status == ScoreCellStatus.available
                      ? FontWeight.bold
                      : null,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 2),
              Icon(icon, size: 14),
            ],
          ],
        ),
      ),
    );
  }
}
