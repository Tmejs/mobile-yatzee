# Mobile Yatzee

Mobile Yatzee is a Flutter and Spring Boot dice game planned for iOS and Android. The approved design covers solo score challenges, local pass-and-play, versioned Generał/Yahtzee/Yatzy rulesets, localization, offline play, Apple/Google-linked ranked profiles, weekly country/continent/global rankings, and a staged ads-plus-lifetime-Premium business model.

The Flutter app provides localized Polish and English home, setup, and game flows in the Modern Tabletop visual style. Players can start a solo challenge or a local two-to-four-player pass-and-play game with Polish Generał v1, Classic Yahtzee v1, or Scandinavian Yatzy v1. The scorecard keeps all player columns visible and marks the active player with a gold treatment and accessibility label. Five localized dice support holds and three-roll turns, while zero scores require confirmation and persistence failures expose retry.

Pure Dart scoring engines and shared JSON conformance fixtures cover the three versioned rulesets. A pure immutable game-session reducer handles score selection, player rotation, completion, and deterministic standings. Restored scorecards are checked against the selected ruleset’s possible scores and repeat-bonus policy. Drift schema v1 stores versioned active-game snapshots, immutable completed results, and preferences. A Riverpod controller autosaves successful transitions and records completed games atomically; local history and the latest-ten solo average are available through the repository. Backend behavior remains planned.

Run the local mobile verification gate with `cd mobile && ./tool/verify.sh`. It checks Dart formatting, Flutter analysis, and Flutter tests.

- [Product and architecture design](codex/design.md)
- [Git and GitHub workflow](codex/git-workflow.md)
- [Codex collaboration records](codex/README.md)
