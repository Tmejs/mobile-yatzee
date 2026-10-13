import 'package:flutter/material.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';

import '../game/presentation/game_setup_screen.dart';
import '../theme/modern_tabletop_theme.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<TabletopTheme>() ?? TabletopTheme.standard;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Card(
            margin: EdgeInsets.all(tokens.spacing * 2),
            child: Padding(
              padding: EdgeInsets.all(tokens.compactSpacing * 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.casino,
                    size: tokens.spacing * 6,
                    color: tokens.gold,
                  ),
                  SizedBox(height: tokens.compactSpacing * 2),
                  Text(
                    l10n.appTitle,
                    style: tokens.titleStyle.copyWith(fontSize: 36),
                  ),
                  SizedBox(height: tokens.compactSpacing),
                  Text(
                    l10n.homeTagline,
                    textAlign: TextAlign.center,
                    style: tokens.bodyStyle,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const GameSetupScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.newGame),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
