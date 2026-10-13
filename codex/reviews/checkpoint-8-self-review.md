# Checkpoint 8 self-review

## Scope

Reviewed the localized application root, Modern Tabletop theme, home/setup/game screens, focused presentation widgets, ARB and generated localization files, interaction/accessibility tests, and six golden baselines.

## TDD evidence

- Initial presentation RED: `flutter test test/game/presentation` failed to compile because the ARB-generated localization and planned presentation types did not yet exist.
- Initial GREEN: the focused presentation suite passed 7 tests after the first implementation.
- Upper-section zero RED: `also confirms a zero in an upper category` failed because only non-qualifying lower-section zeroes opened the confirmation dialog. The UI now confirms every selectable zero result; the targeted test passed.
- Persistence-in-flight RED: `disables commands while a save is pending` found the roll action still enabled during an outstanding write. A local presentation busy state now disables roll, hold, scoring, and retry actions and exposes progress; the targeted test and 9-test presentation suite passed.
- Completion RED: `announces a completed game` failed because completion had no visible announcement. The localized, live-region completion chip made the targeted test pass.
- Navigation integration RED: `real home setup flow starts and plays a scoped local game` reached the game screen but the controller could not resolve the nested session override. Declaring the initial-session provider as a scoped dependency of the controller made the real home/setup/game path save its first roll.
- Later-save error RED: after one successful roll and a failed second save, roll, hold, and score actions remained enabled alongside retry. The game screen now treats a controller error as a pending persistence transition and exposes retry as the only game action until that transition succeeds.
- Completed-player semantics RED: a completed scorecard still tinted and announced the last active player. Completed sessions now remove the active gold treatment and active-player semantic label.
- Combined stress-golden RED: the existing baselines covered four players and text scale 2.0 separately, so no baseline exercised four genuinely long names at scale 2.0 on the same constrained portrait. The sixth golden now combines those constraints and asserts the complete player-header semantics.

## Golden review

Generated and inspected these portrait baselines:

- `solo-pl.png`
- `solo-en.png`
- `two-player-en.png`
- `four-player-pl.png`
- `two-player-large-text.png` at 320 by 700 logical pixels and text scale 2.0
- `four-player-long-names-large-text.png` at 360 by 780 logical pixels, four long names, and text scale 2.0

The reviewed images retain the full score table width, a gold active-player column, usable dice and action regions, and a vertically scrollable scorecard without overflow markers. Visual inspection of the combined stress baseline confirmed that all four columns and the active gold treatment remain visible without overflow. Flutter's Ahem test font limits judgment of production glyph shapes, but does not weaken the column, clipping, or overflow check. A non-update golden run passed all six cases after generation.

## Findings

- **Important — fixed during self-review:** the theme extension defined the requested tokens, but several presentation widgets repeated literal tabletop colors and sizing values. `GameScreen`, `DiceTray`, `PlayerHeader`, and `Scorecard` were changed to consume `TabletopTheme`.
- **Important — fixed after independent review:** a game created through the real navigation path lost the nested `initialGameSessionProvider` override when resolving `gameControllerProvider`. Explicit Riverpod provider dependencies now preserve the scoped session.
- **Important — fixed after independent review:** a failed save after an earlier success left game commands enabled while the controller retained a pending transition. Roll, hold, and category actions are now disabled in the error state until retry succeeds.
- **Important — fixed after independent review:** completed games retained the final active-player tint and announcement. Active treatment and semantics are now conditional on the game remaining incomplete.
- **Important — fixed after independent review:** golden coverage did not combine the maximum four player columns, four genuinely long names, text scale 2.0, and a constrained portrait. The combined baseline and exact semantics assertions now cover that case.
- **Minor — fixed after independent review:** home, setup, and scorecard still repeated common layout values and left `bodyStyle` unused after the first theme cleanup. `TabletopTheme` now owns compact spacing and screen padding as well as body typography; component-specific scorecard width and row height remain local.
- No scoring or persistence behavior was moved into widgets. Category preview calls the selected versioned ruleset and all mutations still go through `GameController` commands.
- Setup creates UUID game/player identifiers and injects the new session through the existing initial-session provider. No domain or controller contract changed.

## Verification

- `flutter gen-l10n`: passed.
- `dart format lib test`: 61 files checked with zero changes.
- `flutter analyze`: no issues.
- Focused navigation, game, accessibility, and golden verification: 17/17 passed.
- Golden generation and non-update verification: 6/6 passed in each run.
- `./tool/verify.sh`: formatting passed, analysis clean, 77/77 tests passed.
- `git diff --check`: passed after this evidence update.

All independent-review findings have fixes and green local evidence. Scoped independent re-review inspected the provider scope, retry-only error state, completed semantics, combined stress golden, and theme tokens; it approved the fixes with no remaining Critical, Important, or Minor findings. Broad final review remains required before the checkpoint can proceed to push and merge.
