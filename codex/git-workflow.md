# Git and GitHub workflow

## Stable integration branch

`main` is the stable integration branch. Feature implementation never happens directly on it. The first documentation commit is the unavoidable repository bootstrap exception; every subsequent checkpoint begins from a clean, synchronized `main`.

Before each checkpoint:

1. Confirm `main` is clean.
2. Fetch and inspect the remote state.
3. Confirm local `main` equals `origin/main`.
4. Create `codex/checkpoint-<number>-<short-name>`.
5. Use an isolated Git worktree when subagents or parallel work are involved.

## Commit structure

Keep changes small and reviewable. A normal checkpoint contains an implementation commit, focused review-fix commits when needed, and a final documentation or verification-record commit. Do not combine unrelated cleanup with feature work.

Plans, reports, review findings, verification results, and deferred ideas belong under `codex/`. Flutter code belongs under `mobile/`, Spring code under `backend/`, and cross-language ruleset fixtures under `rulesets/`. The root `README.md` describes only verified behavior.

## Local verification

All verification runs locally. The project does not add or depend on GitHub Actions unless the user explicitly requests it.

Before pushing a checkpoint:

1. Run focused tests for the changed behavior.
2. Run the complete applicable verification gate.
3. Run `git diff --check`.
4. Perform an independent code review and record it under `codex/`.
5. Fix every Critical or Important finding.
6. Repeat independent review after fixes and record the final result.

The applicable complete gate is:

- **Flutter:** formatting verification, `flutter analyze`, and the relevant unit, widget, golden, or integration tests.
- **Spring Boot:** the repository Maven verification, including Testcontainers coverage where applicable.
- **Shared rules:** both Dart and Java conformance suites.
- **Integration:** the local end-to-end or container smoke test when mobile/backend wiring changes and that test exists.
- **Documentation only:** content review and `git diff --check`; application gates are recorded as not applicable.

Exact commands are added to module documentation and the implementation plan when the project skeleton establishes them.

## Push and merge

Push a checkpoint branch only after verification and review pass, then confirm its local SHA equals the remote branch SHA. Merge it into `main` using an explicit `--no-ff` merge commit. Push `main` and confirm local `main`, `origin/main`, and the GitHub remote SHA are identical.

Start the next checkpoint from that synchronized `main` on a new numbered branch. Preserve completed checkpoint branches on GitHub for traceability unless the user explicitly requests deletion.

Never force-push, reset shared history, delete branches, or overwrite unexpected remote changes without explicit approval. If `main` diverges, the worktree is dirty, or unexpected commits appear, stop the merge and inspect before proceeding.

## Completion criteria

A checkpoint is complete only after its implementation is committed, local verification passes, independent review has no Critical or Important findings, evidence is recorded, the branch is pushed, the checkpoint is merged into `main`, `main` is pushed, and all remote SHAs are confirmed synchronized. Any failed step remains a reported blocker.
