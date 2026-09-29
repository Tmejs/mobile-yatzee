# Ranked Spring Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a locally deployable Spring/PostgreSQL service for federated identity, validated ranked submissions, personal history, and weekly country/continent/global leaderboards.

**Architecture:** A Spring Boot modular monolith separates identity, profiles, rules, games, leaderboards, and statistics by package with package-private internals and explicit public services. PostgreSQL stores immutable accepted results and transactional summary rows; OpenAPI is the canonical external contract.

**Tech Stack:** Java 25, Spring Boot 4.1.1, Maven Wrapper, Spring MVC, Spring Security, OAuth2 JOSE, JDBC, PostgreSQL 18, Flyway, Testcontainers, JUnit 5, AssertJ, Docker Compose.

**Spec:** `codex/design.md`

## Global Constraints

- Use package root `pl.tmejs.mobileyatzee` and constructor injection.
- Keep provider tokens out of application sessions; issue short-lived backend JWT access tokens and opaque rotated refresh tokens.
- Identify providers by `(provider, subject)`, never email.
- Store UTC instants and assign leaderboard week from server receipt time.
- Snapshot country and continent on accepted results.
- Validate numeric category ranges, bonus arithmetic, and totals without claiming to prove dice fairness.
- Make result UUID submissions idempotent and conflicting payload reuse deterministic.
- Do not implement entitlements in this plan; Plan 4 adds that module against the established player/session model.

## Review Focus

- Forged, expired, wrong-audience, wrong-issuer, or nonce-mismatched provider tokens must create no profile/session; Task 11 tests all cases.
- Concurrent identical and conflicting result submissions must create at most one immutable result and one summary update; Task 12 tests with real PostgreSQL.
- Monday 00:00 UTC and delayed offline receipt must use server receipt week; Task 13 pins both sides of the boundary.
- A midweek country change must leave prior country/continent snapshots and boards unchanged; Tasks 11 and 13 test it.
- Account deletion must revoke sessions and remove identifying leaderboard data without corrupting anonymous aggregate metrics; Task 14 tests the transaction.

---

### Task 10: Backend foundation and Java rules conformance

**Files:**
- Create: `backend/pom.xml`
- Create: `backend/mvnw`, `backend/mvnw.cmd`, `backend/.mvn/wrapper/maven-wrapper.properties`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/Application.java`
- Create: `backend/src/main/resources/application.yml`
- Create: `backend/src/test/resources/application-test.yml`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/Ruleset.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/RulesetRegistry.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/DiceRoll.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/ScoreSheet.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/ScoreEvaluation.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/ScoreTotals.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/ScorecardValidator.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/rules/RulesetConformanceTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/ArchitectureTest.java`
- Create: `compose.yaml`
- Create: `backend/tool/verify.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: `rulesets/*.json` from checkpoints 4–5.
- Produces: Java `RulesetRegistry`, `ScorecardValidator`, Spring application skeleton, PostgreSQL local runtime, Maven gate.

- [ ] **Step 1: Create the Maven project and local PostgreSQL**

Pin `<java.version>25</java.version>` and Spring Boot parent `4.1.1`. Add starters for web, validation, security, oauth2-resource-server, actuator, JDBC; Flyway PostgreSQL; PostgreSQL runtime; Testcontainers PostgreSQL/JUnit; Spring Boot test; AssertJ; and ArchUnit.

`compose.yaml` defines PostgreSQL 18 with database/user `mobile_yatzee`, password supplied from `POSTGRES_PASSWORD`, healthcheck `pg_isready`, and no committed production credential. `.env.example` contains `POSTGRES_PASSWORD=local-development-only`.

`application.yml` reads `spring.datasource.password: ${POSTGRES_PASSWORD:local-development-only}` for the local profile; production deployment must set `POSTGRES_PASSWORD`. Every multi-command local gate exports the variable once so Compose, Spring, and backup/restore use the same value.

- [ ] **Step 2: Write a failing cross-language fixture test**

```java
interface Ruleset {
    String id();
    int version();
    ScoreEvaluation evaluate(String categoryId, DiceRoll roll, ScoreSheet prior);
    ScoreTotals totals(ScoreSheet sheet);
}

@ParameterizedTest(name = "{0}")
@MethodSource("allConformanceCases")
void matchesSharedFixture(ConformanceCase fixture) {
    var ruleset = registry.require(fixture.ruleset(), fixture.version());
    var evaluation = ruleset.evaluate(fixture.category(), fixture.roll(), fixture.prior());
    assertThat(evaluation).isEqualTo(fixture.expectedEvaluation());
    assertThat(ruleset.totals(fixture.prior().withApplied(fixture.category(), evaluation)))
        .isEqualTo(fixture.expectedTotals());
}
```

The loader requires `expectedTotals` for every case. Include completed-sheet fixtures for all three rulesets and Classic repeated-Yahtzee totals, so Dart and Java prove identical category, bonus, subtotal, and final-total behavior.

Run: `cd backend && ./mvnw -Dtest=RulesetConformanceTest test`

Expected: FAIL because rules engine classes do not exist.

- [ ] **Step 3: Implement Java rules and submitted-score validation**

Mirror stable IDs and fixture semantics, not Dart implementation structure. Add:

```java
public interface ScorecardValidator {
    ValidatedScorecard validate(
        RulesetKey ruleset,
        Map<String, Integer> categoryScores,
        Map<String, Integer> submittedBonuses,
        int submittedTotal);
}

public record RulesetKey(String id, int version) {}

public record ValidatedScorecard(
    RulesetKey ruleset,
    Map<String, Integer> categoryScores,
    Map<String, Integer> bonuses,
    int finalScore) {}
```

The validator checks exact category set, each ruleset's possible numeric values, bonus threshold/arithmetic, and final sum. Polish and Scandinavian upper bonuses are exact; classic upper bonus is exact, while repeated-Yahtzee bonus must be a multiple of 100 from 0 through 1200 and requires the Yahtzee category to contain 50. It must not accept a claim that category values prove actual rolls.

- [ ] **Step 4: Add package-boundary and application smoke tests**

ArchUnit prevents presentation/API packages from reaching JDBC repositories directly and prevents rules code from importing Spring. `@SpringBootTest` must start with test security and no external service.

- [ ] **Step 5: Add and run the backend gate**

`backend/tool/verify.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
./mvnw --batch-mode verify
```

Run:

```bash
POSTGRES_PASSWORD=local-development-only docker compose up -d postgres
cd backend
chmod +x tool/verify.sh
./tool/verify.sh
```

Expected: shared fixtures, architecture test, and Spring smoke test pass.

- [ ] **Step 6: Commit and complete checkpoint 10**

```bash
git add backend compose.yaml .env.example README.md codex
git commit -m "build: scaffold ranked Spring backend"
```

### Task 11: Federated identity, profiles, sessions, and region snapshots

**Files:**
- Create: `backend/src/main/resources/db/migration/V1__identity_and_profiles.sql`
- Create: `backend/src/main/resources/regions/country-continent-v1.csv`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/identity/ExternalIdentityVerifier.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/identity/IdentityService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/identity/RefreshSessionService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/identity/ExternalIdentityRepository.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/identity/RefreshSessionRepository.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/profile/ProfileService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/profile/ProfileRepository.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/profile/RegionCatalog.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/security/AccessTokenService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/security/SecurityConfiguration.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/AuthController.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/ProfileController.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/identity/IdentityExchangeIntegrationTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/identity/RefreshRotationIntegrationTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/profile/ProfileIntegrationTest.java`

**Interfaces:**
- Consumes: backend foundation.
- Produces: `/v1/auth/exchange`, `/v1/auth/refresh`, `/v1/auth/link`, `GET/DELETE /v1/auth/sessions/current`, `/v1/profile`, stable `PlayerId`, authenticated principal.

- [ ] **Step 1: Write migrations and failing repository tests**

Create `player_profile`, `external_identity`, and `refresh_session`. Enforce `unique(provider, provider_subject)`, ISO two-letter uppercase country check, hashed refresh token only, and optimistic/row locking needed for rotation.

Use a complete versioned ISO country-to-continent CSV. Startup validation rejects duplicate country codes, missing `PL`, unknown continent codes, or a profile country not in the mapping.

- [ ] **Step 2: Define provider-verifier boundary and failing token tests**

```java
public interface ExternalIdentityVerifier {
    VerifiedIdentity verify(Provider provider, String credential, String expectedNonce);
}

public record VerifiedIdentity(Provider provider, String subject) {}

public enum Provider { APPLE, GOOGLE }
public record PlayerId(UUID value) {}
public record SessionId(UUID value) {}
public record SessionFamilyId(UUID value) {}
public record RefreshSession(SessionId id, PlayerId playerId,
    SessionFamilyId familyId, Instant expiresAt, boolean consumed,
    boolean revoked) {}

public interface RefreshSessionRepository {
    RefreshSession create(PlayerId playerId, SessionFamilyId familyId,
                          byte[] refreshHash, Instant expiresAt);
    Optional<RefreshSession> lockByHash(byte[] refreshHash);
    void consumeAndRotate(SessionId current, byte[] nextHash, Instant nextExpiry);
    void revokeFamily(SessionFamilyId familyId);
}
```

Controlled test JWK issuers cover valid Apple/Google tokens plus bad signature, issuer, audience, expiry, nonce, blank subject, and replayed authorization response. Assert failure creates no profile, identity, or session.

- [ ] **Step 3: Implement exchange and backend sessions**

Access JWT lifetime is 15 minutes. Refresh token lifetime is 30 days, generated with 256 bits of secure randomness, stored as SHA-256 hash, and rotated on every use. Reuse of a consumed refresh token revokes that session family.

Add `RefreshSessionService.revokeCurrent(PlayerId, SessionId)` and `DELETE /v1/auth/sessions/current`. Revocation is idempotent, invalidates the complete refresh-token family, and makes every later refresh return `SESSION_REVOKED`. Write the failing revoked-family test before adding the controller method, then run only `RefreshRotationIntegrationTest` until green.

Implement the session flow as short red/green slices: make valid exchange fail, implement profile/identity lookup plus session creation, and run `IdentityExchangeIntegrationTest`; make single refresh fail, implement row-locked rotation, and run `RefreshRotationIntegrationTest`; add the concurrent refresh case and make it green; add reuse-family revocation and make it green; add current-session deletion and make it green. Only then add JWT serialization and the controller response mapping. Run the two focused test classes after every slice.

Return:

```json
{
  "accessToken": "backend-jwt",
  "accessTokenExpiresAt": "2026-09-28T12:15:00Z",
  "refreshToken": "opaque-once",
  "player": {"id": "uuid", "nickname": null, "country": null}
}
```

- [ ] **Step 4: Implement provider linking and profile update**

`POST /v1/auth/link` requires an authenticated backend session plus fresh provider credential. Existing same-player link is idempotent; a link owned by another player returns `IDENTITY_OWNERSHIP_CONFLICT` without owner details.

`PATCH /v1/profile` accepts normalized nickname and country. Backend derives continent from the versioned mapping. Reject blank/oversized nickname, unsupported country, and control characters with stable codes.

Write and run one failing case at a time in `ProfileIntegrationTest`: create profile, update country, derive continent, reject unknown country, normalize nickname, reject invalid nickname. Then do the same in `IdentityExchangeIntegrationTest` for idempotent same-player link and cross-player conflict. Add only the repository/service/controller method required by the current case before rerunning it.

- [ ] **Step 5: Verify rotation, concurrency, and region behavior**

With Testcontainers, race two refresh calls and assert one succeeds. Change Poland to Canada and assert profile continent changes from Europe to North America while no historical object is rewritten.

Run: `cd backend && ./mvnw -Dtest='*Identity*,*Refresh*,*Profile*' test && ./tool/verify.sh`

- [ ] **Step 6: Commit and complete checkpoint 11**

```bash
git add backend codex
git commit -m "feat: add federated identity and player profiles"
```

### Task 12: Idempotent ranked result submission

**Files:**
- Create: `backend/src/main/resources/db/migration/V2__game_results.sql`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/games/GameResult.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/games/GameResultRepository.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/games/GameSubmissionService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/games/GameAcceptedListener.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/games/GameAcceptedListenerConfiguration.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/RulesetAvailability.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/rules/RulesetAvailabilityRegistry.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/GameResultController.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/games/GameSubmissionIntegrationTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/games/GameSubmissionConcurrencyTest.java`

**Interfaces:**
- Consumes: authenticated `PlayerId`, profile region, `ScorecardValidator`.
- Produces: `POST /v1/ranked-games`, immutable accepted `GameResult`, and `GameAcceptedListener` transaction callback.

- [ ] **Step 1: Write migration and failing API tests**

`game_result` stores UUID, player, ruleset ID/version, client completion, server receipt, snapshotted country/continent, JSONB category scores, JSONB named bonuses, final score, app version, and canonical request SHA-256. Enforce unique game UUID and nonnegative numeric checks.

Test valid result, unsupported ruleset, retired-for-ranking ruleset, missing/extra category, impossible numeric value, bad bonus, bad total, missing profile region, and unknown app payload field handling. `RulesetAvailability` carries `playable`, `rankedSubmissionEnabled`, and `historicalReadable`; submission requires the middle flag while history remains readable.

- [ ] **Step 2: Define exact request/response records**

```java
public record SubmitGameRequest(
    UUID gameId,
    Instant completedAt,
    String rulesetId,
    int rulesetVersion,
    Map<String, Integer> categoryScores,
    Map<String, Integer> bonuses,
    int finalScore,
    String appVersion) {}
```

Success returns accepted game ID, canonical server total, server receipt instant, assigned week start, and region snapshot.

- [ ] **Step 3: Implement canonical hashing and transaction**

Define the callback before implementing the transaction:

```java
public interface GameAcceptedListener {
    void onAccepted(GameResult accepted);
}
```

Task 12 registers a no-op through `@Bean @ConditionalOnMissingBean(GameAcceptedListener.class)` in `GameAcceptedListenerConfiguration`; the concurrency test supplies a counting spy bean. `GameSubmissionService.submit()` canonicalizes sorted category and bonus keys, inserts the result, and invokes the listener after the insert in the same Spring transaction; a listener failure rolls back both. On duplicate UUID: same player plus same hash returns original `200` without invoking the listener; different content or different player returns `GAME_ID_CONFLICT`.

- [ ] **Step 4: Test concurrent duplicates with PostgreSQL**

Start 20 parallel identical requests and assert one row, identical responses, and one accepted-listener invocation. Repeat with two payloads sharing a UUID and assert one accepted payload and deterministic conflicts for the other.

- [ ] **Step 5: Run gate and commit checkpoint 12**

```bash
cd backend
./mvnw -Dtest='GameSubmission*' test
./tool/verify.sh
cd ..
git add backend codex
git commit -m "feat: accept idempotent ranked game results"
```

### Task 13: Weekly regional leaderboards and personal statistics

**Files:**
- Create: `backend/src/main/resources/db/migration/V3__weekly_leaderboards.sql`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/leaderboard/LeaderboardRefreshService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/leaderboard/LeaderboardQueryService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/leaderboard/LeaderboardCursorCodec.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/statistics/PersonalStatisticsService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/LeaderboardController.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/StatisticsController.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/leaderboard/LeaderboardIntegrationTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/leaderboard/WeekBoundaryTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/statistics/PersonalStatisticsIntegrationTest.java`

**Interfaces:**
- Consumes: accepted game transaction hook from Task 12.
- Produces: transactional `weekly_player_result` summaries and paginated leaderboard/statistics APIs.

- [ ] **Step 1: Write failing exact-window tests**

Insert 12 scores and assert latest ten by `(received_at, game_id)` are used. Verify provisional counts 1–9 are not ranked, score 10 qualifies, score 11 evicts oldest, exact sum orders rows, displayed average rounds to one decimal only in response formatting, best-single tie break, achieved-at tie break, then player ID deterministic ordering.

- [ ] **Step 2: Write UTC and region tests**

Use an injected `Clock`. Submit at Sunday `23:59:59.999Z` and Monday `00:00:00Z`; assert different ISO Monday week starts. Submit offline data with an old client `completedAt`; assert current server receipt week. Change country midweek and assert country/continent windows use their own snapshots while global uses latest ten regardless of region.

- [ ] **Step 3: Implement summary schema and refresh**

Key summaries by `(week_start, ruleset_id, ruleset_version, scope, region_code, player_id)`. Store game count, last-ten sum, average decimal, best score, achieved-at, and refreshed-at. Refresh GLOBAL plus the accepted result's COUNTRY and CONTINENT rows inside the game transaction using deterministic SQL window queries.

`LeaderboardRefreshService implements GameAcceptedListener`; Spring then omits Task 12's conditional no-op bean without any change to `GameSubmissionService`. Add a context test asserting exactly one listener bean and a transaction rollback test proving a refresh failure leaves neither result nor summary row committed.

- [ ] **Step 4: Implement keyset pagination**

`GET /v1/leaderboards/{rulesetId}/{version}?week=YYYY-MM-DD&scope=COUNTRY&region=PL&limit=50&cursor=...` validates scope/region agreement. It is a public Spring Security/OpenAPI route. Guests provide an explicit country/continent chosen in local settings; GLOBAL needs no region. Sign cursors with server HMAC and encode ordering tuple; reject altered or mismatched cursors. Add MockMvc tests that all three scopes are readable without a bearer token and private `/v1/me/**` routes still return `401`.

`GET /v1/me/statistics` and `/v1/me/games` return accepted ranked history only, never claim to include device-local games.

- [ ] **Step 5: Run gate and commit checkpoint 13**

```bash
cd backend
./mvnw -Dtest='*Leaderboard*,*WeekBoundary*,*PersonalStatistics*' test
./tool/verify.sh
cd ..
git add backend codex
git commit -m "feat: add weekly regional leaderboards"
```

### Task 14: OpenAPI, deletion, operations, and backend alpha

**Files:**
- Create: `api/openapi.yaml`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/ApiError.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/ApiExceptionHandler.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/profile/AccountDeletionService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/security/ApiRateLimitFilter.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/profile/NicknamePolicy.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/RulesetAvailabilityController.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/api/OpenApiContractTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/profile/AccountDeletionIntegrationTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/security/RateLimitIntegrationTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/profile/NicknamePolicyTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/operations/BackupRestoreReadinessTest.java`
- Create: `backend/tool/backup-restore-readiness.sh`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/BackendEndToEndTest.java`
- Modify: `backend/src/main/resources/application.yml`
- Modify: `compose.yaml`
- Modify: `README.md`
- Modify: `codex/progress.md`
- Create: `codex/reviews/checkpoint-14-backend-alpha.md`

**Interfaces:**
- Consumes: Tasks 10–13 APIs.
- Produces: versioned OpenAPI contract, public ruleset-availability metadata, stable error envelope, deletion semantics, security/operational controls, health/metrics/logging, backend alpha evidence.

- [ ] **Step 1: Write the OpenAPI contract before controller alignment**

Define every request/response, bearer security, pagination cursor, enum, timestamp, numeric bound, and stable error code. Error shape:

```json
{
  "code": "GAME_ID_CONFLICT",
  "arguments": {"gameId": "uuid"},
  "requestId": "correlation-id"
}
```

Write a test that loads `api/openapi.yaml`, validates it, and compares documented routes/status codes to Spring MVC mappings.

Document `GET /v1/rulesets` as public. Each item exposes immutable ID/version plus `playable`, `rankedSubmissionEnabled`, and `historicalReadable`. Historical game and leaderboard reads accept retired versions when `historicalReadable=true`; `POST /v1/ranked-games` returns `RULESET_RANKING_RETIRED` when new ranked submissions are disabled.

- [ ] **Step 2: Implement stable exception mapping and observability**

Return no translated prose from business errors. Add request correlation ID generation/propagation, structured JSON production logs without tokens/payloads, Actuator health/readiness, and Micrometer counters for identity exchange, accepted/rejected submissions, and leaderboard latency.

First add failing tests, then enforce explicit maximum lengths/counts in OpenAPI and Bean Validation: provider credential 16 KiB, nickname 24 Unicode code points, app version 64 characters, cursor 2 KiB, at most 20 category/bonus entries, and request body 64 KiB. `NicknamePolicy` applies normalized allow/block lists and returns `NICKNAME_NOT_ALLOWED`. `ApiRateLimitFilter` uses per-IP limits for public auth/leaderboard routes and per-player limits for authenticated writes, returns `429 RATE_LIMITED` with `Retry-After`, and has deterministic injected-clock tests. Configuration keeps thresholds externalized and production defaults nonzero.

Use separate red/green loops in this order: error envelope in `OpenApiContractTest`; request ID propagation; Bean Validation bounds; `NicknamePolicyTest`; `RateLimitIntegrationTest`; structured-log redaction test; Actuator readiness; metrics assertions. Run the single named test after each minimal implementation, then run `./tool/verify.sh`. Do not add the next concern while the current focused test is red.

- [ ] **Step 3: Implement account deletion transaction**

Require recent provider reauthentication. Revoke sessions and identities, remove active/historical leaderboard rows, and delete or irreversibly anonymize identifying result/profile data. Test retries are idempotent and a deleted access/refresh token cannot recover the account.

- [ ] **Step 4: Add backend end-to-end scenario**

Using Testcontainers plus controlled identity issuer: exchange identity, set Poland, submit ten games, repeat one UUID, query PL/Europe/global boards, change country, query personal history, refresh session, then delete account and verify removal/revocation.

Add `backend/tool/backup-restore-readiness.sh`: create a dump with `pg_dump`, restore it with `pg_restore` into a second disposable database, and run SQL assertions for profiles, accepted games, region snapshots, and summary rows. `BackupRestoreReadinessTest` verifies the script/config contract; the checkpoint gate runs the script against Compose and records the restore result.

- [ ] **Step 5: Run complete backend alpha gate**

```bash
export POSTGRES_PASSWORD=local-development-only
docker compose up -d postgres
cd backend && ./tool/verify.sh
./mvnw spring-boot:run >/tmp/mobile-yatzee-backend.log 2>&1 &
BACKEND_PROCESS_ID=$!
cd ..
for ATTEMPT in 1 2 3 4 5 6 7 8 9 10; do
  curl --fail http://localhost:8080/actuator/health && break
  sleep 1
done
curl --fail http://localhost:8080/actuator/health
kill "$BACKEND_PROCESS_ID"
./backend/tool/backup-restore-readiness.sh
docker compose down
```

Expected: Maven verify passes and the health endpoint returns `UP`. Record exact verification in `codex/reviews/checkpoint-14-backend-alpha.md`; if startup fails, include `/tmp/mobile-yatzee-backend.log` diagnostics without committing the temporary log.

- [ ] **Step 6: Commit and complete checkpoint 14**

```bash
git add api backend compose.yaml README.md codex
git commit -m "feat: complete ranked backend alpha"
```
