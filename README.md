# Mobile Yatzee

Mobile Yatzee is a Flutter and Spring Boot dice game planned for iOS and Android. The approved design covers solo score challenges, local pass-and-play, versioned Generał/Yahtzee/Yatzy rulesets, localization, offline play, Apple/Google-linked ranked profiles, weekly country/continent/global rankings, and a staged ads-plus-lifetime-Premium business model.

The Flutter mobile foundation starts in a Riverpod `ProviderScope` and shows the Polish home title “Generał”. A Dart Polish Generał v1 scoring engine now covers all thirteen categories and the upper-section bonus, with shared JSON conformance fixtures. The playable game flow and backend behavior remain planned.

Run the local mobile verification gate with `cd mobile && ./tool/verify.sh`. It checks Dart formatting, Flutter analysis, and Flutter tests.

- [Product and architecture design](codex/design.md)
- [Git and GitHub workflow](codex/git-workflow.md)
- [Codex collaboration records](codex/README.md)
