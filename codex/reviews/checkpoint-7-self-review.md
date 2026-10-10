# Checkpoint 7 self-review

Reviewed implementation commit `9c2bbb6` and the handoff fixes against the Task 7 brief, session contracts, generated Drift schema, and tests.

## Findings

Two Important findings were fixed with regression tests. The later independent task and broad reviews are recorded below.

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

## Task-review fix round 1

Independent task review identified two Important controller races in the preceding implementation. Both were reproduced with controlled regression tests before the fix:

1. A synchronous Riverpod success listener calling `apply(ToggleHold(0))` after a roll saw the old in-flight future. RED: one repository save instead of two, leaving the second transition pending. The controller now releases attempt ownership before publishing success. GREEN: two saves, the held die appears in both published state and the repository.
2. Replacing the initial session while its save was pending retained the old pending transition and allowed its delayed completion to affect the new session. RED: both delayed-success and delayed-failure cases rejected B's command because A remained pending. Each build now invalidates the prior generation and pending attempt; completion checks generation, pending identity, and provider mounting before publishing either success or error. GREEN: A's delayed outcome leaves B's pending and public state intact, and B persists successfully.

Write ownership is reserved before the asynchronous repository call begins. On success, the controller clears the completed pending transition and in-flight future before notifying listeners. On failure it clears only the in-flight future, retaining exactly one pending transition for retry. A stale attempt does not clear a newer session's pending transition or publish a result.

The final `flutter test test/local test/game/application` run passed 17 tests. The final `./tool/verify.sh` run reported 45 files formatted with zero changes, no analysis issues, and 58 passing tests. `git diff --check` passed. No schema changed, so code generation was not rerun.

## Independent review results

- Scoped re-review approved both controller race fixes with no findings. It passed 19 repository tests plus three temporary lifecycle checks covering disposal during delayed success/failure and synchronous error-listener retry.
- Broad final review covered the complete checkpoint diff, repeated the 17 focused tests and 58-test full gate, and found no Critical or Important findings. Its only Minor finding was stale review-status wording in the checkpoint evidence; this documentation update resolves it.
- Push, merge, and remote synchronization remain pending with the checkpoint owner.
