# Checkpoint 1 review — identity and monetization design

**Branch:** `codex/checkpoint-1-design-auth-monetization`

## Scope

This documentation checkpoint revises the product and architecture design with:

- guest-first local play and Apple/Google identity for ranked profiles;
- provider linking, backend sessions, recovery, and account deletion;
- explicit ownership for ranked results completed before sign-in;
- staged advertising and a lifetime Premium purchase;
- purchase entitlement validation and monetization verification scenarios.

## Initial independent review

The reviewer found no Critical issues and four Important issues:

1. A guest Premium purchase had no authenticated server-verification path.
2. The cloud recovery and synchronization wording exceeded the documented data and API scope.
3. Ranked results completed as a guest had no safe claim or account-switch ownership rules.
4. Cross-platform recovery depended on proactive provider linking without documenting that constraint or a secondary-provider login path.

The reviewer also identified Moderate ambiguity in the advertising counter and early-access monetization activation.

## Corrections

- Premium purchase and restoration now require sign-in, and every entitlement requires a player and unique store transaction.
- Recovery is limited to the linked ranked profile, accepted ranked history, and Premium entitlement. Active games, unranked history, pass-and-play data, and settings remain local.
- Guest ranked results use a local guest-profile identifier, require explicit claim confirmation, bind permanently to one backend player before submission, and cannot move during sign-out or account switching.
- Apple and Google are offered on both platforms, with the native provider emphasized and the other available for recovery. Existing identities are never silently merged.
- Ads count completed solo games only, exclude pass-and-play, cannot first appear before game eight, and use a durable installation-scoped counter.
- Both ads and purchases are disabled in early access and can be enabled together before wider promotion.

## Repeat independent review

The repeat review confirmed that all four Important findings and both Moderate ambiguities were resolved. No Critical or Important findings remain.

## Final evidence review

The reviewer found one additional Important backend edge case: the design required a store transaction identifier but did not make it globally unique, so one verified purchase could be replayed onto another player. The design now requires a unique normalized `(store, transaction identifier)`, treats restoration by the same player as idempotent, rejects cross-player reuse without revealing the owner, and includes an integration test for that conflict.

## Verification

- Documentation content review: passed.
- `git diff --check main...HEAD`: passed.
- Placeholder and contradiction scan: passed.
- Final independent re-review after the purchase-replay correction: pending.
- Flutter, Java, database, and end-to-end tests: not applicable because this checkpoint changes documentation only and implementation has not started.
