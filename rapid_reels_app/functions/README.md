# Rapid Reels Cloud Functions

Firebase Cloud Functions for the Rapid Reels application.

## Setup

1. Install dependencies:
```bash
cd functions
npm install
```

2. Set up Razorpay credentials (for production):
```bash
firebase functions:config:set razorpay.key_id="YOUR_KEY_ID"
firebase functions:config:set razorpay.key_secret="YOUR_KEY_SECRET"
```

Alternatively, set environment variables:
```bash
export RAZORPAY_KEY_ID="YOUR_KEY_ID"
export RAZORPAY_KEY_SECRET="YOUR_KEY_SECRET"
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

- `createRazorpayOrder`: Creates a Razorpay payment order
- `verifyRazorpayPayment`: Verifies Razorpay payment signature and updates booking

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

