import 'package:flutter/material.dart';

import '../../domain/category.dart';
import '../../session/game_session.dart';
import '../../../theme/modern_tabletop_theme.dart';
import 'player_header.dart';

final class Scorecard extends StatelessWidget {
  const Scorecard({
    required this.state,
    required this.categories,
    required this.categoryLabel,
    required this.activePlayerLabel,
    required this.scoreLabel,
    required this.isCategorySelectable,
    required this.onCategorySelected,
    this.totalLabel = 'Total',
    super.key,
  });
  final GameSession state;
  final List<CategoryDefinition> categories;
  final String Function(String id) categoryLabel;
  final String Function(String name) activePlayerLabel;
  final String Function(String category, String player, int? score) scoreLabel;
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
                    active: index == state.activePlayerIndex,
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
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    totalLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              for (var index = 0; index < state.players.length; index++)
                Expanded(
                  child: Container(
                    color: index == state.activePlayerIndex
                        ? tokens.gold.withValues(alpha: 0.2)
                        : null,
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: Text(
                      '${state.totalsFor(index).finalTotal}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              categoryLabel(category.id),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        for (var index = 0; index < state.players.length; index++)
          Expanded(
            child: Semantics(
              key: Key('score-${category.id}-${state.players[index].id}'),
              label: scoreLabel(
                categoryLabel(category.id),
                state.players[index].name,
                state.players[index].scoreSheet.scores[category.id],
              ),
              excludeSemantics: true,
              child: Container(
                key: Key('score-${category.id}-p$index-value'),
                color: index == state.activePlayerIndex
                    ? tokens.gold.withValues(alpha: 0.2)
                    : null,
                alignment: Alignment.center,
                child: Text(
                  state.players[index].scoreSheet.scores[category.id]
                          ?.toString() ??
                      '—',
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
