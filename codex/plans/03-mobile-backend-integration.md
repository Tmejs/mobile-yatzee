# Mobile and Backend Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the complete Flutter game to the ranked backend with provider sign-in, secure sessions, owner-bound queued submission, regional leaderboards, recovery, and account management.

**Architecture:** A generated Dart API package mirrors the reviewed OpenAPI contract. Platform identity adapters feed one application-level authentication service; secure backend sessions and Drift-owned submission records remain separate from UI, allowing deterministic fakes in tests.

**Tech Stack:** Flutter 3.47, Riverpod 3.4.3, http 1.6.0, flutter_secure_storage 11.2.0, google_sign_in 7.2.0, sign_in_with_apple 8.2.0, OpenAPI Generator 7.25.0, Spring/PostgreSQL backend from Plan 2.

**Spec:** `codex/design.md`

## Global Constraints

- Guest play never makes a backend account and remains fully offline.
- Offer Apple and Google on both platforms; emphasize Apple on iOS and Google on Android.
- Store only backend refresh credentials in secure storage; keep access credentials in memory and provider credentials transient.
- Explicitly claim guest pending results before binding; never reassign a bound result.
- Present local latest-ten and server weekly latest-ten as separate statistics.
- Keep ads and purchases disabled throughout this plan.

## Review Focus

- Expired access during a submission must refresh once and retry the same UUID without duplicating; Task 15 tests concurrent refresh collapse.
- Account switching with pending results must hide other-player items and never mutate owner ID; Task 16 tests it across restart.
- A result bound locally before a crash must resume under the same player after reauthentication; Task 16 tests the crash boundary.
- Apple-linked recovery on Android and Google-linked recovery on iOS must work through secondary provider flows; Task 17 tests both.
- Cached leaderboard failure states must show age/retry without blocking local play; Task 16 widget and integration tests cover it.

---

### Task 15: Generated API client, provider adapters, and secure sessions

**Files:**
- Create: `api-clients/mobile_yatzee_api/` generated Dart package
- Create: `tool/generate-mobile-api.sh`
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/src/auth/domain/auth_session.dart`
- Create: `mobile/lib/src/auth/data/provider_identity.dart`
- Create: `mobile/lib/src/auth/data/apple_identity_provider.dart`
- Create: `mobile/lib/src/auth/data/google_identity_provider.dart`
- Create: `mobile/lib/src/auth/data/session_store.dart`
- Create: `mobile/lib/src/auth/data/secure_session_store.dart`
- Create: `mobile/lib/src/auth/data/authenticated_api_client.dart`
- Create: `mobile/lib/src/auth/application/auth_controller.dart`
- Create: `mobile/lib/src/auth/presentation/sign_in_sheet.dart`
- Create: `mobile/android/auth.properties.example`
- Modify: `mobile/android/app/build.gradle.kts`
- Modify: `mobile/android/app/src/main/AndroidManifest.xml`
- Create: `mobile/ios/Config/Auth.local.xcconfig.example`
- Create: `mobile/ios/Config/Auth.defaults.xcconfig`
- Modify: `mobile/ios/Runner/Info.plist`
- Modify: `mobile/ios/Runner.xcodeproj/project.pbxproj`
- Create: `mobile/test/auth/auth_controller_test.dart`
- Create: `mobile/test/auth/authenticated_api_client_test.dart`
- Create: `mobile/test/auth/provider_priority_test.dart`
- Create: `mobile/test/auth/secure_session_store_test.dart`

**Interfaces:**
- Consumes: `api/openapi.yaml`, Task 14 backend endpoints, existing Flutter providers.
- Produces: generated `MobileYatzeeApi`, `ProviderIdentity`, `AuthController`, authenticated HTTP retry boundary, sign-in sheet.

- [ ] **Step 1: Generate and pin the Dart client**

`tool/generate-mobile-api.sh` runs:

```bash
docker run --rm \
  -v "$PWD:/workspace" \
  openapitools/openapi-generator-cli:v7.25.0 generate \
  -i /workspace/api/openapi.yaml \
  -g dart \
  -o /workspace/api-clients/mobile_yatzee_api \
  --additional-properties=pubName=mobile_yatzee_api,pubVersion=1.0.0
```

Add the generated package as a path dependency. Run generation twice and assert `git diff --exit-code api-clients/mobile_yatzee_api` after the second run.

- [ ] **Step 2: Write failing provider-priority and session tests**

```dart
enum IdentityProvider { apple, google }

final class ProviderCredential {
  const ProviderCredential({required this.provider, required this.token,
    required this.nonce});
  final IdentityProvider provider;
  final String token;
  final String nonce;
}

abstract interface class ProviderIdentity {
  Future<ProviderCredential> authenticate({required String nonce});
}

abstract interface class SessionStore {
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String value);
  Future<void> clear();
}
```

Tests assert iOS order Apple/Google, Android order Google/Apple, cancellation creates no backend request, provider token is not persisted, backend refresh token is persisted, and sign-out attempts `DELETE /v1/auth/sessions/current` before clearing local state. Network failure during revoke still clears local credentials; a successful revoke makes the refresh family unusable in the backend contract test.

- [ ] **Step 3: Verify tests fail and add pinned dependencies**

```bash
cd mobile
flutter pub add http:1.6.0 flutter_secure_storage:11.2.0 google_sign_in:7.2.0 sign_in_with_apple:8.2.0
flutter test test/auth
```

Expected: FAIL because adapters/controllers do not exist.

- [ ] **Step 4: Implement exchange and concurrent refresh collapse**

`AuthController.signIn(provider)` creates a cryptographic nonce, calls the platform adapter, exchanges the credential through generated API, stores only rotated refresh token, and publishes the backend player/session.

`AuthenticatedApiClient` attaches access token, handles one `401`, and uses one shared in-flight refresh future so concurrent requests perform one rotation. A second `401` signs out and surfaces `sessionExpired`.

Implement `AuthController.signOut()` as best-effort server revocation followed by `SessionStore.clear()` in `finally`. Expose only `signedOut` after secure storage is cleared.

Use these red/green slices, running the named file after each minimal change:

1. Add the successful exchange case to `auth_controller_test.dart`; implement nonce creation, provider call, generated exchange call, and secure refresh-token write.
2. Add cancellation and exchange-failure cases; implement state rollback without persisting provider credentials.
3. Add one-expired-request and concurrent-expired-request cases to `authenticated_api_client_test.dart`; implement the shared in-flight refresh future and one retry.
4. Add the second-`401` case; implement `sessionExpired` and local clear.
5. Add successful and network-failed revoke cases; implement best-effort `DELETE /v1/auth/sessions/current` plus `finally` clear.

Run `flutter test test/auth/auth_controller_test.dart test/auth/authenticated_api_client_test.dart` after the five slices, then continue to native adapters.

- [ ] **Step 5: Implement platform configuration without secrets**

`mobile/android/auth.properties.example` defines `APPLE_SERVICE_ID`, `APPLE_REDIRECT_URI`, `GOOGLE_SERVER_CLIENT_ID`, and `API_BASE_URL`; `build.gradle.kts` reads an optional untracked `auth.properties` and otherwise uses empty local-build values. `mobile/ios/Config/Auth.defaults.xcconfig` defines empty local-build values and optionally includes untracked `Auth.local.xcconfig`; `Auth.local.xcconfig.example` documents `GOOGLE_IOS_CLIENT_ID`, `GOOGLE_REVERSED_CLIENT_ID`, and `API_BASE_URL`. The Xcode project includes the committed defaults file, so a fresh checkout builds while provider actions report unconfigured state. Android Apple login uses the package browser callback flow; iOS adds the Sign in with Apple entitlement and Google URL scheme.

Add one adapter contract case at a time in `provider_priority_test.dart`: Apple success/cancel on each platform, then Google success/cancel on each platform, then platform priority. Implement only the adapter under test and rerun that file. Finish with `flutter build apk --debug` and `flutter build ios --simulator --no-codesign` using local non-secret test configuration.

- [ ] **Step 6: Run focused and complete gates**

```bash
./tool/generate-mobile-api.sh
cd mobile
flutter test test/auth
./tool/verify.sh
```

Expected: provider ordering, secure persistence, cancellation, refresh rotation, concurrent collapse, and sign-out tests pass.

- [ ] **Step 7: Commit and complete checkpoint 15**

```bash
git add api-clients tool mobile codex
git commit -m "feat: add mobile federated authentication"
```

### Task 16: Owner-bound submission queue and ranked UI

**Files:**
- Modify: `mobile/lib/src/local/tables/completed_games.dart`
- Create: `mobile/lib/src/ranked/domain/submission_state.dart`
- Create: `mobile/lib/src/ranked/data/ranked_repository.dart`
- Create: `mobile/lib/src/ranked/data/api_ranked_repository.dart`
- Create: `mobile/lib/src/ranked/application/result_claim_controller.dart`
- Create: `mobile/lib/src/ranked/application/submission_queue.dart`
- Create: `mobile/lib/src/ranked/application/leaderboard_controller.dart`
- Create: `mobile/lib/src/ranked/application/ruleset_availability_controller.dart`
- Create: `mobile/lib/src/ranked/presentation/claim_results_sheet.dart`
- Create: `mobile/lib/src/ranked/presentation/leaderboard_screen.dart`
- Create: `mobile/lib/src/ranked/presentation/personal_statistics_screen.dart`
- Create: `mobile/test/ranked/result_claim_controller_test.dart`
- Create: `mobile/test/ranked/submission_queue_test.dart`
- Create: `mobile/test/ranked/leaderboard_controller_test.dart`
- Create: `mobile/test/ranked/ruleset_availability_controller_test.dart`
- Create: `mobile/test/ranked/leaderboard_screen_test.dart`
- Create: `mobile/integration_test/ranked_submission_flow_test.dart`

**Interfaces:**
- Consumes: authenticated API client, local completed games, backend ranked APIs.
- Produces: explicit claim flow, durable owner binding, retry queue, country/continent/global boards, cached ranked statistics.

```dart
abstract interface class RankedRepository {
  Future<AcceptedGame> submit(CompletedGame game);
  Future<LeaderboardPage> leaderboard(LeaderboardQuery query);
  Future<List<RulesetAvailability>> rulesets();
}

final class RulesetKey {
  const RulesetKey(this.id, this.version);
  final String id;
  final int version;
}

final class AcceptedGame {
  const AcceptedGame({required this.gameId, required this.receivedAt,
    required this.weekStart});
  final String gameId;
  final DateTime receivedAt;
  final DateTime weekStart;
}

enum LeaderboardScope { country, continent, global }

final class LeaderboardEntry {
  const LeaderboardEntry({required this.rank, required this.displayName,
    required this.gameCount, required this.lastTenAverage});
  final int rank;
  final String displayName;
  final int gameCount;
  final double lastTenAverage;
}

final class LeaderboardQuery {
  const LeaderboardQuery({required this.ruleset, required this.weekStart,
    required this.scope, this.region, this.cursor});
  final RulesetKey ruleset;
  final DateTime weekStart;
  final LeaderboardScope scope;
  final String? region;
  final String? cursor;
}

final class LeaderboardPage {
  const LeaderboardPage({required this.entries, this.nextCursor});
  final List<LeaderboardEntry> entries;
  final String? nextCursor;
}

final class RulesetAvailability {
  const RulesetAvailability({required this.key, required this.playable,
    required this.rankedSubmissionEnabled, required this.historicalReadable});
  final RulesetKey key;
  final bool playable;
  final bool rankedSubmissionEnabled;
  final bool historicalReadable;
}
```

- [ ] **Step 1: Add schema migration and failing ownership tests**

Add completed-game fields: `localGuestProfileId`, nullable immutable `backendPlayerId`, `rankedIntent`, submission state, attempt count, next attempt instant, last error code, accepted receipt/week.

Tests must prove:

```dart
await queue.claim(gameIds, playerA);
await auth.signOut();
await auth.signIn(playerB);
expect(queue.visiblePendingFor(playerB), isEmpty);
expect(await database.ownerOf(gameId), playerA.id);
expect(() => queue.claim([gameId], playerB), throwsA(isA<OwnershipConflict>()));
```

- [ ] **Step 2: Implement explicit claim transaction**

The sheet lists count, ruleset, completion time, and score. Confirmation binds all selected UUIDs to the current backend player in one local transaction before network I/O. Decline clears `rankedIntent` but preserves local history. Pass-and-play rows are ineligible by query and invariant.

First implement only the Drift owner-binding transaction and make `result_claim_controller_test.dart` green. Then render `ClaimResultsSheet` from controller state and make its widget cases green before continuing to the network worker.

- [ ] **Step 3: Implement idempotent queue worker**

Queue processes only current-player rows, sends original UUID, saves accepted receipt before removing retry metadata, and uses bounded exponential delays of 5 seconds, 30 seconds, 2 minutes, 10 minutes, then 1 hour maximum. Connectivity/app-resume triggers an immediate eligible retry. Permanent API errors stop retry and retain translated diagnostic state.

Before submitting, fetch/cache ruleset availability. A queued result with `rankedSubmissionEnabled=false` remains local with a translated retired-ruleset explanation and is not retried; already accepted results remain visible when `historicalReadable=true`. An offline started local game always finishes using its bundled immutable ruleset even when later metadata marks it `playable=false`.

- [ ] **Step 4: Write failing leaderboard/cache tests**

Cover provisional `x/10`, exact ruleset/version selector, three scopes, cursor pagination, previous weeks, tie display, cached timestamp, and retry state. Signed-in defaults come from the profile. A guest can browse without account creation: GLOBAL opens directly, while COUNTRY/CONTINENT use a locally stored region choice or prompt for country and derive continent from the bundled catalog. A failed fetch must leave New Game and Resume operational.

- [ ] **Step 5: Implement ranked screens and statistic labels**

Display `Średnia z ostatnich 10 gier lokalnych` separately from weekly server average. Never combine different ruleset versions. Persist only read-cache DTOs, guest region choice, ruleset availability, and fetch timestamps, not provider/access tokens. `LeaderboardController` calls the public generated client directly for reads; authentication is optional and never triggers sign-in.

- [ ] **Step 6: Test crash boundaries and API integration**

The integration fake must terminate/recreate the app after local claim but before HTTP, after HTTP success but before UI refresh, and during access refresh. Assert same owner/UUID and a single backend result each time.

Run:

```bash
cd mobile
dart run build_runner build --delete-conflicting-outputs
flutter test test/ranked
flutter test integration_test/ranked_submission_flow_test.dart
./tool/verify.sh
```

- [ ] **Step 7: Commit and complete checkpoint 16**

```bash
git add mobile codex
git commit -m "feat: submit and display ranked results"
```

### Task 17: Cross-platform recovery, account controls, and early access

**Files:**
- Create: `mobile/lib/src/profile/profile_screen.dart`
- Create: `mobile/lib/src/profile/account_screen.dart`
- Create: `mobile/lib/src/profile/provider_link_screen.dart`
- Create: `mobile/lib/src/profile/delete_account_flow.dart`
- Create: `mobile/test/profile/provider_recovery_test.dart`
- Create: `mobile/test/profile/profile_screen_test.dart`
- Create: `mobile/test/profile/delete_account_flow_test.dart`
- Create: `mobile/integration_test/full_ranked_flow_test.dart`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/MobileContractEndToEndTest.java`
- Modify: `mobile/lib/src/app.dart`
- Modify: `README.md`
- Modify: `codex/progress.md`
- Create: `codex/reviews/checkpoint-17-early-access.md`

**Interfaces:**
- Consumes: complete local and ranked stacks.
- Produces: profile country/nickname, second-provider linking, recovery UX, deletion, and early-access release evidence.

- [ ] **Step 1: Write failing provider recovery/conflict tests**

Adapter/fake contract tests cover Apple-linked player on Android using the secondary Apple flow and Google-linked player on iOS. Each restores ranked history and links the other provider. If Google and Apple already own separate profiles, linking returns conflict, reveals no other player details, preserves both sessions/data, and offers sign-out/recover choices.

- [ ] **Step 2: Implement profile and linked-provider UI**

Country selector uses ISO names localized on device and sends code only. Explain that country affects future results. Show linked providers, current sessions, sign-out, and delete account. Do not imply local games/settings are cloud backed up.

- [ ] **Step 3: Implement deletion with recent reauthentication**

Require fresh provider flow, explain ranked-history removal and local-history retention separately, call delete endpoint, clear secure session and ranked caches, mark that player's bound pending results permanently unsubmitted/archived, and return to guest home. Archived rows remain in local history but never return to the submission queue.

- [ ] **Step 4: Run true local end-to-end stack**

Start PostgreSQL/backend with controlled provider issuer, run Flutter integration flow for sign-in, country, ten submissions, provisional/eligible boards, duplicate retry, cross-provider link, recovery, and deletion. Use network fault injection for one queued retry.

```bash
export POSTGRES_PASSWORD=local-development-only
docker compose up -d postgres
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=e2e
```

Run the backend in a dedicated terminal/session, then:

```bash
cd mobile
flutter test integration_test/full_ranked_flow_test.dart \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080
./tool/verify.sh
cd ../backend
./tool/verify.sh
```

- [ ] **Step 5: Build early-access artifacts with monetization disabled**

```bash
cd mobile
flutter build appbundle --debug --dart-define=MONETIZATION_ENABLED=false
flutter build ios --simulator --no-codesign --dart-define=MONETIZATION_ENABLED=false
```

On configured local devices, list identifiers and read the selected values into named variables before running both targets:

```bash
flutter devices --machine
: "${ANDROID_DEVICE_ID:?Export ANDROID_DEVICE_ID from flutter devices output}"
: "${IOS_SIMULATOR_ID:?Export IOS_SIMULATOR_ID from flutter devices output}"
ANDROID_API_BASE_URL="${ANDROID_API_BASE_URL:-http://10.0.2.2:8080}"
IOS_API_BASE_URL="${IOS_API_BASE_URL:-http://127.0.0.1:8080}"
flutter test integration_test/full_ranked_flow_test.dart -d "$ANDROID_DEVICE_ID" \
  --dart-define=API_BASE_URL="$ANDROID_API_BASE_URL"
flutter test integration_test/full_ranked_flow_test.dart -d "$IOS_SIMULATOR_ID" \
  --dart-define=API_BASE_URL="$IOS_API_BASE_URL"
```

The Android default targets the standard emulator host alias; export `ANDROID_API_BASE_URL` with the Mac's reachable LAN address for a physical device. Record resolved IDs, URLs, and OS versions in the checkpoint review. Provider SDK behavior that controlled issuers cannot exercise is recorded as adapter-contract coverage; do not claim store-provider end-to-end coverage until sandbox Apple and Google credentials are tested.

Record all outputs and limitations in `codex/reviews/checkpoint-17-early-access.md`. Update README with verified local/ranked behavior and clearly label deployment/store publication as not yet performed.

- [ ] **Step 6: Commit and complete checkpoint 17**

```bash
git add mobile backend README.md codex
git commit -m "feat: complete ranked early-access flow"
```
