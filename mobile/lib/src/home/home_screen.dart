import 'package:flutter/material.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';

import '../game/presentation/game_setup_screen.dart';
import '../theme/modern_tabletop_theme.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<TabletopTheme>()!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.casino, size: 72, color: tokens.gold),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appTitle,
                    style: tokens.titleStyle.copyWith(fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.homeTagline, textAlign: TextAlign.center),
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
