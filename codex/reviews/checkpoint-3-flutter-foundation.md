# Checkpoint 3: Flutter foundation verification

## Toolchain

Command: `PATH=/Users/matrzad/develop/flutter-3.47.3/flutter/bin:$PATH flutter --version`

```text
Flutter 3.47.3 • channel stable • https://github.com/flutter/flutter.git
Framework • revision e8113bf456 (4 weeks ago) • 2026-09-04 13:20:08 -0700
Engine • hash 0e228ec8c8d2abc9fcf1d053e8a40665bb859ec7 (revision 06a2e2a110) (29 days ago) • 2026-09-03 16:07:13.000Z
Tools • Dart 3.13.3 • DevTools 2.60.0
```

The SDK was installed for this checkpoint from the official Flutter 3.47.3 Apple Silicon release archive, and the archive checksum was verified. The SDK initialized its cache on first use.

## Test-driven root widget

Before adding `MobileYatzeeApp`, the scaffold's counter test was removed and `test/app_smoke_test.dart` was added. `lib/src/app.dart` existed as an empty library so the failure isolated the absent class.

RED command: `cd mobile && PATH=/Users/matrzad/develop/flutter-3.47.3/flutter/bin:$PATH flutter test test/app_smoke_test.dart` (exit 1)

```text
00:00 +0: loading /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart
test/app_smoke_test.dart:7:56: Error: Method not found: 'MobileYatzeeApp'.
    await tester.pumpWidget(const ProviderScope(child: MobileYatzeeApp()));
                                                       ^^^^^^^^^^^^^^^
00:00 +0 -1: loading /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart [E]
  Failed to load "/Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart":
  Compilation failed for testPath=/Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart: test/app_smoke_test.dart:7:56: Error: Method not found: 'MobileYatzeeApp'.
      await tester.pumpWidget(const ProviderScope(child: MobileYatzeeApp()));
                                                         ^^^^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart: loading /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart
```

GREEN command: `cd mobile && PATH=/Users/matrzad/develop/flutter-3.47.3/flutter/bin:$PATH flutter test test/app_smoke_test.dart` (exit 0)

```text
00:00 +0: loading /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart
00:00 +0: starts in Polish and shows the home title
00:00 +1: All tests passed!
```

## Complete local mobile gate

Command: `cd mobile && PATH=/Users/matrzad/develop/flutter-3.47.3/flutter/bin:$PATH ./tool/verify.sh` (exit 0)

```text
Formatted 3 files (0 changed) in 0.01 seconds.
Analyzing mobile...
No issues found! (ran in 5.4s)
00:00 +0: starts in Polish and shows the home title
00:00 +1: All tests passed!
```

`flutter analyze` and `flutter test` each also resolved dependencies successfully; pub reported 12 newer versions incompatible with current constraints. `git diff --check` exited 0 with no output. The app is limited to a smoke-tested root widget; device builds and gameplay were not part of this checkpoint.

## Review status

Self-review is recorded in the task report after the implementation commit. The initial independent task review found one Important localization-boundary issue and one Minor native-label inconsistency. Both were fixed in `121beac` and the scoped re-review confirmed that no Critical or Important issue remained.

## Review fix round 1

Independent review identified an Important localization issue: the home title was a domain-visible literal in the widget. It also identified a Minor inconsistency in installed Android/iOS names. The root now resolves `AppStringKey.homeTitle` through `AppStrings.polish`; Android uses `@string/app_name` backed by a Polish resource and iOS displays `Generał`.

Test-first evidence:

- `flutter test test/localization_test.dart` failed with undefined `AppStringKey` and `AppStrings`, then `flutter test test/localization_test.dart test/app_smoke_test.dart` passed both tests.
- `flutter test test/platform_labels_test.dart` failed because Android's manifest still used `android:label="mobile_yatzee"`, then passed after the platform label changes.
- Complete `./tool/verify.sh` passed: six Dart files formatted with zero changes, `flutter analyze` found no issues, and all three tests passed.
- `git diff --check` exited 0 with no output.

The exact RED/GREEN and gate outputs are retained in the ignored task workspace used during implementation.

## Final broad review

The final reviewer inspected the complete two-commit branch against the task brief, approved design, repository rules, and recorded verification evidence. The review found no Critical, Important, or Minor issues and judged the branch ready to merge within the foundation scope.

The review explicitly left gameplay, rules engines, persistence, backend integration, full ARB localization, Modern Tabletop styling, device builds, signing, and store preparation to their planned later checkpoints. Native builds remain unverified in this checkpoint.


## Post-merge review fix round 2: clean-checkout gate

A clean copy without `.dart_tool` or `build` exposed the gate defect: `dart format` ran before package resolution and emitted package-resolution warnings while the script still exited 0. `mobile/tool/verify.sh` now runs `flutter pub get` before formatting. Dependencies and the remaining format/analyze/test steps are unchanged. The README needed no change.

RED: copied `mobile/` to `/private/tmp/flutter-foundation-red.ev5IoT/mobile/` with `.dart_tool` and `build` excluded, then ran `PATH=/Users/matrzad/develop/flutter-3.47.3/flutter/bin:$PATH ./tool/verify.sh > gate.log 2>&1` from that copy. Script exit: 0; package-resolution warning present. Exact combined output:

```text
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/main.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/private/tmp/flutter-foundation-red.ev5IoT/mobile/analysis_options.yaml".
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/src/app.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/private/tmp/flutter-foundation-red.ev5IoT/mobile/analysis_options.yaml".
Warning: Package resolution error when reading "analysis_options.yaml" file for "lib/src/localization/app_strings.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/private/tmp/flutter-foundation-red.ev5IoT/mobile/analysis_options.yaml".
Warning: Package resolution error when reading "analysis_options.yaml" file for "test/app_smoke_test.dart":
Failed to resolve package URI "package:flutter_lints/flutter.yaml" in include at "/private/tmp/flutter-foundation-red.ev5IoT/mobile/analysis_options.yaml".
Formatted 6 files (0 changed) in 0.00 seconds.
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing mobile...\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
No issues found! (ran in 5.4s)
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/flutter-foundation-red.ev5IoT/mobile/test/platform_labels_test.dart
00:00 +0: /private/tmp/flutter-foundation-red.ev5IoT/mobile/test/platform_labels_test.dart: installed app labels use the Polish game title
00:00 +1: /private/tmp/flutter-foundation-red.ev5IoT/mobile/test/localization_test.dart: Polish home title resolves from a stable key
00:00 +2: /private/tmp/flutter-foundation-red.ev5IoT/mobile/test/app_smoke_test.dart: starts in Polish and shows the home title
00:00 +3: All tests passed!
```

GREEN: copied the updated `mobile/` to `/private/tmp/flutter-foundation-green.rvyW8d/mobile/` with `.dart_tool` and `build` excluded, then ran the same command. Script exit: 0. `rg -q 'Warning: Package resolution error' gate.log` found no match (`PACKAGE_WARNING_CHECK=PASS`). Exact combined output:

```text
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Formatted 6 files (0 changed) in 0.01 seconds.
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing mobile...\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
No issues found! (ran in 5.3s)
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/flutter-foundation-green.rvyW8d/mobile/test/platform_labels_test.dart
00:00 +0: /private/tmp/flutter-foundation-green.rvyW8d/mobile/test/platform_labels_test.dart: installed app labels use the Polish game title
00:00 +1: /private/tmp/flutter-foundation-green.rvyW8d/mobile/test/localization_test.dart: Polish home title resolves from a stable key
00:00 +2: /private/tmp/flutter-foundation-green.rvyW8d/mobile/test/app_smoke_test.dart: starts in Polish and shows the home title
00:00 +3: All tests passed!
```

Complete worktree gate: `cd mobile && PATH=/Users/matrzad/develop/flutter-3.47.3/flutter/bin:$PATH ./tool/verify.sh` (exit 0). Exact combined output:

```text
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Formatted 6 files (0 changed) in 0.01 seconds.
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing mobile...\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
No issues found! (ran in 5.4s)
Resolving dependencies...
Downloading packages...
  code_assets 1.2.1 (2.1.0 available)
  cupertino_icons 1.0.9 (2.0.0 available)
  drift 2.35.0 (2.35.1 available)
  hooks 2.0.2 (2.2.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  native_toolchain_c 0.19.2 (0.19.5 available)
  objective_c 9.5.0 (9.6.2 available)
  record_use 0.6.0 (1.1.1 available)
  sqlite3 3.5.2 (3.7.0 available)
  test_api 0.7.12 (0.7.14 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
12 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/platform_labels_test.dart
00:00 +0: /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/platform_labels_test.dart: installed app labels use the Polish game title
00:00 +1: /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/localization_test.dart: Polish home title resolves from a stable key
00:00 +2: /Users/matrzad/.codex/worktrees/checkpoint-1-design-auth/Logic game/mobile/test/app_smoke_test.dart: starts in Polish and shows the home title
00:00 +3: All tests passed!
```

`git diff --check` exited 0 with no output before recording this evidence; the staged diff was checked again before commit. No new independent review was dispatched in this focused fix round, as directed by the coordinating agent.

In the recorded gate logs above, trailing progress padding on `Analyzing mobile...` is encoded as `\x20` per space so the review record passes `git diff --check`. The ignored task report preserves the raw output.
