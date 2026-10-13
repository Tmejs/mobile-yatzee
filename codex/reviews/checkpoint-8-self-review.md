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
- Broad-final locale RED: `uses the supported English device locale` found that the production application forced Polish even when the device preferred English. The application now follows supported Polish or English device preferences, falls back to Polish for unsupported languages, and retains explicit locale injection for deterministic tests.
- The first unsupported-locale regression used `localeTestValue` and failed for the wrong reason because Flutter's `LocalizationsResolver` reads `platformDispatcher.locales`. Reading the Flutter 3.47 resolver and test binding identified the mismatch; the test now sets and clears `localesTestValue`, proving the real device-locale path and Polish fallback.
- Broad-final score-preview RED: after a roll, positive and zero active-player cells still displayed an em dash, semantics said only “not scored,” and Classic forced-placement cells had no non-color state cue. Ruleset evaluations now feed presentation-only previews, cells show projected values, check/add/block icons distinguish recorded/selectable/unavailable states, inactive players receive no preview, and Polish and English semantics announce score availability and active state.
- Locale-change integration RED: the full gate exposed that the Polish-label home-flow test had depended on the removed production locale override. That deterministic test now injects Polish explicitly; product locale negotiation remains unchanged.

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
- **Important — fixed and independently re-reviewed:** `MobileYatzeeApp` hard-forced Polish, ignoring a supported English device locale. It now resolves supported device languages and uses Polish only as the unsupported-locale fallback; optional explicit locale injection remains available for tests.
- **Important — fixed and independently re-reviewed:** unused active-player score cells discarded the ruleset's evaluated score and exposed neither availability nor a non-color status. Presentation-only previews now retain the evaluated score/selectability, while scoring and mutations remain owned by the ruleset and controller respectively.
- No scoring or persistence behavior was moved into widgets. Category preview calls the selected versioned ruleset and all mutations still go through `GameController` commands.
- Setup creates UUID game/player identifiers and injects the new session through the existing initial-session provider. No domain or controller contract changed.

## Verification

- `flutter gen-l10n`: passed.
- `dart format lib test`: 61 files checked with zero changes.
- `flutter analyze`: no issues.
- Focused locale, game, and accessibility verification after the broad-review fixes: 16/16 passed.
- Golden generation and non-update verification: 6/6 passed in each run, with no baseline byte changes.
- Deterministic Polish home-flow verification: 1/1 passed.
- `./tool/verify.sh`: formatting checked 61 files with zero changes, analysis was clean, and 81/81 tests passed.
- `git diff --check`: passed after this evidence update.

All task-review and broad-final findings have fixes and green local evidence. The first scoped independent re-review approved the provider, retry, completion, stress-golden, and theme fixes. The final scoped re-review approved device locale resolution and live score previews with no remaining Critical, Important, or Minor findings. The checkpoint may proceed to exact-head verification, push, and merge.
