# Project progress

## Repository bootstrap

- Initial product and architecture design recorded.
- Git/GitHub checkpoint workflow established.
- Independent documentation review passed.
- Integrated on `main` at `d1accf1`.

## Checkpoint 1 — identity and monetization design

- Guest-first identity and ranked-account boundaries specified.
- Apple/Google exchange, linking, recovery, sessions, deletion, and tests specified.
- Guest result claim and ownership rules specified.
- Early-access and wider-release monetization stages specified.
- Lifetime Premium, advertising cadence, consent, entitlements, and tests specified.
- Independent review and final re-review passed with no remaining Critical or Important findings.
- Written design approved by the user on 2026-09-28.

## Checkpoint 2 — implementation planning

- Written design approved by the user.
- Delivery decomposed into offline Flutter, ranked Spring backend, mobile/backend integration, and post-retention monetization plans.
- Checkpoints 3–20 define task-level files, interfaces, red-green verification, commits, and release milestones.
- Independent review and all repeat reviews passed with no remaining Critical, Important, or Minor findings.
- Plans await user review and execution-method selection.

## Checkpoint 3 — Flutter foundation

- Flutter 3.47.3/Dart 3.13.3 Android/iOS project scaffolded with pinned Riverpod and Drift dependencies.
- Riverpod application root and Polish `Generał` smoke screen implemented through a stable localization key.
- Android and iOS installed app labels aligned to `Generał`.
- Local mobile gate covers formatting, analysis, and Flutter tests.
- The gate restores Flutter packages before formatting and passes from a dependency-free checkout without package-resolution warnings.
- Test-first RED/GREEN evidence recorded for the application root, localization boundary, and platform labels.
- Task review, scoped re-review, broad final review, and post-merge verification-fix review passed with no remaining Critical, Important, or Minor findings.
- Native device/simulator builds are deferred to their planned later checkpoints.

## Checkpoint 4 — Polish Generał scoring engine

- Added immutable dice, score-sheet, evaluation, and ruleset contracts for Polish Generał v1.
- Added a versioned shared JSON fixture schema and 34 Polish Generał conformance cases.
- Focused Dart tests and the full local mobile gate pass. Java conformance starts with backend Task 10.
- Independent task review and broad final review passed. The final review's one Minor fixture-coverage finding was fixed and independently re-reviewed with no remaining findings.

## Checkpoint 5 — additional rulesets

- Added Classic Yahtzee v1 and Scandinavian Yatzy v1 scoring engines and an immutable versioned registry for the three v1 rulesets.
- Added 35 Classic and 27 Scandinavian shared JSON conformance cases. The existing 34 Polish cases remain unchanged.
- Captured RED runs for all three new test files before implementation; focused rules tests, the complete mobile gate, JSON integrity checks, and staged `git diff --check` passed.
- Independent task review found one Important and one Minor fixture-coverage gap; both were fixed with focused mutation evidence and passed scoped re-review.
- Broad final review and its documentation-fix re-review passed with no remaining Critical, Important, or Minor findings.

## Checkpoint 6 — deterministic game session reducer

- Added immutable, restorable session and player state for solo and two-to-four-player local games. A pure reducer applies rolls, holds, category selection, turn rotation, and completion through the versioned ruleset registry.
- Focused session tests cover all three complete solo scorecards, complete four-player and tied two-player games, rejected commands, bonus totals, and stable standings.
- The focused session suite (26 tests), rules suite (12 tests), full mobile gate (41 tests), formatting, and analysis pass locally after two review fixes for restored scorecard validation, including Classic repeat-bonus placement feasibility.
- Task review, both scoped re-reviews, broad final review, and the final test-fix re-review passed with no remaining Critical, Important, or Minor findings.

## Checkpoint 7 — local persistence and autosave

- Added Drift schema v1 for active games, completed games, and preferences, with generated schema code committed.
- Versioned snapshots retain the game ID, ranked intent, ruleset, mode, players and scores, turn position, dice, and holds. Completion writes immutable history and removes the active row in one transaction.
- Riverpod game controller persists each successful command before publishing it, retains a failed transition for explicit retry, and coalesces overlapping retry calls. The repository exposes active/history streams and a latest-ten solo average scoped to ruleset version. Completion instants retain microsecond precision for ordering.
- RED runs were captured before implementation and for two review fixes. The focused local/application suite (14 tests), complete mobile gate (55 tests), formatting, analysis, and diff check passed. A second code-generation run wrote zero outputs and kept the generated database file hash unchanged.
- Handoff self-review found and fixed two Important issues: overlapping retries could publish an error after a successful save, and Drift's default timestamp mapping lost subsecond precision.
- Task-review fix round 1 addressed two further Important controller races: a success listener could start a transition that reused the old completed attempt, and a delayed save from a replaced session could publish into the new session. Controlled listener and delayed success/failure regressions passed; focused suite: 17 tests; full gate: 58 tests, formatting unchanged, analysis clean.
- Scoped re-review passed 19 repository tests and three additional lifecycle checks with no findings. Broad final review repeated the focused suite and full gate and found no Critical or Important findings; its only Minor documentation finding was this stale review status, now corrected before exact-head verification.

## Checkpoint 8 — Modern Tabletop UI and localization

- Added Polish and English ARB localization with a Polish fallback for unsupported device locales, a centralized Modern Tabletop theme, and portrait home, setup, and game flows.
- Setup supports solo and two-to-four-player pass-and-play games across all three versioned rulesets and creates UUID-backed local sessions.
- The game screen keeps every score column visible, combines a gold active-player treatment with full-name semantics, exposes localized die/hold semantics, confirms every zero score, disables actions while persistence is pending, and provides localized completion and retry states.
- The application follows supported Polish or English device preferences, falls back to Polish for unsupported locales, and permits explicit locale injection for deterministic tests. After a roll, the active player's unused cells show ruleset-evaluated positive or zero previews; recorded, selectable, and unavailable states use localized semantics plus check/add/block icons, while inactive columns remain unpreviewed.
- Test-first cycles cover localization, player limits, four-column active state, dice and three-roll behavior, zero confirmation/cancel, completion, pending writes, persistence retry, and focused scorecard accessibility.
- Six reviewed portrait baselines cover solo, two-player, four-player, Polish, English, a constrained text-scale-2.0 layout, and a combined four-long-name/text-scale-2.0 stress case. All four stress-case columns and the active gold treatment remain visible without overflow; non-update golden verification passed 6/6.
- Self-review fixed one Important theme-token issue. Independent review then found four Important integration, error-state, completion-semantics, and combined-golden gaps plus one Minor residual token-centralization issue. Controlled RED tests reproduced each behavioral gap; the fixes preserve scoped sessions, make retry the only action after a failed later save, remove active treatment from completed games, assert all player semantics in the combined golden, and reuse layout/body tokens without changing domain or persistence semantics.
- Broad final review found two additional Important gaps: production forced Polish instead of honoring supported device locales, and scorecard cells discarded live evaluated scores and availability. Both have controlled RED/GREEN coverage without domain or persistence changes. The corrected focused suite passed 16/16, golden update and non-update runs passed 6/6 with no baseline changes, the deterministic Polish home flow passed 1/1, the full gate passed formatting (61 files, zero changes), clean analysis, and 81/81 tests, and `git diff --check` passed. Scoped re-review approved both fixes with no remaining Critical, Important, or Minor findings. Push, merge, and synchronization remain pending.
