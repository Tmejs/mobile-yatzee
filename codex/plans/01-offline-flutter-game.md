# Offline Flutter Game Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete offline iOS/Android game with three rulesets, solo and pass-and-play, autosave, Polish/English UI, accessibility, and local last-ten statistics.

**Architecture:** Pure Dart domain and session reducers have no Flutter or persistence dependencies. Drift persists versioned snapshots and completed games; Riverpod application controllers connect repositories to focused Flutter widgets using the Modern Tabletop theme.

**Tech Stack:** Flutter 3.47 stable, Dart bundled with Flutter, flutter_riverpod 3.4.3, drift 2.35.0, drift_flutter 0.3.1, Flutter gen-l10n, package:integration_test.

**Spec:** `codex/design.md`

## Global Constraints

- Use exactly five six-sided dice and at most three rolls per turn.
- Persist after every roll, hold toggle, category selection, and player transition.
- Support one solo player and two to four pass-and-play players.
- Keep all domain-visible labels behind stable localization keys.
- Preserve `rulesetId` and `rulesetVersion` in every game and completed result.
- Never require network, account, advertising, or backend code in this plan.
- Use portrait-first layouts; all player score columns remain visible together.

## Review Focus

- Five-of-a-kind scored into Polish three/four-of-a-kind must count exactly three/four dice; Task 4 fixtures pin both cases.
- Classic repeat-Yahtzee must follow forced upper, joker lower, and zero-upper fallback branches; Task 5 fixtures pin each branch.
- A crash after the third roll but before category selection must restore the same dice/holds/roll count; Task 7 tests every persisted transition.
- Four long player names plus large text must not obscure active-player or score semantics; Task 8 widget/golden tests cover constrained widths.
- Recording a deliberate zero must require confirmation while a valid zero-valued upper score remains selectable; Tasks 6 and 8 distinguish the cases.

---

### Task 3: Flutter foundation and local verification gate

**Files:**
- Create: `mobile/` with `flutter create --org pl.tmejs --project-name mobile_yatzee --platforms android,ios mobile`
- Modify: `mobile/pubspec.yaml`
- Modify: `mobile/analysis_options.yaml`
- Create: `mobile/lib/main.dart`
- Create: `mobile/lib/src/app.dart`
- Create: `mobile/test/app_smoke_test.dart`
- Create: `mobile/tool/verify.sh`
- Modify: `README.md`
- Create: `codex/reviews/checkpoint-3-flutter-foundation.md`

**Interfaces:**
- Consumes: no product code.
- Produces: `MobileYatzeeApp`, `ProviderScope` root, reproducible `mobile/tool/verify.sh` gate.

- [ ] **Step 1: Pin the toolchain and scaffold only iOS/Android**

Run:

```bash
flutter --version
flutter create --org pl.tmejs --project-name mobile_yatzee --platforms android,ios mobile
cd mobile
flutter pub add flutter_riverpod:3.4.3 drift:2.35.0 drift_flutter:0.3.1 intl uuid
flutter pub add --dev build_runner drift_dev flutter_lints
```

Record the exact Flutter/Dart output in `codex/reviews/checkpoint-3-flutter-foundation.md`. Expected: Flutter 3.47 stable; if the machine has no Flutter, install that stable SDK before continuing and record the installation source.

- [ ] **Step 2: Write the failing root-widget smoke test**

```dart
testWidgets('starts in Polish and shows the home title', (tester) async {
  await tester.pumpWidget(const ProviderScope(child: MobileYatzeeApp()));
  expect(find.text('Generał'), findsOneWidget);
});
```

Run: `cd mobile && flutter test test/app_smoke_test.dart`

Expected: FAIL because `MobileYatzeeApp` does not exist.

- [ ] **Step 3: Add the minimal application root**

```dart
class MobileYatzeeApp extends StatelessWidget {
  const MobileYatzeeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: Text('Generał'))),
      );
}
```

`main.dart` must call `runApp(const ProviderScope(child: MobileYatzeeApp()))`.

- [ ] **Step 4: Add the complete mobile gate**

`mobile/tool/verify.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
dart format --output=none --set-exit-if-changed lib test integration_test 2>/dev/null || \
  dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Run: `cd mobile && chmod +x tool/verify.sh && ./tool/verify.sh`

Expected: formatting, analysis, and one smoke test pass.

- [ ] **Step 5: Commit and complete checkpoint 3**

```bash
git add mobile README.md codex/reviews/checkpoint-3-flutter-foundation.md
git commit -m "build: scaffold Flutter mobile app"
```

Follow the repository checkpoint gate, including independent review and `--no-ff` merge.

### Task 4: Shared fixture schema and Polish Generał engine

**Files:**
- Create: `rulesets/conformance.schema.json`
- Create: `rulesets/polish-general-v1.json`
- Create: `mobile/lib/src/game/domain/dice.dart`
- Create: `mobile/lib/src/game/domain/category.dart`
- Create: `mobile/lib/src/game/domain/score_sheet.dart`
- Create: `mobile/lib/src/game/rules/ruleset.dart`
- Create: `mobile/lib/src/game/rules/score_evaluation.dart`
- Create: `mobile/lib/src/game/rules/polish_general_ruleset.dart`
- Create: `mobile/test/support/conformance_fixture.dart`
- Create: `mobile/test/game/rules/polish_general_ruleset_test.dart`
- Modify: `mobile/pubspec.yaml` to include `../rulesets/*.json` test assets or load fixtures by repository-relative path in tests.

**Interfaces:**
- Consumes: none.
- Produces: `DiceRoll`, `CategoryId`, `ScoreSheet`, `Ruleset.evaluate(CategoryId, DiceRoll, ScoreSheet)`, and versioned JSON fixture schema used by Java later.

- [ ] **Step 1: Define fixture and Dart contracts**

Use this fixture shape:

```json
{
  "ruleset": "polish-general",
  "version": 1,
  "cases": [
    {
      "name": "four sixes in three-kind counts three dice",
      "dice": [6, 6, 6, 6, 2],
      "category": "three-kind",
      "priorState": {"scores": {}, "repeatedFiveOfAKindBonusTotal": 0},
      "selectable": true,
      "valid": true,
      "score": 18,
      "bonusDelta": 0
    }
  ]
}
```

Define exact signatures:

```dart
typedef CategoryId = String;

final class DiceRoll {
  DiceRoll(List<int> values);
  List<int> get values;
  Map<int, int> get counts;
  int get sum;
}

abstract interface class Ruleset {
  String get id;
  int get version;
  List<CategoryDefinition> get categories;
  ScoreEvaluation evaluate(CategoryId category, DiceRoll roll, ScoreSheet sheet);
  ScoreTotals totals(ScoreSheet sheet);
}
```

- [ ] **Step 2: Write failing validation and scoring tests**

Tests must reject fewer/more than five dice and faces outside 1–6, then load every fixture. Include explicit assertions:

```dart
expect(evaluate([6, 6, 6, 6, 2], 'three-kind').score, 18);
expect(evaluate([6, 6, 6, 6, 6], 'four-kind').score, 24);
expect(evaluate([1, 2, 3, 4, 5], 'small-straight').score, 15);
expect(evaluate([2, 3, 4, 5, 6], 'large-straight').score, 20);
expect(evaluate([6, 6, 6, 6, 6], 'general').score, 80);
```

Run: `cd mobile && flutter test test/game/rules/polish_general_ruleset_test.dart`

Expected: FAIL because domain and ruleset classes are absent.

- [ ] **Step 3: Implement immutable score evaluation**

`ScoreEvaluation` must distinguish qualification from score:

```dart
final class ScoreEvaluation {
  const ScoreEvaluation({
    required this.selectable,
    required this.qualifies,
    required this.score,
    this.bonusDelta = 0,
  });
  final bool selectable;
  final bool qualifies;
  final int score;
  final int bonusDelta;
}
```

`selectable=false` represents a rules constraint such as classic forced-upper joker placement; it is different from a non-qualifying roll that may be sacrificed for zero. Implement all thirteen categories, upper subtotal, the `>= 63` fifty-point bonus, and final total. Do not place localized strings in these files.

- [ ] **Step 4: Expand fixtures across every category boundary**

Include zero/miss cases, `62` versus `63` upper subtotal, exact full house, wrong straight, five-of-a-kind reuse in three/four-kind, and minimum/maximum scores. Run:

```bash
cd mobile
flutter test test/game/rules/polish_general_ruleset_test.dart
./tool/verify.sh
```

Expected: all fixture cases and the complete gate pass.

- [ ] **Step 5: Commit and complete checkpoint 4**

```bash
git add rulesets mobile/lib/src/game mobile/test mobile/pubspec.yaml codex
git commit -m "feat: add Polish General scoring engine"
```

### Task 5: Classic Yahtzee and Scandinavian Yatzy engines

**Files:**
- Create: `rulesets/classic-yahtzee-v1.json`
- Create: `rulesets/scandinavian-yatzy-v1.json`
- Create: `mobile/lib/src/game/rules/classic_yahtzee_ruleset.dart`
- Create: `mobile/lib/src/game/rules/scandinavian_yatzy_ruleset.dart`
- Create: `mobile/lib/src/game/rules/ruleset_registry.dart`
- Create: `mobile/test/game/rules/classic_yahtzee_ruleset_test.dart`
- Create: `mobile/test/game/rules/scandinavian_yatzy_ruleset_test.dart`
- Create: `mobile/test/game/rules/ruleset_registry_test.dart`

**Interfaces:**
- Consumes: Task 4 `Ruleset`, `ScoreSheet`, and fixture format.
- Produces: `RulesetRegistry.require(String id, int version)` containing exactly the three v1 rulesets.

- [ ] **Step 1: Write failing registry and fixture tests**

```dart
expect(registry.require('classic-yahtzee', 1), isA<ClassicYahtzeeRuleset>());
expect(registry.require('scandinavian-yatzy', 1), isA<ScandinavianYatzyRuleset>());
expect(() => registry.require('classic-yahtzee', 2), throwsUnsupportedError);
```

Add classic fixtures for upper bonus 35, full house 25, small/large straight 30/40, first Yahtzee 50, repeat bonus 100, forced matching upper, joker fixed scores, Yahtzee-box-zero behavior, and forced zero in an unused upper category after all lower categories are filled.

Add Scandinavian fixtures for highest pair, two distinct pairs, exact three/four-kind score, exact full house, fixed straights, upper bonus 50, and Yatzy 50 with no repeat bonus.

- [ ] **Step 2: Verify the new tests fail**

Run:

```bash
cd mobile
flutter test test/game/rules/classic_yahtzee_ruleset_test.dart
flutter test test/game/rules/scandinavian_yatzy_ruleset_test.dart
flutter test test/game/rules/ruleset_registry_test.dart
```

Expected: FAIL because implementations and registry are absent.

- [ ] **Step 3: Implement both rulesets without branching UI code**

Expose ordered `CategoryDefinition` lists and keep special repeat-Yahtzee policy inside `ClassicYahtzeeRuleset`. `RulesetRegistry` uses the immutable key `${id}:v$version` and throws on unknown versions.

- [ ] **Step 4: Run all cross-ruleset tests**

Run: `cd mobile && flutter test test/game/rules && ./tool/verify.sh`

Expected: every JSON case passes and each ruleset reports 13, 13, and 15 categories respectively.

- [ ] **Step 5: Commit and complete checkpoint 5**

```bash
git add rulesets mobile/lib/src/game/rules mobile/test/game/rules codex
git commit -m "feat: add classic and Scandinavian rulesets"
```

### Task 6: Deterministic game session reducer

**Files:**
- Create: `mobile/lib/src/game/session/dice_roller.dart`
- Create: `mobile/lib/src/game/session/game_mode.dart`
- Create: `mobile/lib/src/game/session/player.dart`
- Create: `mobile/lib/src/game/session/game_session.dart`
- Create: `mobile/lib/src/game/session/game_command.dart`
- Create: `mobile/lib/src/game/session/game_reducer.dart`
- Create: `mobile/test/game/session/game_reducer_test.dart`
- Create: `mobile/test/game/session/complete_game_test.dart`

**Interfaces:**
- Consumes: Task 5 `RulesetRegistry` and scoring contracts.
- Produces: pure `GameReducer.apply(GameSession, GameCommand, DiceRoller)` and serializable `GameSession` state.

- [ ] **Step 1: Define commands and invariants in failing tests**

```dart
sealed class GameCommand { const GameCommand(); }
final class RollDice extends GameCommand { const RollDice(); }
final class ToggleHold extends GameCommand { const ToggleHold(this.index); final int index; }
final class SelectCategory extends GameCommand {
  const SelectCategory(this.category, {this.confirmZero = false});
  final CategoryId category;
  final bool confirmZero;
}
```

Tests cover: no holds before first roll, held dice unchanged, fourth roll rejected, used category rejected, invalid category requires `confirmZero`, a legitimate upper zero does not require sacrifice confirmation, turn advances after scoring, and final round completes the game.

- [ ] **Step 2: Verify reducer tests fail**

Run: `cd mobile && flutter test test/game/session/game_reducer_test.dart`

Expected: FAIL because session types are absent.

- [ ] **Step 3: Implement reducer and injectable randomness**

```dart
abstract interface class DiceRoller {
  List<int> roll(int count);
}

final class GameReducer {
  GameSession apply(GameSession state, GameCommand command, DiceRoller roller);
}
```

Use `Random.secure()` only in `SecureDiceRoller`; tests inject a queue-based fake. Reducer returns a new immutable state and never performs I/O.

- [ ] **Step 4: Prove complete solo and four-player games**

Drive every category using deterministic rolls. Assert round count, player order, bonuses, totals, winner ordering, and completion exactly once.

Run: `cd mobile && flutter test test/game/session && ./tool/verify.sh`

- [ ] **Step 5: Commit and complete checkpoint 6**

```bash
git add mobile/lib/src/game/session mobile/test/game/session codex
git commit -m "feat: add deterministic game session engine"
```

### Task 7: Drift persistence, autosave, and application controllers

**Files:**
- Create: `mobile/lib/src/local/app_database.dart`
- Create: `mobile/lib/src/local/tables/active_games.dart`
- Create: `mobile/lib/src/local/tables/completed_games.dart`
- Create: `mobile/lib/src/local/tables/preferences.dart`
- Create: `mobile/lib/src/local/game_snapshot_codec.dart`
- Create: `mobile/lib/src/game/data/game_repository.dart`
- Create: `mobile/lib/src/game/data/drift_game_repository.dart`
- Create: `mobile/lib/src/game/domain/completed_game.dart`
- Create: `mobile/lib/src/game/application/game_controller.dart`
- Create: `mobile/lib/src/game/application/providers.dart`
- Create: `mobile/test/local/game_snapshot_codec_test.dart`
- Create: `mobile/test/local/drift_game_repository_test.dart`
- Create: `mobile/test/game/application/game_controller_test.dart`

**Interfaces:**
- Consumes: Task 6 immutable `GameSession` and commands.
- Produces: `GameRepository`, `GameController`, active-game watch stream, completed-game history, local latest-ten average.

- [ ] **Step 1: Write failing round-trip and transition tests**

```dart
abstract interface class GameRepository {
  Future<void> saveActive(GameSession session);
  Future<GameSession?> loadActive(String gameId);
  Future<void> complete(GameSession session);
  Stream<List<CompletedGame>> watchCompleted({String? rulesetId});
}
```

`CompletedGame` contains game UUID, mode, ruleset ID/version, player score sheets/totals, completion instant, and ranked-intent flag; network owner/submission fields are added by Plan 3.

For each command type, apply it through `GameController`, recreate the controller/database, and assert the restored state equals the post-command state. Include third roll before scoring, zero confirmation, player transition, and final completion transaction.

- [ ] **Step 2: Verify tests fail**

Run: `cd mobile && flutter test test/local test/game/application`

Expected: FAIL because repository/controller do not exist.

- [ ] **Step 3: Implement schema version 1 and atomic completion**

Store snapshots as versioned JSON with `snapshotVersion`, ruleset ID/version, players, active index, roll count, dice, holds, and score sheets. `complete()` must insert the completed result and remove the active snapshot in one Drift transaction.

- [ ] **Step 4: Implement Riverpod controller and local latest-ten statistic**

`GameController` extends `Notifier<AsyncValue<GameSession>>`; every successful reducer transition awaits `saveActive` before publishing success. Calculate each ruleset's latest-ten average from completed local solo games, including unranked results.

- [ ] **Step 5: Run persistence gate**

Run:

```bash
cd mobile
dart run build_runner build --delete-conflicting-outputs
flutter test test/local test/game/application
./tool/verify.sh
```

Expected: every transition survives repository recreation; no generated-file diff remains after a second build.

- [ ] **Step 6: Commit and complete checkpoint 7**

```bash
git add mobile/lib/src/local mobile/lib/src/game mobile/test mobile/pubspec.yaml codex
git commit -m "feat: persist and resume local games"
```

### Task 8: Modern Tabletop UI, localization, and accessibility

**Files:**
- Create: `mobile/l10n.yaml`
- Create: `mobile/lib/l10n/app_pl.arb`
- Create: `mobile/lib/l10n/app_en.arb`
- Create: `mobile/lib/src/theme/modern_tabletop_theme.dart`
- Create: `mobile/lib/src/home/home_screen.dart`
- Create: `mobile/lib/src/game/presentation/game_setup_screen.dart`
- Create: `mobile/lib/src/game/presentation/game_screen.dart`
- Create: `mobile/lib/src/game/presentation/widgets/dice_tray.dart`
- Create: `mobile/lib/src/game/presentation/widgets/scorecard.dart`
- Create: `mobile/lib/src/game/presentation/widgets/player_header.dart`
- Create: `mobile/lib/src/game/presentation/zero_score_dialog.dart`
- Create: `mobile/test/game/presentation/game_screen_test.dart`
- Create: `mobile/test/game/presentation/scorecard_accessibility_test.dart`
- Create: `mobile/test/goldens/modern_tabletop_test.dart`
- Create: `mobile/test/goldens/baselines/` generated PNGs

**Interfaces:**
- Consumes: Task 7 Riverpod providers and localized keys from rule/category definitions.
- Produces: portrait setup/game/home flows with no scoring logic in widgets.

- [ ] **Step 1: Write failing Polish/English and interaction widget tests**

Pump the game in each locale. Verify setup limits players to 2–4 for pass-and-play, all player columns are visible, active column has both semantic label and gold styling, dice expose face/held semantics, roll button disables after roll three, and invalid scoring opens the zero dialog.

```dart
expect(
  tester.getSemantics(find.byKey(const Key('player-column-p2'))),
  matchesSemantics(label: contains('aktywny gracz')),
);
```

- [ ] **Step 2: Verify widget tests fail**

Run: `cd mobile && flutter test test/game/presentation`

- [ ] **Step 3: Implement ARB localization and theme tokens**

Define felt `#123C2F`, ivory `#F4EAD2`, gold `#C99A2E`, readable error/success colors, spacing, radius, elevation, and typography in one `ThemeExtension`. Generate localization with `flutter gen-l10n`; category IDs map to ARB keys in presentation only.

- [ ] **Step 4: Implement focused widgets**

`GameScreen` composes `PlayerHeader`, `DiceTray`, and `Scorecard`. `Scorecard` renders rows from `Ruleset.categories`, uses one fixed category column plus `Expanded` player columns, and provides text/icon state in addition to color.

- [ ] **Step 5: Add golden and large-text cases**

Capture solo, two-player, and four-player screens at representative portrait sizes in Polish and English, plus text scale `2.0`. Fail tests on overflow, clipped total, missing active semantics, or inaccessible dice.

Run: `cd mobile && flutter test --update-goldens test/goldens/modern_tabletop_test.dart` once to establish reviewed baselines, then `./tool/verify.sh` without update mode.

- [ ] **Step 6: Commit and complete checkpoint 8**

```bash
git add mobile/lib mobile/test mobile/l10n.yaml mobile/pubspec.yaml codex
git commit -m "feat: add localized Modern Tabletop game UI"
```

### Task 9: Local history, statistics, and installable alpha

**Files:**
- Create: `mobile/lib/src/history/history_screen.dart`
- Create: `mobile/lib/src/history/local_statistics.dart`
- Create: `mobile/lib/src/settings/settings_screen.dart`
- Create: `mobile/integration_test/local_game_flow_test.dart`
- Modify: `mobile/lib/src/app.dart`
- Modify: `mobile/android/app/src/main/AndroidManifest.xml`
- Modify: `mobile/ios/Runner/Info.plist`
- Modify: `README.md`
- Modify: `codex/progress.md`
- Create: `codex/reviews/checkpoint-9-local-alpha.md`

**Interfaces:**
- Consumes: complete local game stack.
- Produces: installable local alpha and stable navigation seams later plans extend.

- [ ] **Step 1: Write failing local-statistics tests**

Create 12 completed solo games across two rulesets. Assert each ruleset uses only its latest ten by completion time, pass-and-play is excluded, averages retain exact numeric value, and an empty history renders a localized empty state.

- [ ] **Step 2: Implement history/settings navigation**

Home exposes New Game, Resume, History, and Settings. Settings chooses locale/system default, reduced motion override, and last-used ruleset. History shows result, ruleset version, completion time, and local latest-ten average clearly labeled as local.

- [ ] **Step 3: Add the end-to-end local flow**

`local_game_flow_test.dart` must start in Polish, create a four-player Generał game, roll/hold/score, restart the app process binding, resume exact state, finish a deterministic solo game, and see it in history. Use dependency overrides for deterministic dice rather than tapping until a roll appears.

- [ ] **Step 4: Run full local alpha verification**

```bash
cd mobile
./tool/verify.sh
flutter test integration_test/local_game_flow_test.dart
flutter build apk --debug
flutter build ios --simulator --no-codesign
```

Expected: all checks pass and both debug artifacts build. Record simulator/device limitations precisely.

- [ ] **Step 5: Update verified README behavior and commit**

Describe only flows proven by the gate. Record command output and independent review in `codex/reviews/checkpoint-9-local-alpha.md`.

```bash
git add mobile README.md codex
git commit -m "feat: complete offline local game alpha"
```

Complete checkpoint 9 and tag the merged commit locally as `local-alpha` only if the user explicitly asks for a tag.
