# Stripe Production Integration Guide

## Decision

Use a backend-first Stripe integration for production.

- Flutter app uses only Stripe publishable key (`pk_live`).
- Backend (Firebase Functions/Node.js) handles all Stripe secret-key operations.
- Webhook is the source of truth for payment status in Firestore.
- Runtime currency is locked to GBP (`gbp`) only.
- Legacy Razorpay endpoints are disabled (HTTP 410).

## UK-only currency lock

- `createStripePaymentIntent` rejects non-GBP booking currencies.
- `stripeWebhook` normalizes fallback currency values to `gbp`.
- New migration utility for existing INR records:
  - `npm run migrate:inr-gbp:dry`
  - `npm run migrate:inr-gbp -- --fxRate=0.0095 --batchId=fx_2026_uk_rollout`

## Why this is mandatory

- Mobile apps can be reverse engineered; any embedded secret key can be extracted.
- Exposed `sk_live` allows unauthorized Stripe API activity against your account.
- Client-controlled amount values can be tampered with unless server recalculates from trusted booking data.

## Approved architecture

1. Client creates booking in Firestore with `payment.paymentStatus = pending`.
2. Client calls callable function `createStripePaymentIntent` with only `bookingId`.
3. Backend validates caller ownership, reads booking, computes amount from `payment.advanceAmount`, and creates/reuses PaymentIntent.
4. Backend returns only `clientSecret` and `paymentIntentId`.
5. Client presents Stripe PaymentSheet.
6. Stripe webhook updates booking status (`confirmed` / `failed`) authoritatively.

## Current implementation in this project

- Client no longer sends Stripe secret key.
- Client payment intent creation is now callable-only.
- Backend `createStripePaymentIntent` now:
  - validates authenticated caller
  - verifies booking ownership (`customerId`)
  - computes amount on server from booking data
  - applies Stripe idempotency key to avoid duplicate intents
  - reuses existing non-canceled PaymentIntent when available
- Webhook now protects against duplicate event processing using Stripe event IDs.

## Key management policy

### Flutter app

- Allowed: `pk_test`, `pk_live`
- Forbidden: `sk_test`, `sk_live`

### Backend only

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`

## Production rollout steps

1. Configure backend secrets (Firebase Secret Manager). From `rapid_reels_app` run:
   - `firebase functions:secrets:set STRIPE_SECRET_KEY` (paste `sk_live_...` when prompted)
   - `firebase functions:secrets:set STRIPE_WEBHOOK_SECRET` (paste `whsec_...` when prompted)
   - Ensure **Secret Manager API** is enabled for your GCP project and your account can create secrets.
2. Deploy functions so `createStripePaymentIntent` and `stripeWebhook` receive those secrets:
   - `firebase deploy --only functions`
3. Local emulator: copy `functions/.env.example` to `functions/.env` for **test** keys only (never commit `.env`).
4. Configure webhook endpoint in Stripe Dashboard to your deployed `stripeWebhook` URL.
5. Build app with live publishable key:
   - `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...`
6. Run real low-value transaction test in live mode.
7. Validate webhook-driven booking state transitions in Firestore.
8. Rotate any test/possibly exposed secret keys and disable old keys.

## Payment transaction tracking (canonical)

Production writes each Stripe PaymentIntent lifecycle event into
`payment_transactions/{transactionId}` as the source of truth.

- `transactionId` = Stripe `payment_intent.id`
- Linked fields: `bookingId`, `customerUserId`, `providerUserId`
- Status lifecycle: `processing`, `succeeded`, `failed`, `canceled`
- Failure metadata: `failureCode`, `failureMessage`
- Audit metadata: `stripeEventId`, `isLiveMode`, timestamps

Booking payment map remains as a compatibility summary:

- `bookings.payment.paymentStatus`
- `bookings.payment.lastTransactionRef`
- `bookings.payment.transactions` (lightweight UI summary)

## Provider/Admin visibility

- Provider and Admin payment views read from `payment_transactions`.
- Booking detail views show all transactions for a given `bookingId`.
- Notifications are inserted into `notifications` on success/failure
  for provider and admin users.

## Failure and reconciliation checklist

- Track failed/canceled events with exact Stripe error fields.
- Use Stripe event id deduplication (`stripe_webhook_events`) to avoid duplicate processing.
- Reconcile records where booking remains `pending` for too long by checking latest
  payment status in `payment_transactions` and Stripe dashboard logs.

## Security checklist before go-live

- [ ] No `sk_` keys in Flutter code or mobile build defines.
- [ ] Backend secrets set through secure env/secrets manager only.
- [ ] Backend computes charge amount from trusted booking record.
- [ ] Webhook signature verification enabled.
- [ ] Duplicate webhook event handling enabled.
- [ ] Logs do not print keys, client secrets, or raw card details.
- [ ] Stripe Dashboard alerts and request-log monitoring reviewed.
