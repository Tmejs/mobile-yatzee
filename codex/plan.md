# Mobile Yatzee Delivery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a production-ready Flutter dice game and Spring Boot ranked-play service through small, independently verified Git checkpoints.

**Architecture:** The program is split into four plans whose outputs are useful and testable on their own: an offline-first Flutter game, a ranked Spring backend, mobile/backend integration, and post-retention monetization. Each numbered task is one repository checkpoint and must use a fresh `codex/checkpoint-<number>-<short-name>` branch from synchronized `main`.

**Tech Stack:** Flutter 3.47 stable, Dart bundled with Flutter, Riverpod 3.4.3, Drift 2.35.0 with drift_flutter 0.3.1, Java 25, Spring Boot 4.1.1, Maven Wrapper, PostgreSQL 18, Flyway, Testcontainers, OpenAPI, Docker Compose.

**Spec:** `codex/design.md`

## Global Constraints

- Local solo and pass-and-play must remain usable without network access or sign-in.
- Support iOS and Android in portrait orientation with Polish and English at launch.
- Implement `polish-general:v1`, `classic-yahtzee:v1`, and `scandinavian-yatzy:v1` as immutable versioned rulesets.
- Run identical JSON conformance fixtures through the Dart and Java scoring engines.
- Require Apple or Google identity only for ranked submission, ranked-profile recovery, and Premium purchase/restoration.
- Keep active games, unranked history, pass-and-play history, and local settings on the device in version one.
- Keep leaderboards separate by UTC week, ruleset version, and country/continent/global scope.
- Early access has ads and purchases disabled; monetization is enabled only after retention review.
- Run all verification locally; do not add GitHub Actions unless the user explicitly requests it.
- Preserve checkpoint branches, merge each with `--no-ff`, and confirm local/remote SHAs after every merge.

## Review Focus

- App termination after any roll, hold, score, identity claim, or purchase event must resume without duplicating or losing state; Plans 1, 3, and 4 pin these transitions with persistence tests.
- A ruleset edge case must produce the same score in Dart and Java; Plans 1 and 2 run the shared fixture corpus in both languages.
- Signing out or changing providers must never reassign queued results or entitlements; Plans 3 and 4 test owner binding and cross-player replay rejection.
- UTC week boundaries and midweek country changes must not move historical results between boards; Plan 2 tests Monday boundaries and regional snapshots.
- Ads, failed ads, consent denial, and store outages must never block a saved result or a new game; Plan 4 tests every fallthrough path.

---

## Delivery plans

1. [Offline Flutter game](plans/01-offline-flutter-game.md) — checkpoints 3–9. Produces a complete installable local game with all three rulesets, pass-and-play, autosave, localization, accessibility, and personal statistics.
2. [Ranked Spring backend](plans/02-ranked-spring-backend.md) — checkpoints 10–14. Produces a locally deployable service with identity, validated submissions, weekly regional leaderboards, personal history, deletion, and OpenAPI.
3. [Mobile and backend integration](plans/03-mobile-backend-integration.md) — checkpoints 15–17. Produces provider sign-in, durable owner-bound submission, profile/region screens, ranked boards, and recovery flows.
4. [Monetization and release controls](plans/04-monetization.md) — checkpoints 18–20. Produces feature-flagged ads, server-verified lifetime Premium, themes/statistics entitlements, consent handling, and launch evidence.

## Specification coverage

| Design area | Owning checkpoints |
|---|---|
| Product modes, turns, pass-and-play | 6, 8, 9 |
| Modern Tabletop UI and accessibility | 8, 9 |
| Three versioned rulesets and shared fixtures | 4, 5, 10 |
| Mobile layers, persistence, autosave | 3, 6, 7 |
| Spring modules, PostgreSQL, OpenAPI | 10–14 |
| Identity, linking, recovery, deletion | 11, 15, 17 |
| Idempotent results and honest validation limits | 12, 16 |
| Weekly regional rankings and personal statistics | 13, 16 |
| Localization and offline failures | 8, 9, 16 |
| Security, privacy, operations | 11, 14, 17, 20 |
| Advertising and lifetime Premium | 18–20 |

## Program execution order

- Execute Plans 1 and 2 in order. They may be developed sequentially by one worker; their shared fixture contract is established in checkpoint 4 and consumed by the backend.
- Execute Plan 3 only after checkpoints 9 and 14 are merged.
- Release an internal/early-access build after checkpoint 17 with monetization flags disabled.
- Measure retention outside this repository. Execute Plan 4 only after the user explicitly decides to enable monetization work.
- Update `codex/progress.md` and the relevant review record at every checkpoint. Update the root `README.md` at user-facing milestones or whenever verified behavior, setup, or commands change.

## Checkpoint gate used by every task

1. Synchronize clean `main` with `origin/main` and create the task's named branch.
2. Use an isolated worktree whenever subagents or parallel work participate.
3. Follow the task's red-green-refactor steps and focused checks.
4. Run the complete applicable Flutter, Maven, shared-contract, or integration gate.
5. Run `git diff --check`.
6. Obtain independent review, fix every Critical or Important finding, and repeat review.
7. Record commands, results, review findings, and deferred ideas under `codex/`.
8. Push and verify the checkpoint branch SHA.
9. Merge to `main` with `--no-ff`, push, and verify local `main`, `origin/main`, and GitHub remote SHA are identical.

## Definition of product milestones

- **Local alpha:** checkpoint 9; all game modes work offline on iOS and Android simulators/devices.
- **Backend alpha:** checkpoint 14; Spring/PostgreSQL service passes its local API and concurrency suites.
- **Early access:** checkpoint 17; ranked identity/submission/recovery works end to end with ads and purchases disabled.
- **Monetized release candidate:** checkpoint 20; ads and Premium remain remotely/configurationally disabled until the user approves activation.
