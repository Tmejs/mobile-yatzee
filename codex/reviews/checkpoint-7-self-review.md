# Checkpoint 7 self-review

Reviewed implementation commit `9c2bbb6` and the handoff fixes against the Task 7 brief, session contracts, generated Drift schema, and tests.

## Findings

Two Important findings were fixed with regression tests. Independent review is still required by the repository gate.

1. Overlapping `retryPersistence()` calls could write the same pending transition twice. If one save succeeded and the other failed, the later failure could replace the successful public state with `AsyncError`. A failing regression reproduced two writes; the controller now shares one in-flight persistence attempt, and the test observes one write and a successful state.
2. Drift's default `DateTimeColumn` stores Unix seconds, so two completions within one second sorted by game ID rather than actual completion time. A failing regression reproduced the wrong order; the schema now stores UTC epoch microseconds as an integer. History and latest-ten queries sort by that value, and the test checks exact timestamp round trips.

## Reviewed behavior

- Schema v1 defines primary keys for active and completed game IDs and preferences keys. Generated `app_database.g.dart` contains all three tables; no migration from a previous application schema is required. Completed timestamps use epoch microseconds.
- Session IDs and ranked intent remain immutable through reducer transitions. Snapshots encode every restorable field and decode through `GameSession.restore`, which checks turn order, dice/holds, ruleset, scores, and bonuses.
- Active saves upsert by ID and reject a completed ID. Completion checks that a game is finished, inserts one immutable result, and deletes the active snapshot inside one transaction. Duplicate completion raises `StateError`.
- Completed history uses descending completion time and ascending game ID as a stable tie break. Latest-ten averages query only solo games for the exact ruleset ID and version, regardless of ranked intent; empty history returns `null`.
- Controller commands await repository writes before publishing the next state. On a write error, `AsyncError` is published while `lastPublished` and `pending` retain enough state for `retryPersistence()`. Overlapping retries share one write.
- Restart tests reopen SQLite connections and compare all snapshot fields after roll, hold, third roll, zero confirmation, and player transition. Completion history is read after reopening a connection.

## Verification

- Initial RED: the three new test files failed to compile because codec, repository, controller, and session metadata were absent.
- Regression RED: resaving a completed game ID returned successfully; the new test failed until the repository rejected it.
- Focused tests after fixes: 14 passed.
- Full local mobile gate after fixes: formatting unchanged across 45 files, analysis clean, 55 tests passed.
- After the schema fix, the first build-runner pass wrote 16 outputs; the second wrote zero. Generated database SHA-256 stayed `aa9f7f74aad824e8f018d642adaa1db09ef4a710a530258376e5393af8a2db87` across the second pass. The generated diff matches the timestamp column type/name change.
- `git diff --check` passed after the fixes.

## Scope limits

The app has no playable UI yet. The controller receives an initial or loaded session through an overridable provider; UI wiring and game creation belong to a later checkpoint.
