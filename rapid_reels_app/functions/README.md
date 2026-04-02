# Rapid Reels Cloud Functions

Firebase Cloud Functions for the Rapid Reels application.

## Setup

1. Install dependencies:
```bash
cd functions
npm install
```

2. Set up Stripe credentials (for production):
```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
```

Alternatively, set local environment variables:
```bash
export STRIPE_SECRET_KEY="sk_test_xxx"
export STRIPE_WEBHOOK_SECRET="whsec_xxx"
```

3. Deploy functions:
```bash
npm run deploy
```

## Functions

### Booking Functions

- `onBookingCreated`: Sends notifications when a new booking is created
- `sendBookingReminders`: Scheduled function that sends reminders for upcoming bookings

### Payment Functions

- `createStripePaymentIntent`: Creates GBP-only Stripe PaymentIntent for booking
- `stripeWebhook`: Handles Stripe payment lifecycle and updates transactions

### Referral Functions

- `processReferral`: Processes referral rewards when a new user signs up

### Reel Functions

- `onReelDelivered`: Sends notifications when a new reel is delivered to customer

## Local Testing

Run the emulator:
```bash
npm run serve
```

## Logs

View logs:
```bash
npm run logs
```

