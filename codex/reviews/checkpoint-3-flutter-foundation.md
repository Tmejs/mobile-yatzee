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

Self-review is recorded in the task report after the implementation commit. Independent review and checkpoint push/merge are pending the coordinating agent.

## Review fix round 1

Independent review identified an Important localization issue: the home title was a domain-visible literal in the widget. It also identified a Minor inconsistency in installed Android/iOS names. The root now resolves `AppStringKey.homeTitle` through `AppStrings.polish`; Android uses `@string/app_name` backed by a Polish resource and iOS displays `Generał`.

Test-first evidence:

- `flutter test test/localization_test.dart` failed with undefined `AppStringKey` and `AppStrings`, then `flutter test test/localization_test.dart test/app_smoke_test.dart` passed both tests.
- `flutter test test/platform_labels_test.dart` failed because Android's manifest still used `android:label="mobile_yatzee"`, then passed after the platform label changes.
- Complete `./tool/verify.sh` passed: six Dart files formatted with zero changes, `flutter analyze` found no issues, and all three tests passed.
- `git diff --check` exited 0 with no output.

The exact RED/GREEN and gate outputs are retained in `.superpowers/sdd/01-offline-flutter-game/task-3-report.md`. Follow-up independent review remains with the coordinating agent.
