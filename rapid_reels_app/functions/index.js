const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {defineSecret} = require("firebase-functions/params");
require("dotenv").config();
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const Stripe = require("stripe");

admin.initializeApp();

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

// Emulator: use `functions/.env`. Deployed: secrets bound via `secrets` on each function.
function resolveStripeApiKey() {
  if (process.env.STRIPE_SECRET_KEY) {
    return process.env.STRIPE_SECRET_KEY;
  }
  return stripeSecretKey.value();
}

function resolveWebhookSecret() {
  if (process.env.STRIPE_WEBHOOK_SECRET) {
    return process.env.STRIPE_WEBHOOK_SECRET;
  }
  return stripeWebhookSecret.value();
}

function stripeClient() {
  const key = resolveStripeApiKey();
  return key ? new Stripe(key) : null;
}

function setCorsHeaders(response) {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.set("Access-Control-Allow-Headers", "Content-Type, stripe-signature");
}

// Send notification when booking is created
exports.onBookingCreated = onDocumentCreated(
    "events/{eventId}",
    async (event) => {
      const booking = event.data.data();
      const eventId = event.params.eventId;

      logger.info("New booking created:", eventId);

      try {
        // Get customer's FCM token
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(booking.customerId)
            .get();

        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          // Send notification to customer
          const message = {
            notification: {
              title: "Booking Confirmed! 🎉",
              body: `Your booking for ${booking.eventName} is confirmed!`,
            },
            data: {
              eventId: eventId,
              type: "booking_confirmed",
              screen: "event_details",
            },
            token: fcmToken,
          };

          await admin.messaging().send(message);
          logger.info("Booking confirmation sent to customer");
        }

        // Get provider's FCM token
        const providerDoc = await admin.firestore()
            .collection("providers")
            .doc(booking.providerId)
            .get();

        const providerToken = providerDoc.data()?.fcmToken;

        if (providerToken) {
          // Send notification to provider
          const providerMessage = {
            notification: {
              title: "New Booking Request! 📅",
              body: `New booking for ${booking.eventType} event`,
            },
            data: {
              eventId: eventId,
              type: "booking_request",
              screen: "booking_details",
            },
            token: providerToken,
          };

          await admin.messaging().send(providerMessage);
          logger.info("Booking notification sent to provider");
        }

        // Create notification documents
        await admin.firestore().collection("notifications").add({
          userId: booking.customerId,
          userType: "customer",
          title: "Booking Confirmed! 🎉",
          body: `Your booking for ${booking.eventName} is confirmed!`,
          type: "booking_confirmed",
          data: {eventId: eventId},
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        await admin.firestore().collection("notifications").add({
          userId: booking.providerId,
          userType: "provider",
          title: "New Booking Request! 📅",
          body: `New booking for ${booking.eventType} event`,
          type: "booking_request",
          data: {eventId: eventId},
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return null;
      } catch (error) {
        logger.error("Error in onBookingCreated:", error);
        return null;
      }
    }
);

// Process referral when user signs up
exports.processReferral = onDocumentCreated(
    "users/{userId}",
    async (event) => {
      const user = event.data.data();
      const userId = event.params.userId;

      logger.info("New user created:", userId);

      if (!user.referredBy) {
        return null;
      }

      try {
        const referralCode = user.referredBy;

        // Find referrer
        const referrerQuery = await admin.firestore()
            .collection("users")
            .where("referralCode", "==", referralCode)
            .limit(1)
            .get();

        if (referrerQuery.empty) {
          logger.warn("Referrer not found for code:", referralCode);
          return null;
        }

        const referrerId = referrerQuery.docs[0].id;
        const rewardAmount = 200; // ₹200 reward

        // Create referral record
        await admin.firestore().collection("referrals").add({
          referrerId: referrerId,
          referredUserId: userId,
          referralCode: referralCode,
          status: "pending", // Will be completed after first booking
          rewardAmount: rewardAmount,
          rewardType: "wallet_credit",
          rewardCredited: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        logger.info("Referral record created");

        // Send notification to referrer
        const referrerDoc = referrerQuery.docs[0];
        const fcmToken = referrerDoc.data().fcmToken;

        if (fcmToken) {
          await admin.messaging().send({
            notification: {
              title: "New Referral! 🎁",
              body: `Someone signed up using your code! Complete booking to earn ₹${rewardAmount}`,
            },
            token: fcmToken,
          });
        }

        return null;
      } catch (error) {
        logger.error("Error in processReferral:", error);
        return null;
      }
    }
);

// Create Razorpay order
exports.createRazorpayOrder = onRequest(async (request, response) => {
  // Enable CORS
  response.set("Access-Control-Allow-Origin", "*");

  if (request.method === "OPTIONS") {
    response.set("Access-Control-Allow-Methods", "POST");
    response.set("Access-Control-Allow-Headers", "Content-Type");
    response.status(204).send("");
    return;
  }

  try {
    const {amount, bookingId, userId} = request.body;

    if (!amount || !bookingId || !userId) {
      response.status(400).send({error: "Missing required parameters"});
      return;
    }

    // TODO: Replace with actual Razorpay credentials
    // Set these using: firebase functions:config:set razorpay.key_id="YOUR_KEY"
    const Razorpay = require("razorpay");
    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID || "YOUR_KEY_ID",
      key_secret: process.env.RAZORPAY_KEY_SECRET || "YOUR_KEY_SECRET",
    });

    const order = await razorpay.orders.create({
      amount: amount * 100, // amount in paise
      currency: "INR",
      receipt: bookingId,
      notes: {
        userId: userId,
        bookingId: bookingId,
      },
    });

    logger.info("Razorpay order created:", order.id);

    response.status(200).send({
      success: true,
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
    });
  } catch (error) {
    logger.error("Error creating Razorpay order:", error);
    response.status(500).send({
      error: "Failed to create order",
      message: error.message,
    });
  }
});

// Verify Razorpay payment
exports.verifyRazorpayPayment = onRequest(async (request, response) => {
  // Enable CORS
  response.set("Access-Control-Allow-Origin", "*");

  if (request.method === "OPTIONS") {
    response.set("Access-Control-Allow-Methods", "POST");
    response.set("Access-Control-Allow-Headers", "Content-Type");
    response.status(204).send("");
    return;
  }

  try {
    const {orderId, paymentId, signature, bookingId} = request.body;

    if (!orderId || !paymentId || !signature || !bookingId) {
      response.status(400).send({error: "Missing required parameters"});
      return;
    }

    const crypto = require("crypto");

    const expectedSignature = crypto
        .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET || "YOUR_KEY_SECRET")
        .update(`${orderId}|${paymentId}`)
        .digest("hex");

    if (expectedSignature === signature) {
      // Update booking with payment details
      await admin.firestore()
          .collection("events")
          .doc(bookingId)
          .update({
            payments: admin.firestore.FieldValue.arrayUnion({
              paymentId: paymentId,
              orderId: orderId,
              amount: 0, // Will be updated by the app
              method: "razorpay",
              transactionId: orderId,
              status: "success",
              paidAt: admin.firestore.FieldValue.serverTimestamp(),
            }),
            paymentStatus: "advance_paid",
            status: "confirmed",
            "eventStatus.bookingConfirmed": admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

      logger.info("Payment verified and booking updated");

      response.status(200).send({
        success: true,
        verified: true,
        message: "Payment verified successfully",
      });
    } else {
      logger.warn("Invalid payment signature");
      response.status(400).send({
        success: false,
        verified: false,
        error: "Invalid signature",
      });
    }
  } catch (error) {
    logger.error("Error verifying payment:", error);
    response.status(500).send({
      error: "Failed to verify payment",
      message: error.message,
    });
  }
});

// Create Stripe PaymentIntent (callable — Flutter SDK resolves correct URL/region)
exports.createStripePaymentIntent = onCall(
    {
      // Must match Flutter `FirebaseFunctions.instanceFor(region: ...)` (default us-central1).
      region: "us-central1",
      secrets: [stripeSecretKey],
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in required");
      }
      const uid = request.auth.uid;

      const stripe = stripeClient();
      if (!stripe) {
        logger.error("Stripe is not configured. STRIPE_SECRET_KEY is missing.");
        throw new HttpsError(
            "failed-precondition",
            "Stripe is not configured on the server",
        );
      }

      const {bookingId} = request.data || {};
      if (!bookingId) {
        throw new HttpsError("invalid-argument", "Missing bookingId");
      }

      try {
        const bookingRef = admin.firestore()
            .collection("bookings")
            .doc(String(bookingId));
        const bookingSnap = await bookingRef.get();
        if (!bookingSnap.exists) {
          throw new HttpsError("not-found", "Booking not found");
        }
        const booking = bookingSnap.data() || {};
        if (String(booking.customerId || "") !== uid) {
          throw new HttpsError(
              "permission-denied",
              "Booking does not belong to caller",
          );
        }

        const payment = booking.payment || {};
        const advanceAmount = Number(payment.advanceAmount || 0);
        const currency = String(payment.currency || "inr").toLowerCase();
        const allowedCurrencies = new Set(["inr", "gbp"]);
        if (!allowedCurrencies.has(currency)) {
          throw new HttpsError(
              "failed-precondition",
              "Unsupported payment currency",
          );
        }
        const amountInSmallestUnit = Math.round(advanceAmount * 100);
        if (!Number.isFinite(amountInSmallestUnit) || amountInSmallestUnit <= 0) {
          throw new HttpsError("failed-precondition", "Invalid booking amount");
        }
        if (currency === "gbp" && amountInSmallestUnit < 30) {
          throw new HttpsError(
              "failed-precondition",
              "GBP amount must be at least £0.30",
          );
        }
        const idempotencyKey = `booking_${String(bookingId)}_${currency}_advance_${amountInSmallestUnit}`;

        // Always create a fresh PaymentIntent for each pay attempt.
        // Reusing stale intents can skip payment sheet or fail immediately.
        const paymentIntent = await stripe.paymentIntents.create({
          amount: amountInSmallestUnit,
          currency,
          automatic_payment_methods: {enabled: true},
          metadata: {
            bookingId: String(bookingId),
            userId: String(uid),
          },
        }, {idempotencyKey});

        await bookingRef.update({
          "payment.stripePaymentIntentId": paymentIntent.id,
          "payment.paymentStatus": "pending",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          success: true,
          clientSecret: paymentIntent.client_secret,
          paymentIntentId: paymentIntent.id,
        };
      } catch (error) {
        if (error instanceof HttpsError) {
          throw error;
        }
        logger.error("Error creating Stripe PaymentIntent:", error);
        throw new HttpsError(
            "internal",
            error.message || "Failed to create payment intent",
        );
      }
    },
);

// Stripe webhook for authoritative payment status updates
exports.stripeWebhook = onRequest(
    {
      secrets: [stripeSecretKey, stripeWebhookSecret],
    },
    async (request, response) => {
  if (request.method !== "POST") {
    response.status(405).send("Method not allowed");
    return;
  }

  const stripe = stripeClient();
  const webhookSecret = resolveWebhookSecret();
  if (!stripe || !webhookSecret) {
    logger.error("Stripe webhook not configured");
    response.status(500).send("Stripe webhook not configured");
    return;
  }

  const signature = request.headers["stripe-signature"];
  if (!signature) {
    response.status(400).send("Missing stripe-signature header");
    return;
  }

  let event;
  try {
    event = stripe.webhooks.constructEvent(
        request.rawBody,
        signature,
        webhookSecret
    );
  } catch (err) {
    logger.error("Stripe webhook signature verification failed:", err.message);
    response.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  try {
    const eventRef = admin.firestore()
        .collection("stripe_webhook_events")
        .doc(String(event.id));
    const alreadyProcessed = await admin.firestore().runTransaction(
        async (tx) => {
          const processedSnap = await tx.get(eventRef);
          if (processedSnap.exists) {
            return true;
          }
          tx.set(eventRef, {
            type: event.type,
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return false;
        },
    );
    if (alreadyProcessed) {
      response.status(200).send({received: true, duplicate: true});
      return;
    }

    if (event.type === "payment_intent.succeeded") {
      const paymentIntent = event.data.object;
      const bookingId = paymentIntent.metadata?.bookingId;
      if (bookingId) {
        await admin.firestore().collection("bookings").doc(String(bookingId)).update({
          status: "confirmed",
          "payment.paymentStatus": "fully_paid",
          "eventStatus.bookingConfirmed": admin.firestore.FieldValue.serverTimestamp(),
          "payment.transactions": admin.firestore.FieldValue.arrayUnion({
            paymentId: paymentIntent.id,
            amount: (paymentIntent.amount_received || paymentIntent.amount || 0) / 100,
            method: "stripe",
            transactionId: paymentIntent.id,
            status: "success",
            paidAt: admin.firestore.FieldValue.serverTimestamp(),
          }),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    if (event.type === "payment_intent.payment_failed" ||
        event.type === "payment_intent.canceled") {
      const paymentIntent = event.data.object;
      const bookingId = paymentIntent.metadata?.bookingId;
      if (bookingId) {
        const failureMessage = paymentIntent.last_payment_error?.message || "Payment failed";
        await admin.firestore().collection("bookings").doc(String(bookingId)).update({
          "payment.paymentStatus": "failed",
          "payment.failureReason": failureMessage,
          "payment.transactions": admin.firestore.FieldValue.arrayUnion({
            paymentId: paymentIntent.id,
            amount: (paymentIntent.amount || 0) / 100,
            method: "stripe",
            transactionId: paymentIntent.id,
            status: "failed",
            paidAt: admin.firestore.FieldValue.serverTimestamp(),
          }),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    response.status(200).send({received: true});
  } catch (error) {
    logger.error("Error handling Stripe webhook event:", error);
    response.status(500).send("Webhook handler failed");
  }
});

// Send booking reminders (scheduled every hour)
exports.sendBookingReminders = onSchedule(
    "every 1 hours",
    async (event) => {
      logger.info("Running booking reminder check");

      try {
        const now = admin.firestore.Timestamp.now();
        const oneHourLater = admin.firestore.Timestamp.fromMillis(
            now.toMillis() + 60 * 60 * 1000
        );
        const oneDayLater = admin.firestore.Timestamp.fromMillis(
            now.toMillis() + 24 * 60 * 60 * 1000
        );

        // Get bookings in next hour
        const upcomingBookings = await admin.firestore()
            .collection("events")
            .where("eventDate", ">=", now)
            .where("eventDate", "<=", oneHourLater)
            .where("status", "==", "confirmed")
            .get();

        // Get bookings in next day
        const tomorrowBookings = await admin.firestore()
            .collection("events")
            .where("eventDate", ">=", oneHourLater)
            .where("eventDate", "<=", oneDayLater)
            .where("status", "==", "confirmed")
            .get();

        const promises = [];

        // Send reminders for bookings in next hour
        upcomingBookings.forEach((doc) => {
          const booking = doc.data();

          promises.push(
              admin.firestore()
                  .collection("users")
                  .doc(booking.customerId)
                  .get()
                  .then((userDoc) => {
                    const fcmToken = userDoc.data()?.fcmToken;
                    if (fcmToken) {
                      return admin.messaging().send({
                        notification: {
                          title: "Booking Reminder ⏰",
                          body: `Your ${booking.eventType} event is in 1 hour!`,
                        },
                        data: {
                          eventId: doc.id,
                          type: "booking_reminder",
                        },
                        token: fcmToken,
                      });
                    }
                  })
          );
        });

        // Send reminders for bookings tomorrow
        tomorrowBookings.forEach((doc) => {
          const booking = doc.data();

          promises.push(
              admin.firestore()
                  .collection("users")
                  .doc(booking.customerId)
                  .get()
                  .then((userDoc) => {
                    const fcmToken = userDoc.data()?.fcmToken;
                    if (fcmToken) {
                      return admin.messaging().send({
                        notification: {
                          title: "Upcoming Event Tomorrow 📅",
                          body: `Your ${booking.eventType} event is tomorrow!`,
                        },
                        data: {
                          eventId: doc.id,
                          type: "booking_reminder",
                        },
                        token: fcmToken,
                      });
                    }
                  })
          );
        });

        await Promise.all(promises);
        logger.info(`Sent ${promises.length} reminder notifications`);

        return null;
      } catch (error) {
        logger.error("Error sending reminders:", error);
        return null;
      }
    }
);

// Send notification when reel is delivered
exports.onReelDelivered = onDocumentCreated(
    "reels/{reelId}",
    async (event) => {
      const reel = event.data.data();
      const reelId = event.params.reelId;

      logger.info("New reel delivered:", reelId);

      try {
        // Get customer's FCM token
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(reel.customerId)
            .get();

        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          const message = {
            notification: {
              title: "Your reel is ready! 🎉",
              body: `${reel.title} is ready to view and share!`,
            },
            data: {
              reelId: reelId,
              eventId: reel.eventId,
              type: "reel_delivered",
              screen: "reel_player",
            },
            token: fcmToken,
          };

          await admin.messaging().send(message);
          logger.info("Reel delivery notification sent");

          // Update event with first reel delivered timestamp
          const eventDoc = await admin.firestore()
              .collection("events")
              .doc(reel.eventId)
              .get();

          if (eventDoc.exists && !eventDoc.data().eventStatus?.firstReelDelivered) {
            await admin.firestore()
                .collection("events")
                .doc(reel.eventId)
                .update({
                  "eventStatus.firstReelDelivered": admin.firestore.FieldValue.serverTimestamp(),
                });
          }
        }

        return null;
      } catch (error) {
        logger.error("Error in onReelDelivered:", error);
        return null;
      }
    }
);

