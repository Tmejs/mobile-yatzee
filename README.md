# Mobile Yatzee

Mobile Yatzee is a Flutter and Spring Boot dice game planned for iOS and Android. The approved design covers solo score challenges, local pass-and-play, versioned Generał/Yahtzee/Yatzy rulesets, localization, offline play, Apple/Google-linked ranked profiles, weekly country/continent/global rankings, and a staged ads-plus-lifetime-Premium business model.

The Flutter mobile foundation starts in a Riverpod `ProviderScope` and shows the Polish home title “Generał”. Pure Dart scoring engines cover Polish Generał v1, Classic Yahtzee v1, and Scandinavian Yatzy v1, with 13, 13, and 15 ordered categories. A versioned registry resolves these three engines, and shared JSON conformance fixtures cover their scoring and bonus rules. The playable game flow and backend behavior remain planned.

Run the local mobile verification gate with `cd mobile && ./tool/verify.sh`. It checks Dart formatting, Flutter analysis, and Flutter tests.

- [Product and architecture design](codex/design.md)
- [Git and GitHub workflow](codex/git-workflow.md)
- [Codex collaboration records](codex/README.md)
