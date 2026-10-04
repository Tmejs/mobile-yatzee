# Checkpoint 5 review fixes, round 1

The independent task review found two fixture coverage gaps:

1. **Important:** Yahtzee-box-zero cases did not cover a five-of-a-kind scored in an unused lower category while its matching upper category remained open. A new `full-house` case has `yahtzee: 0`, an unused `sixes` box, five sixes, and expects `selectable: true`, `valid: false`, score 0, bonus delta 0, and all-zero totals. This catches an incorrect forced-upper policy and incorrect joker treatment together.
2. **Minor:** Classic small-straight fixtures did not cover the 3–4–5–6 four-face run. A new case uses `[3,4,5,6,6]` and expects 30.

Both cases were added before any production change. To verify they catch regressions, the Classic engine was temporarily mutated twice. A zero-box policy mutation made only the new lower-sacrifice case fail (`Expected: true`, `Actual: false`). A four-face-run bound mutation made only the new high-run case fail (`Expected: true`, `Actual: false`). The original engine was restored after each run; its final diff is empty.

With the correct engine, `flutter test test/game/rules` passed 13 test groups, and `./tool/verify.sh` passed formatting (21 files, 0 changes), analysis (no issues), and all 15 tests. Both new JSON files parse. A separate fixture integrity check recomputed totals and checked category/dice validity and unique names for 35 Classic and 27 Scandinavian cases. Java conformance remains unavailable until backend Task 10. Independent re-review is pending before push.
