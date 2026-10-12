import 'package:flutter/material.dart';

import '../../../theme/modern_tabletop_theme.dart';

final class PlayerHeader extends StatelessWidget {
  const PlayerHeader({
    required this.playerId,
    required this.name,
    required this.active,
    required this.activeLabel,
    super.key,
  });
  final String playerId, name, activeLabel;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<TabletopTheme>() ?? TabletopTheme.standard;
    return Semantics(
      label: active ? activeLabel : name,
      header: true,
      container: true,
      excludeSemantics: true,
      child: Container(
        key: Key('player-column-$playerId'),
        color: active ? tokens.gold.withValues(alpha: 0.2) : Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: 2,
          vertical: tokens.spacing * 2 / 3,
        ),
        alignment: Alignment.center,
        child: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
