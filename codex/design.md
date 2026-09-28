# Generał Dice Game — Product and Architecture Design

**Created:** 2026-09-27
**Last updated:** 2026-09-28
**Status:** Approved conversational design, revised identity and monetization awaiting written-spec review

## 1. Purpose and success criteria

Generał is a polished, cross-platform dice game for iOS and Android. Its first audience is the Polish market, while its structure and English launch translation make later international expansion straightforward. The initial release combines a fast solo score challenge with local pass-and-play for two to four people.

The product should succeed on three levels:

- It feels as immediate and pleasant as a physical tabletop game: rolls are quick, the whole scorecard remains understandable, and players can hand the phone around without explanation.
- It treats regional competition as a motivating layer rather than a condition for play. A player can always play locally, including offline, and completed solo games can be submitted later.
- It demonstrates a credible mobile/backend integration: a Flutter client, a Java Spring service, federated Apple/Google identity, durable score submissions, versioned game rules, and country, continent, and global leaderboards.

The first release excludes live online multiplayer, computer opponents, subscriptions, consumable currencies, loot boxes, achievements, friend systems, and fine-grained geographic rankings. Early access launches without advertising or in-app purchases; restrained advertising and a lifetime Premium purchase can be enabled before wider promotion after retention is measured.

## 2. Product modes and main flow

### 2.1 Solo score challenge

A solo game uses one selected ruleset. The player completes the full scorecard and sees the final total and a comparison with recent personal performance. A completed game is stored locally before any network action. If the player chose ranked play and has linked an Apple or Google identity, the client submits the result immediately when online or queues it for retry. If the player has not signed in, the completed result stays attached to that installation's local guest profile and the app offers to claim and submit it through one-tap platform sign-in.

There is no daily play limit. Players may start and submit as many completed ranked games as they want. Weekly rankings use a rolling window of recent results to reward consistent play without rewarding volume alone.

### 2.2 Local pass-and-play

Two to four players share one device. Before the game they enter names and choose one ruleset for everyone. Turns rotate in a fixed order. The phone shows every player's score next to the others, with the active player's column highlighted in gold. At the end, the app ranks the local players by final score.

Pass-and-play results are local and do not enter public solo leaderboards in version one.

### 2.3 Turn interaction

Every turn starts with five dice. A player may roll up to three times. After each roll, individual dice can be held or released. The player may score after any roll, including the first. To finish a turn, the player selects one unused category. A qualifying roll receives the category's calculated score; a non-qualifying roll can be deliberately entered as zero. The app asks for a concise confirmation before recording a zero to prevent accidental sacrifices.

The game autosaves after each roll, hold change, and category selection. An interrupted game resumes at the exact turn and roll state.

### 2.4 Guest and account experience

The app opens directly into a guest experience. Local solo and pass-and-play require no registration, email address, password, or backend connection. Sign-in is delayed until it provides visible value: public leaderboard submission, recovery of an accepted ranked profile and its history, or Premium purchase and restoration. Active games, unranked history, pass-and-play history, and local settings remain device-local in version one and are not presented as cloud-synchronized data.

Both providers are available on both platforms. The primary action is **Continue with Apple** on iOS, with Google as the secondary option. Android presents **Continue with Google** as primary and Apple through its supported browser authorization flow as secondary. A player can therefore recover an Apple-linked profile on Android or a Google-linked profile on iOS and then link the platform's native provider. Nickname and country remain explicit game-profile settings and do not come from a provider account automatically.

An offline completed ranked game remains queued under a random local guest-profile identifier. After identity exchange, the app explicitly asks whether to claim the listed pending results for the signed-in player. On confirmation, it durably binds their UUIDs to that backend player before the first submission attempt. A bound result can never be reassigned: signing out or switching accounts leaves it hidden and pending until its original player authenticates again. Declining the claim keeps the results and personal statistics local without repeatedly interrupting play. Pass-and-play results are never claimable or submitted.

### 2.5 Monetization experience

Early access disables both advertising and in-app purchases so retention and game quality can be measured without monetization noise. Before wider promotion, the free version may enable restrained full-screen advertising and the Premium purchase under these rules:

- the first five completed solo games on an installation are ad-free;
- pass-and-play never contributes to the advertising counter and never shows a full-screen ad;
- after the exemption, at most one full-screen ad may appear for each three additional completed solo games, making game eight the earliest possible first ad;
- the durable counter is installation-scoped and survives app restarts; clearing application data or reinstalling may reset it;
- ads appear only after the final solo result is safely stored and never during a turn, score choice, or unfinished game;
- dismissing or failing to load an ad never blocks results, another game, or leaderboard submission;
- advertising never grants extra rolls, score changes, ranking advantages, or other competitive benefits.

A one-time, non-consumable **Premium lifetime** purchase launches at a target Polish price of 19.99 PLN, with final regional tiers configured in the stores. Premium removes advertising, unlocks additional dice/table/scorecard themes, and enables detailed personal statistics. All rulesets, local modes, and public leaderboards remain free. Sign-in is required before purchase or restoration so the backend can verify the store transaction and attach the entitlement to one internal player. A validated entitlement follows that linked profile across signed-in devices and platforms; the original store also retains its normal restore mechanism.

Optional rewarded theme previews and separate cosmetic theme packs are deferred until usage supports them. Version one has no monthly subscription because the game does not yet provide enough recurring content or service value to justify one.

## 3. Visual and interaction direction

The selected direction is **Modern Tabletop**: a deep green felt background, warm ivory scorecard surfaces, restrained gold accents, tactile dice, and clear typography. The visual identity should suggest a contemporary board-game table without simulating wood, paper, or shadows so heavily that the interface becomes busy.

The primary orientation is portrait. During pass-and-play, the scorecard uses category rows and one player column per participant. Two to four columns must remain visible together; compact totals and horizontally economical names preserve comparison. The active player's full column receives a subtle gold tint and gold header treatment. No additional turn marker is necessary unless usability testing shows that the highlight is insufficient.

The dice and roll action remain visually dominant while the active turn is being played. Category rows show a live potential score after a roll, distinguish available and already-used categories, and never rely on color alone. Motion should be brief and purposeful: dice roll, selection, score placement, and total change. Reduced-motion settings must be respected.

## 4. Versioned rulesets

The app launches with three recognizable dice-game families. A ruleset has an immutable identifier and integer version. A scoring change creates a new version rather than modifying results already stored under an older one.

All rulesets share five dice, up to three rolls per turn, held dice, one category recorded per turn, and the ability to record zero in any unused category.

### 4.1 Polish Generał (`polish-general:v1`)

This is the primary Polish-market ruleset and has thirteen categories.

| Category | Qualification | Score |
|---|---|---|
| Jedynki–Szóstki | Any roll | Sum of dice matching the selected face |
| Trzy jednakowe | At least three dice of one face | Exactly three matching dice; four or five matching dice still score only three |
| Cztery jednakowe | At least four dice of one face | Exactly four matching dice; five matching dice still score only four |
| Full | Exactly three of one face and two of another | Sum of all five dice |
| Mały strit | Exactly 1, 2, 3, 4, 5 | 15 |
| Duży strit | Exactly 2, 3, 4, 5, 6 | 20 |
| Generał | Five dice of one face | Sum of all five dice plus 50 |
| Szansa | Any roll | Sum of all five dice |

If the sum of Jedynki through Szóstki reaches at least 63, the upper section receives a 50-point bonus. Generał has no repeat bonus and there is no joker behavior. A five-of-a-kind may be recorded as Trzy jednakowe or Cztery jednakowe using the exact matching-dice limits above.

Examples:

- `6,6,6,6,2` scores 18 in Trzy jednakowe and 24 in Cztery jednakowe.
- `6,6,6,6,6` scores 18 in Trzy jednakowe, 24 in Cztery jednakowe, or 80 in Generał.

### 4.2 Classic Yahtzee-style (`classic-yahtzee:v1`)

This ruleset follows the familiar thirteen-category Yahtzee structure.

| Category | Qualification | Score |
|---|---|---|
| Ones–Sixes | Any roll | Sum of dice matching the selected face |
| Three of a kind | At least three dice of one face | Sum of all five dice |
| Four of a kind | At least four dice of one face | Sum of all five dice |
| Full house | Three of one face and two of another | 25 |
| Small straight | At least four consecutive faces | 30 |
| Large straight | Five consecutive faces | 40 |
| Yahtzee | Five dice of one face | 50 |
| Chance | Any roll | Sum of all five dice |

An upper-section total of at least 63 receives 35 points. If the Yahtzee category already contains 50 and another five-of-a-kind is rolled, the player receives a 100-point Yahtzee bonus. If the matching upper category is unused, the roll must be recorded there. Otherwise it may be recorded in an unused lower category; Full House, Small Straight, and Large Straight then receive their fixed joker scores of 25, 30, and 40. If the matching upper category and every lower category are already filled, the roll must be entered as zero in any unused upper category. If the Yahtzee category previously received zero, later five-of-a-kind rolls receive no Yahtzee bonus and no joker treatment. Shared conformance fixtures cover each branch so the mobile and server interpretations cannot diverge.

### 4.3 Scandinavian Yatzy (`scandinavian-yatzy:v1`)

This ruleset has fifteen categories.

| Category | Qualification | Score |
|---|---|---|
| Ones–Sixes | Any roll | Sum of dice matching the selected face |
| One pair | At least two matching dice | Sum of the two dice in the highest qualifying pair |
| Two pairs | Two distinct pairs | Sum of those four dice |
| Three of a kind | At least three matching dice | Exactly three matching dice |
| Four of a kind | At least four matching dice | Exactly four matching dice |
| Full house | Exactly three of one face and two of another | Sum of all five dice |
| Small straight | Exactly 1, 2, 3, 4, 5 | 15 |
| Large straight | Exactly 2, 3, 4, 5, 6 | 20 |
| Chance | Any roll | Sum of all five dice |
| Yatzy | Five dice of one face | 50 |

An upper-section total of at least 63 receives 50 points. There is no repeated-Yatzy bonus or joker behavior.

The public display names will receive a trademark and store-listing review before release. Internal identifiers remain neutral and stable regardless of later naming changes.

### 4.4 Ruleset contract and conformance

The client exposes a `Ruleset` abstraction containing:

- stable identifier and version;
- localized name and description keys;
- ordered category definitions;
- roll and round limits;
- category qualification and scoring functions;
- section bonus rules;
- repeated five-of-a-kind and joker policy;
- final-total calculation.

The Flutter and Spring implementations remain native to their languages. They share versioned JSON conformance fixtures in the repository's `rulesets/` directory. Fixtures describe dice, selected category, prior scorecard state where relevant, validity, category score, bonuses, and final totals. Both engines run the same fixtures in their test suites. Fixture changes are reviewed as rules changes and require a new ruleset version if they alter a released result.

Each game stores its ruleset identifier and version. Scorecards render dynamically from the ordered category list, so the fifteen-row Scandinavian card does not require a separate screen. Public leaderboards never combine different rulesets or versions.

## 5. Mobile architecture

The mobile app uses Flutter and standard Flutter widgets. State management should remain lightweight and selected during implementation planning based on current stable ecosystem support; the domain model must not depend on that choice.

The app is divided into four layers:

1. **Domain:** pure Dart dice, scorecard, turn, game, player, and ruleset models plus deterministic scoring. It has no Flutter, persistence, or network dependencies.
2. **Application:** game controllers/use cases that coordinate rolls, holds, scoring, turn rotation, autosave, and ranked submission state.
3. **Data:** local game persistence, preferences, secure backend credentials, federated sign-in adapters, purchase entitlement state, advertising consent/state, pending submission queue, and typed API client implementations behind interfaces.
4. **Presentation:** Flutter screens, widgets, navigation, localization, animation, accessibility, and the Modern Tabletop theme.

Random dice generation belongs to a replaceable `DiceRoller` interface. Version one uses an on-device cryptographically appropriate random source where Flutter/Dart supports it. Tests inject deterministic rolls. The server does not generate or authorize individual rolls in version one.

The planned repository is a monorepo:

```text
mobile/                  Flutter application
backend/                 Spring Boot application
codex/                   Plans, reports, reviews, and development evidence
rulesets/                Shared JSON conformance fixtures
```

## 6. Backend architecture

The backend is a Java Spring Boot modular monolith backed by PostgreSQL. A modular monolith keeps deployment and transactions simple while demonstrating clear boundaries that could later be extracted if scale justifies it.

Its modules are:

- **Identity:** Apple/Google identity exchange and verification, provider linking, backend token issuance and refresh, nickname, country selection, account recovery, and account deletion.
- **Games:** idempotent result submission, ruleset-version validation, score-range and arithmetic validation, and immutable accepted results.
- **Leaderboards:** weekly qualification, rolling-last-ten aggregates, tie breaking, regional filtering, and historical weekly views.
- **Statistics:** personal recent games and locally useful summary data exposed through the API.
- **Entitlements:** server-validated App Store and Google Play purchases, lifetime Premium state, restoration, and entitlement lookup.

Flutter obtains a short-lived Apple or Google identity credential and sends it to the backend over TLS. Spring verifies the credential signature, issuer, audience, expiry, and nonce where applicable, then resolves the stable provider subject. Email address is optional profile data and is never the account key. The backend creates or links the internal player and returns its own short-lived access token plus rotated refresh credentials. Spring Security protects profile, entitlement, submission, and leaderboard-personalization endpoints with those backend credentials; provider tokens are not used as ordinary API session tokens.

Flyway owns database migrations. OpenAPI defines the client/server contract and supports generating or validating the Flutter API client. Testcontainers supplies real PostgreSQL integration tests. Structured application logs, request correlation identifiers, health endpoints, and basic submission/leaderboard metrics are included from the first deployable version. Hosting provider selection is deferred to implementation/deployment planning and does not change these boundaries.

## 7. Data model

The conceptual relational model contains:

- `player_profile`: ID, nickname, selected country code, derived continent code, locale preferences, created/updated timestamps.
- `external_identity`: player ID, provider (`APPLE` or `GOOGLE`), stable provider subject, provider metadata, linked timestamp; provider and subject are unique together.
- `refresh_session`: player ID, hashed refresh credential, device/session metadata, rotation state, expiry, and revocation timestamps.
- `game_result`: client-generated UUID, player ID, ruleset ID and version, client completion time, server receipt time, snapshotted country and continent, submitted category scores, submitted bonuses, server-calculated values, final score, app version, acceptance status.
- `weekly_player_result`: week, player, ruleset ID/version, region snapshots, number of accepted games in the current window, sum and average of the latest ten, best single score, and the timestamp at which the ranking value was achieved.
- `purchase_entitlement`: player ID, store, product ID, normalized original transaction/purchase identifier, verification status, entitlement type, purchase timestamp, and revocation state. Player ID and transaction identifier are required, and `(store, normalized transaction identifier)` is globally unique.

Accepted game results are immutable during the life of an account. Corrections happen through explicit administrative records or a new ruleset version, never by silently rewriting history. Account deletion is the privacy exception: identifying result rows and leaderboard entries are deleted or irreversibly anonymized according to the published retention policy, while non-identifying aggregate operational metrics may remain. Country uses ISO 3166-1 alpha-2 codes. Continent is derived on the server from a versioned mapping and both region values are copied onto each result. Changing profile country affects only later submissions.

The raw result schema preserves enough stable facts—ruleset version, regional snapshot, client and server timestamps, category scores, and calculated total—to feed a later ETL pipeline or specialized read store. Version one queries PostgreSQL and maintains transactional weekly summaries; it does not introduce a warehouse or streaming platform.

## 8. API surface and data flow

The first API provides:

- Apple/Google credential exchange, provider linking, backend token refresh, sign-out/session revocation, and account deletion;
- nickname and selected-country update;
- idempotent ranked solo result submission;
- personal result history and summary statistics;
- paginated current and previous weekly leaderboards for country, continent, and global scope, filtered by ruleset version;
- store purchase verification, Premium entitlement lookup, and restoration support.

Guest play does not create a backend account. The first successful provider exchange creates the internal player profile. Linking a second provider requires an authenticated backend session plus fresh proof from that provider. Because both providers are available on both operating systems, a returning player signs in with an already-linked provider first and can then link the native provider of the new device.

A provider identity already linked to another player is rejected rather than silently merging accounts. If a player accidentally created two internal profiles, version one keeps them separate: the app explains which provider belongs to which profile, lets the player sign out and recover the intended profile, and does not transfer results automatically. Account deletion revokes sessions and provider links, removes the profile from leaderboards, and deletes or irreversibly anonymizes retained game data according to the published retention policy.

After verifying a store transaction, the backend normalizes its store-specific stable identifier. Repeating that transaction for the same player is an idempotent restoration and returns the existing entitlement. Presenting it under another player is rejected with a stable ownership-conflict error and never moves or duplicates Premium access. The response does not reveal the existing owner's identity.

A result submission contains the game UUID, client completion timestamp, ruleset ID/version, every category score, bonuses, submitted final score, and app version. The server authenticates the profile, resolves the current profile region snapshot, checks that the ruleset version is supported, validates each category against the numeric values permitted by that ruleset, recalculates bonuses and the arithmetic final total, and rejects inconsistent or numerically impossible scorecards. On acceptance, it stores the immutable result and updates the weekly aggregate in one transaction.

The same UUID always represents the same logical result. Retrying an identical accepted submission returns the existing success response. Reusing a UUID with different content returns a stable conflict error. Database uniqueness and transaction boundaries protect this behavior under concurrent retries.

Because version one receives category totals rather than the roll sequence, it cannot verify that an individual category score came from the player's actual dice, prove that dice were rolled fairly, or prove that a result came from an unmodified client. Validation catches malformed totals, values outside a category's possible range, invalid bonuses, and arithmetic inconsistencies, not fabricated but numerically valid scores. Rankings should be described as community competition until a later release adds server-authorized rolls or signed replay verification.

## 9. Weekly rankings and regions

Leaderboards are separated by calendar week, ruleset identifier/version, and one of three scopes:

- **Country:** other results with the same submitted country snapshot;
- **Continent:** other results with the same derived continent snapshot;
- **Global:** all accepted results for that ruleset version.

Weeks start Monday at 00:00 UTC and end immediately before the next Monday at 00:00 UTC. The server assigns a result to a week using server receipt time, which prevents backdating and makes delayed offline submissions predictable. Previous weeks remain readable.

The ranking value is the arithmetic mean of a player's latest ten accepted games received during that week. A player with one to nine games is shown as provisional with an `x/10` indicator but is not placed in the ranked list. After ten games, each newly accepted game enters the window and the oldest one leaves it. The UI may display the mean to one decimal place; ordering uses the exact stored sum or equivalent exact decimal value to avoid display-rounding ties.

Ties are resolved by:

1. higher best single-game score among the ten games in the active window;
2. earlier server receipt time at which the current ten-game ranking value was achieved;
3. stable player ID as a deterministic final database ordering key.

Each scope calculates its own ten-game window. A country board uses a player's latest ten accepted games bearing that country snapshot, a continent board uses the latest ten bearing that continent snapshot, and the global board uses the latest ten regardless of region. If a player changes country midweek, earlier results remain in their original country and continent because every result retains its submission-time snapshots. This explicitly prevents historical scores moving between regions. It also means the player's country, continent, and global averages can differ during the same week.

The app also calculates and displays the player's local average from the most recent ten completed games for personal feedback. This local statistic can include unranked or not-yet-submitted games and is visually labeled separately from the server's weekly ranked average.

## 10. Localization and accessibility

Polish and English ship in version one. Flutter ARB resources, such as `app_pl.arb` and `app_en.arb`, contain all user-visible strings. Domain entities expose stable localization keys rather than embedded names. The backend returns stable error codes and structured arguments; it does not return sentences intended for direct display.

Dates, numbers, decimal separators, and week labels use the current locale while stored timestamps remain UTC. Layouts must accommodate longer translations and enlarged system text. Dice expose spoken face values and selected/held state. Scorecard cells expose category name, current score or availability, player, and active state to assistive technologies. Color is reinforced with shape, weight, label, or icon changes.

## 11. Offline behavior and failure handling

Local solo and pass-and-play never depend on backend availability or sign-in. Each active game is persisted after every meaningful action. A completed ranked result is finalized locally before submission and remains visible while pending.

The submission queue retries transient failures with bounded exponential backoff and connectivity-triggered retry. It always reuses the original game UUID. Missing identity leaves the result under its local guest profile until an explicit claim. Once claimed, the result stores the backend player ID locally and can be submitted only under that identity. Authentication expiry pauses the queue until the matching backend session refreshes or that player signs in again. Permanent validation failures remain attached to the local result with a translated explanation and a diagnostic code; the client does not silently discard them.

The API uses stable error codes for invalid scorecards, unsupported ruleset versions, conflicting UUID reuse, expired credentials, invalid nickname or country, rate limiting, and temporary service failure. A leaderboard read failure shows cached data with its update time when available and otherwise an unobtrusive retry state. It never blocks starting or continuing a local game.

When a ruleset version is retired from new rankings, an already-started local game can still be completed. The app states before submission if that version is no longer eligible. The backend retains the ability to read historical results and boards for supported historical versions.

## 12. Verification strategy

### Mobile

- Unit tests cover every ruleset category, edge case, bonus threshold, zero sacrifice, turn transition, and final total.
- The Dart engine runs all shared JSON conformance fixtures.
- Application tests cover three-roll limits, hold behavior, player rotation, autosave/resume, pending submission retries, backend-session refresh, explicit guest-result claims, durable owner binding, sign-out, and account switching.
- Widget tests cover one through four players, thirteen- and fifteen-category layouts, Polish and English strings, sign-in prompts, large text, and semantic labels.
- Monetization tests cover the first-five-solo-games exemption, the game-eight earliest-ad boundary, durable installation counters, pass-and-play exclusion, Premium ad removal, failed-ad fallthrough, sign-in-required purchase and restoration, and the absence of competitive rewards.
- Golden image tests protect the Modern Tabletop scorecard and dice states at representative phone sizes.

### Backend

- The Java engine runs the identical conformance fixtures and rejects altered totals.
- Unit tests cover weekly boundaries, exact averaging, rolling-window eviction, provisional status, all tie breakers, and country-change behavior.
- Testcontainers integration tests cover PostgreSQL transactions, Flyway migrations, regional queries, pagination, UUID idempotency, concurrent duplicate submissions, result-owner mismatch rejection, provider-link conflicts, two-existing-profile conflicts, refresh-token rotation, account deletion, same-player purchase restoration, and cross-player store-transaction replay rejection.
- Identity tests use controlled Apple/Google-compatible test issuers and keys to cover issuer, audience, signature, expiry, nonce, and stable-subject validation without calling production identity services.
- OpenAPI compatibility tests protect the mobile contract and stable error shapes.

### End to end

A local test environment runs Flutter against Spring Boot and PostgreSQL with controlled identity and store-verification fakes. Its critical scenarios are guest play without a backend account, explicit pending-result claim, sign-out without result reassignment, cross-platform recovery with the secondary provider, linking the new platform's native provider, rejection of two-existing-profile conflicts, profile country selection, an accepted ranked submission, an identical retry, a conflicting UUID retry, provisional progress through ten games, sign-in-required Premium purchase and restoration, ad suppression for Premium, and the same eligible result appearing correctly in country, continent, and global views.

## 13. Security, privacy, and operational limits

The service stores only the profile information required for play: stable provider subject, nickname, country, locale preferences, purchase entitlement, and game results. Provider email and name are not required and are discarded unless a later reviewed feature needs them. No GPS location is requested. Nicknames are length-limited, normalized, and moderated with a practical release-appropriate policy. API inputs have explicit size and range limits, and identity, purchase, and submission endpoints are rate-limited.

Backend refresh credentials are stored using platform secure storage. Provider and backend tokens never enter ordinary logs. Transport uses TLS, purchase verification is performed server-side against the relevant store, and advertising SDKs initialize only after the required consent state is established. The privacy settings let eligible users revisit advertising consent. Database backups and restore checks are part of deployment readiness.

The initial leaderboard design is suitable for launch and portfolio demonstration, but client-generated dice limit competitive integrity. Server-authorized rolls, signed action logs, anomaly detection, and appeal/admin tooling are later security increments if usage makes them worthwhile.

## 14. Delivery boundaries and future evolution

Version one delivers the complete local game, the three versioned rulesets, Polish and English, guest local play, Apple/Google-linked profiles for ranked play and recovery of accepted ranked data, reliable ranked solo submissions, personal statistics, weekly country/continent/global leaderboards, and the technical seams for the staged advertising/Premium model. Early access keeps ads and purchases disabled until retention has been measured; the wider public release can enable the approved post-game ads and lifetime Premium purchase without redesigning the app.

Likely later increments are:

- server-authorized dice or compact replay verification for stronger ranked integrity;
- passkeys or other identity providers if they materially improve recovery;
- a subscription only if recurring tournaments, seasonal content, or another sustained service creates continuing value;
- more translations and market-specific rulesets;
- friends and private groups;
- analytics/ETL and a specialized leaderboard read model if PostgreSQL summaries become insufficient;
- additional regional levels only if users demonstrate a need for them.

These extensions must build on immutable results, stable ruleset versions, localization keys, and region snapshots established in version one.
