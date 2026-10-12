import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../application/providers.dart';
import '../session/game_mode.dart';
import '../session/game_session.dart';
import '../session/player.dart';
import 'game_screen.dart';

final class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({this.onSessionCreated, super.key});
  final ValueChanged<GameSession>? onSessionCreated;
  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

final class _GameSetupScreenState extends State<GameSetupScreen> {
  GameMode _mode = GameMode.solo;
  String _rulesetId = 'polish-general';
  final _names = <TextEditingController>[];
  @override
  void initState() {
    super.initState();
    _setPlayerCount(1);
  }

  @override
  void dispose() {
    for (final item in _names) {
      item.dispose();
    }
    super.dispose();
  }

  void _setPlayerCount(int count) {
    while (_names.length < count) {
      _names.add(TextEditingController());
    }
    while (_names.length > count) {
      _names.removeLast().dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<GameMode>(
              segments: [
                ButtonSegment(
                  value: GameMode.solo,
                  label: Text(l10n.solo),
                  icon: const Icon(Icons.person),
                ),
                ButtonSegment(
                  value: GameMode.passAndPlay,
                  label: Text(
                    l10n.passAndPlay,
                    key: const Key('mode-pass-and-play'),
                  ),
                  icon: const Icon(Icons.groups),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) => setState(() {
                _mode = value.single;
                _setPlayerCount(_mode == GameMode.solo ? 1 : 2);
              }),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _rulesetId,
              decoration: InputDecoration(labelText: l10n.ruleset),
              items: [
                DropdownMenuItem(
                  value: 'polish-general',
                  child: Text(l10n.polishGeneral),
                ),
                DropdownMenuItem(
                  value: 'classic-yahtzee',
                  child: Text(l10n.classicYahtzee),
                ),
                DropdownMenuItem(
                  value: 'scandinavian-yatzy',
                  child: Text(l10n.scandinavianYatzy),
                ),
              ],
              onChanged: (value) => setState(() => _rulesetId = value!),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _names.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  key: Key('player-name-$index'),
                  controller: _names[index],
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: l10n.playerName(index + 1),
                    counterText: '',
                  ),
                ),
              ),
            if (_mode == GameMode.passAndPlay)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    key: const Key('remove-player'),
                    tooltip: l10n.removePlayer,
                    onPressed: _names.length > 2
                        ? () =>
                              setState(() => _setPlayerCount(_names.length - 1))
                        : null,
                    icon: const Icon(Icons.person_remove),
                  ),
                  IconButton(
                    key: const Key('add-player'),
                    tooltip: l10n.addPlayer,
                    onPressed: _names.length < 4
                        ? () =>
                              setState(() => _setPlayerCount(_names.length + 1))
                        : null,
                    icon: const Icon(Icons.person_add),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _start(l10n),
              child: Text(l10n.startGame),
            ),
          ],
        ),
      ),
    );
  }

  void _start(AppLocalizations l10n) {
    const uuid = Uuid();
    final session = GameSession.start(
      gameId: uuid.v4(),
      rulesetId: _rulesetId,
      rulesetVersion: 1,
      mode: _mode,
      players: [
        for (var i = 0; i < _names.length; i++)
          Player(
            id: uuid.v4(),
            name: _names[i].text.trim().isEmpty
                ? l10n.defaultPlayerName(i + 1)
                : _names[i].text.trim(),
          ),
      ],
    );
    final callback = widget.onSessionCreated;
    if (callback != null) {
      callback(session);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProviderScope(
          overrides: [initialGameSessionProvider.overrideWithValue(session)],
          child: const GameScreen(),
        ),
      ),
    );
  }
}
