import 'package:flutter/material.dart';

import '../../../theme/modern_tabletop_theme.dart';

final class DiceTray extends StatelessWidget {
  const DiceTray({
    required this.dice,
    required this.held,
    required this.canHold,
    required this.faceLabel,
    required this.onToggleHold,
    super.key,
  });
  final List<int>? dice;
  final List<bool> held;
  final bool canHold;
  final String Function(int index, int? face, bool held) faceLabel;
  final ValueChanged<int> onToggleHold;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<TabletopTheme>() ?? TabletopTheme.standard;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var index = 0; index < 5; index++)
          Semantics(
            label: faceLabel(index, dice?[index], held[index]),
            button: canHold,
            selected: held[index],
            excludeSemantics: true,
            child: SizedBox.square(
              dimension: 52,
              child: Material(
                color: held[index] ? tokens.gold : tokens.ivory,
                elevation: held[index] ? 1 : tokens.elevation + 1,
                borderRadius: BorderRadius.circular(tokens.radius * 0.75),
                child: InkWell(
                  key: Key('die-$index'),
                  borderRadius: BorderRadius.circular(tokens.radius * 0.75),
                  onTap: canHold ? () => onToggleHold(index) : null,
                  child: Center(
                    child: Text(
                      dice?[index].toString() ?? '–',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
