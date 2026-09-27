# Repository working rules

These rules apply to all development in this Flutter and Spring Boot monorepo.

## Branch and checkpoint workflow

- Treat `main` as the stable integration branch. Do not implement features directly on it.
- The repository's initial documentation commit is the one-time bootstrap exception. Every later checkpoint follows the branch workflow below.
- Before each checkpoint:
  1. Confirm `main` is clean.
  2. Fetch and inspect the remote state.
  3. Confirm local `main` matches `origin/main`.
  4. Create a fresh branch named `codex/checkpoint-<number>-<short-name>`.
  5. Use an isolated Git worktree when subagents or parallel work are involved.
- Start each checkpoint from the newly synchronized `main`. Do not accumulate unrelated checkpoints on a long-running branch.
- Do not mix unrelated cleanup with feature commits.

## Commits and records

- Keep commits small and reviewable. Prefer an implementation commit, focused review-fix commits when necessary, and a final documentation or verification-record commit.
- Store plans, progress reports, review findings, verification evidence, and deferred ideas under `codex/`.
- Keep application source in its normal modules. Never place product source under `codex/`.
- Keep the root `README.md` current and describe only behavior that has been verified.

## Local verification gate

- Run all verification locally. Do not add or depend on GitHub Actions unless the user explicitly requests it.
- Before pushing a checkpoint:
  1. Run focused tests for the changed behavior.
  2. Run the complete applicable local gate.
  3. Run `git diff --check`.
  4. Request an independent code review.
  5. Record the review and verification evidence under `codex/`.
  6. Fix every Critical or Important finding.
  7. Repeat independent review after those fixes.
- The complete mobile gate is formatting verification, `flutter analyze`, and the applicable Flutter tests. Include golden or integration tests when the changed behavior requires them.
- The complete backend gate is the repository Maven verification, including Testcontainers tests when applicable.
- Changes to shared ruleset fixtures must pass both the Dart and Java conformance suites.
- Changes to mobile/backend integration must run the repository's local end-to-end or container smoke test once that test exists.
- Documentation-only checkpoints require content review and `git diff --check`; unavailable application gates are recorded as not applicable.

## Push, merge, and synchronization

- Push a checkpoint branch only after local verification and independent review pass.
- Confirm the pushed checkpoint branch SHA matches its remote SHA.
- Merge a completed checkpoint into `main` with an explicit `--no-ff` merge commit so its boundary remains visible.
- Push `main`, then confirm local `main`, `origin/main`, and the GitHub remote SHA are identical.
- Preserve completed checkpoint branches on GitHub unless the user explicitly requests deletion.
- Never force-push, reset shared history, delete branches, or overwrite unexpected remote changes without explicit approval.
- If `main` diverges, a worktree is dirty, or unexpected commits appear, stop the merge and inspect the state before proceeding.

## Definition of complete

A checkpoint is complete only when:

1. implementation is committed;
2. local verification passes;
3. independent review has no Critical or Important findings;
4. review evidence is recorded;
5. the checkpoint branch is pushed;
6. the checkpoint is merged into `main` with `--no-ff`;
7. `main` is pushed; and
8. remote SHA synchronization is confirmed.

If verification, review, pushing, merging, or synchronization fails, report the blocker instead of calling the checkpoint complete.
