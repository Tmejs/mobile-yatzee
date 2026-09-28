# Monetization and Release Controls Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add remotely/configurationally disabled-by-default advertising and a server-verified lifetime Premium purchase without changing game fairness or blocking play.

**Architecture:** Pure eligibility policies decide whether an ad or Premium feature may be offered; platform SDK adapters perform consent, ads, and store purchases behind testable interfaces. Spring verifies and uniquely owns store transactions, while the mobile app treats backend entitlement as authoritative after sign-in.

**Tech Stack:** Flutter 3.47, google_mobile_ads 9.1.0, in_app_purchase 3.3.1, Drift, Riverpod, Spring Boot 4.1.1, PostgreSQL, Apple App Store Server APIs, Google Play Developer APIs.

**Spec:** `codex/design.md`

## Global Constraints

- Do not begin this plan until the user explicitly approves monetization work after early-access retention review.
- Default all monetization flags to false in source, local profiles, and release configuration.
- Show no ad before five completed solo games; game eight is the earliest possible first ad.
- Exclude pass-and-play and unfinished games from ad counters and placements.
- Never block result storage, navigation, leaderboard submission, or a new game on consent/ad/store failure.
- Require sign-in before purchase/restoration and make `(store, normalized transaction identifier)` globally unique.
- Provide no subscription, consumable currency, loot box, extra roll, or competitive paid advantage.

## Review Focus

- Consent denied/unavailable or ad load/show callback missing must still return to results/new game; Task 18 tests watchdog and fallthrough.
- Counter state across restart, Premium activation, reinstall reset, and pass-and-play must match the spec; Task 18 pins transitions.
- Same purchase restored concurrently on two devices for one player must be idempotent; the same transaction on another player must conflict; Task 19 tests both.
- Refund/revocation must remove Premium without deleting local content or corrupting sessions; Task 19 tests notification replay/out-of-order delivery.
- Remote flags turning off mid-session must prevent new ads/purchases while preserving an in-flight verified purchase; Task 20 tests configuration races.

---

### Task 18: Monetization configuration, consent, and ad eligibility

**Files:**
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/config/PublicAppConfigController.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/config/PublicAppConfigTest.java`
- Modify: `api/openapi.yaml`
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/src/monetization/domain/monetization_config.dart`
- Create: `mobile/lib/src/monetization/domain/ad_eligibility.dart`
- Create: `mobile/lib/src/monetization/data/ad_counter_repository.dart`
- Create: `mobile/lib/src/monetization/data/ad_service.dart`
- Create: `mobile/lib/src/monetization/data/google_mobile_ad_service.dart`
- Create: `mobile/lib/src/monetization/application/post_game_ad_controller.dart`
- Create: `mobile/lib/src/monetization/presentation/privacy_settings.dart`
- Create: `mobile/test/monetization/ad_eligibility_test.dart`
- Create: `mobile/test/monetization/post_game_ad_controller_test.dart`

**Interfaces:**
- Consumes: completed solo-game event, local database, authenticated Premium state if present.
- Produces: public config endpoint and safe `PostGameAdController.maybeShowAfterSavedSoloResult()`.

- [ ] **Step 1: Write failing pure eligibility tests**

```dart
final class AdEligibility {
  const AdEligibility();
  bool shouldAttempt({
    required bool enabled,
    required bool isPremium,
    required bool isSolo,
    required int completedSoloGames,
    required int lastAdAtCompletedCount,
  });
}
```

Assert false for counts 0–7, true at 8 when no prior ad, false at 9/10 after ad at 8, true at 11, always false for pass-and-play/Premium/disabled. Persist completed count and last-ad count across repository recreation.

- [ ] **Step 2: Add disabled-by-default backend config**

`GET /v1/config` returns:

```json
{
  "monetizationEnabled": false,
  "adsEnabled": false,
  "premiumPurchaseEnabled": false,
  "premiumProductId": "premium_lifetime"
}
```

Values come from validated server configuration; absence resolves to false. Regenerate the mobile API and verify no diff on a second generation.

- [ ] **Step 3: Add SDK and write failing fallthrough tests**

Run: `cd mobile && flutter pub add google_mobile_ads:9.1.0`

```dart
abstract interface class AdService {
  Future<ConsentState> requestConsent();
  Future<AdShowResult> showInterstitial();
  Future<void> openPrivacyOptions();
}
```

Tests cover denied consent, not-required consent, unavailable form, load failure, show failure, dismissal, callback never arriving, config turning off, and Premium activation. Every path completes within a test-controlled timeout and returns navigation control.

- [ ] **Step 4: Implement UMP/AdMob adapter and durable counters**

Initialize the ads SDK only when config and consent permit. Use official test ad unit IDs outside release configuration. Advance `lastAdAtCompletedCount` only after a full-screen content callback confirms presentation; always advance completed-solo count after result persistence, independent of ad outcome.

Use a five-second watchdog around SDK show callbacks. On timeout, dispose the ad and continue without showing another for that same completion event.

- [ ] **Step 5: Add privacy settings and UI placement**

Privacy Settings exposes consent options when required. The game completion flow stores result first, navigates to result screen, then calls the controller; no banner/native/rewarded ad is added. Pass-and-play never calls the controller.

- [ ] **Step 6: Run gates and commit checkpoint 18**

```bash
cd mobile
flutter test test/monetization
./tool/verify.sh
cd ../backend
./tool/verify.sh
cd ..
git add api backend mobile codex
git commit -m "feat: add safe post-game advertising controls"
```

### Task 19: Server-verified lifetime Premium and paid features

**Files:**
- Create: `backend/src/main/resources/db/migration/V4__purchase_entitlements.sql`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/entitlement/Entitlement.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/entitlement/EntitlementRepository.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/entitlement/EntitlementService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/entitlement/StorePurchaseVerifier.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/entitlement/AppleStorePurchaseVerifier.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/entitlement/GoogleStorePurchaseVerifier.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/entitlement/StoreNotificationService.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/EntitlementController.java`
- Create: `backend/src/main/java/pl/tmejs/mobileyatzee/api/StoreNotificationController.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/entitlement/EntitlementIntegrationTest.java`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/entitlement/StoreNotificationIntegrationTest.java`
- Modify: `backend/src/main/java/pl/tmejs/mobileyatzee/profile/AccountDeletionService.java`
- Modify: `backend/src/test/java/pl/tmejs/mobileyatzee/profile/AccountDeletionIntegrationTest.java`
- Modify: `api/openapi.yaml`
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/src/monetization/data/store_purchase_service.dart`
- Create: `mobile/lib/src/monetization/data/platform_store_purchase_service.dart`
- Create: `mobile/lib/src/monetization/application/premium_controller.dart`
- Create: `mobile/lib/src/monetization/presentation/premium_screen.dart`
- Create: `mobile/lib/src/theme/premium_theme_catalog.dart`
- Create: `mobile/lib/src/history/premium_statistics.dart`
- Create: `mobile/test/monetization/premium_controller_test.dart`
- Create: `mobile/test/theme/premium_theme_catalog_test.dart`

**Interfaces:**
- Consumes: authenticated player/session, public config, store SDK.
- Produces: purchase verification/restoration APIs, authoritative entitlement state, ad removal, themes, advanced local statistics.

- [ ] **Step 1: Write migration and failing ownership tests**

Create `purchase_entitlement` with nullable `player_id` for deletion anonymization, non-null store/product/normalized transaction, status, purchase/revocation timestamps, raw verification audit hash, and `unique(store, normalized_transaction_id)`. A check constraint requires `player_id` while status is active; deletion first moves the row to retained/anonymized state.

Tests cover valid Apple/Google purchase, same-player repeat/restore returns same row, concurrent repeat creates one row, other-player replay returns `PURCHASE_OWNERSHIP_CONFLICT`, invalid signature/token, wrong product, refund, and revoked transaction. Responses never expose the owning player on conflict.

Add deletion cases before changing production code: active and revoked entitlements must not block account deletion. `purchase_entitlement.player_id` becomes nullable on deletion; the transaction clears it and retains only store, product, normalized transaction ID, status, event times, and audit hash for refund/replay/audit obligations. The deleted player cannot be reconstructed from retained purchase rows, while the global transaction uniqueness constraint remains effective. Document the retention window in the privacy inventory and test that a later different player still receives `PURCHASE_OWNERSHIP_CONFLICT` without owner details.

- [ ] **Step 2: Implement verifier boundary and production adapters**

```java
public interface StorePurchaseVerifier {
    VerifiedPurchase verify(Store store, String productId, String proof);
}

public record VerifiedPurchase(
    Store store,
    String normalizedTransactionId,
    String productId,
    Instant purchasedAt,
    PurchaseState state) {}
```

Apple adapter verifies signed transaction/JWS chain and bundle/product/environment. Google adapter calls the Play Developer product purchase API and verifies package/product/purchase state. Credentials/keys come from secret configuration and never persist in repository or logs.

- [ ] **Step 3: Implement notification idempotency and ordering**

Verify App Store Server Notification V2 and Google RTDN authenticity, store notification IDs uniquely, and apply events only when their store event time/version is newer than the entitlement state. Duplicate or out-of-order notifications return success without rolling state backward.

- [ ] **Step 4: Add Flutter IAP and failing controller tests**

Run: `cd mobile && flutter pub add in_app_purchase:3.3.1`

Tests assert sign-in required before store UI, disabled config prevents purchase, pending transaction remains visible, client sends proof to backend before enabling Premium, backend rejection completes/finishes store flow safely, restore is idempotent, refund removes Premium, and API outage never charges twice.

- [ ] **Step 5: Implement Premium UI and features**

Product screen displays store-localized price, one-time wording, Restore Purchases, and benefits. Premium state comes from backend entitlement after verification. Gate only:

- ad suppression;
- additional dice/table/scorecard themes;
- detailed local statistics such as per-category average, best score by ruleset, and score trend.

Do not gate rulesets, leaderboards, local modes, or ranked submissions.

- [ ] **Step 6: Regenerate client and run both gates**

```bash
./tool/generate-mobile-api.sh
cd backend
./mvnw -Dtest='*Entitlement*,*StoreNotification*' test
./tool/verify.sh
cd ../mobile
flutter test test/monetization test/theme
./tool/verify.sh
```

- [ ] **Step 7: Commit and complete checkpoint 19**

```bash
cd ..
git add api api-clients backend mobile codex
git commit -m "feat: add lifetime Premium entitlement"
```

### Task 20: Monetized release-candidate verification

**Files:**
- Create: `mobile/integration_test/monetization_flow_test.dart`
- Create: `backend/src/test/java/pl/tmejs/mobileyatzee/MonetizationEndToEndTest.java`
- Create: `docs/privacy-data-inventory.md`
- Create: `docs/store-release-checklist.md`
- Modify: `README.md`
- Modify: `codex/progress.md`
- Create: `codex/reviews/checkpoint-20-monetized-release-candidate.md`

**Interfaces:**
- Consumes: complete product.
- Produces: locally verified release candidate with explicit activation and store/publication steps remaining manual.

- [ ] **Step 1: Write full monetization integration scenarios**

With fake consent/ad/store layers plus real local database/backend, cover games 1–7 no ad, game 8 ad attempt, pass-and-play exclusion, failure/dismissal fallthrough, Premium purchase, immediate ad suppression, restore on second signed-in device, cross-player replay rejection, refund notification, and Premium removal.

- [ ] **Step 2: Test configuration races**

Turn ads off between eligibility and show: no ad. Turn purchase off before store UI: no purchase. Turn purchase off after a store transaction begins: finish server verification and grant valid purchase, but prevent new attempts. Cache config only with a short documented expiry and default every missing/stale safety flag to false.

- [ ] **Step 3: Produce privacy and store evidence**

`docs/privacy-data-inventory.md` lists every SDK, datum, purpose, retention/deletion path, consent dependency, and platform disclosure. `docs/store-release-checklist.md` includes Apple/Google identity configuration, account deletion URL/flow, privacy policy, UMP messages, AdMob IDs, store product IDs, server notification URLs, screenshots, age rating, and restore-purchase check.

- [ ] **Step 4: Run complete repository gate**

```bash
docker compose up -d postgres
cd backend
./tool/verify.sh
cd ../mobile
./tool/verify.sh
flutter test integration_test/full_ranked_flow_test.dart \
  --dart-define=MONETIZATION_ENABLED=false
flutter test integration_test/monetization_flow_test.dart \
  --dart-define=MONETIZATION_ENABLED=true \
  --dart-define=USE_FAKE_ADS=true \
  --dart-define=USE_FAKE_STORE=true
flutter build appbundle --release --dart-define=MONETIZATION_ENABLED=false
flutter build ios --release --no-codesign --dart-define=MONETIZATION_ENABLED=false
```

Release builds deliberately remain monetization-disabled. Record artifact hashes and all results in the checkpoint review.

- [ ] **Step 5: Update README and commit**

README may state only locally verified behavior. It must say store submission, production identity review, live purchase sandbox validation, live ad consent validation, and production activation remain incomplete until actually performed.

```bash
cd ..
git add mobile backend docs README.md codex
git commit -m "test: verify monetized release candidate"
```

- [ ] **Step 6: Complete checkpoint 20 without activating monetization**

Perform independent whole-product review, fix every Critical/Important finding, rerun the complete gate, preserve the branch, merge with `--no-ff`, and verify SHAs. Ask the user separately before changing production config, publishing store products, or submitting either app to a store.
