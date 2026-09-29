# Checkpoint 2 review — implementation planning

**Branch:** `codex/checkpoint-2-implementation-plan`

## Scope

This documentation checkpoint turns the approved design into four executable plans covering checkpoints 3–20:

- offline Flutter game and the three immutable rulesets;
- ranked Spring Boot/PostgreSQL backend;
- mobile identity, durable ranked submission, and leaderboard integration;
- disabled-by-default advertising and server-verified lifetime Premium.

Each task identifies concrete files and interfaces, follows red-green verification, records local commands, and ends at the repository checkpoint gate.

## Independent review and corrections

The initial review found no Critical issues and nine Important issues. Corrections added final-total parity to shared fixtures, a reliable formatting gate, exact file/type contracts, the transactional accepted-game listener, session revocation, release security and backup/restore checks, ruleset retirement, public guest leaderboard reads, and deletion-safe Premium audit ownership.

Repeat reviews then found execution-level gaps. The plan was tightened with:

- conditional listener wiring that yields exactly one production implementation;
- exported PostgreSQL credentials shared by Compose, Spring, and restore checks;
- concrete Apple/Google identity configuration, Apple entitlements, and cross-platform device commands;
- native Gradle/Xcode AdMob configuration and release-only real-ID validation;
- exact Apple/Google purchase and notification verifier boundaries, including authenticated Google Pub/Sub push and authoritative Play API lookup;
- controlled backend startup and cleanup for backend-dependent mobile end-to-end tests;
- explicit mobile purchase controller/adapter contracts and focused tests.

The final cleanup also records complete iOS entitlement XML, ignored local monetization overrides, and the platform store adapter test file.

## Final independent review

The final reviewer audit of commit `d5fa66b` reports no Critical, Important, or Minor findings. It confirms that the three last Minor notes were resolved without regression.

## Verification

- Documentation content and approved-design coverage review: passed.
- Cross-plan type, dependency, and command consistency review: passed.
- `git diff --check main...HEAD`: passed.
- Placeholder scan: passed; the only literal use of the word is the real Gradle API name `manifestPlaceholders`.
- Flutter, Java, database, simulator, and end-to-end tests: not applicable because this checkpoint changes planning documentation only; their exact gates are specified for implementation checkpoints.

