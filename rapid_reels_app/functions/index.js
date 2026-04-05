const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {defineSecret} = require("firebase-functions/params");
require("dotenv").config();
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const Stripe = require("stripe");
const invoiceEmail = require("./invoice_email");

admin.initializeApp();

/**
 * Rebuild Firestore Timestamp values from Flutter callable JSON
 * ({ seconds, nanoseconds }).
 * @param {*} value
 * @return {*}
 */
function reviveFirestoreTimestamps(value) {
  if (value === null || value === undefined) return value;
  if (typeof value === "object" && !Array.isArray(value) &&
      typeof value.seconds === "number") {
    const ns = typeof value.nanoseconds === "number" ? value.nanoseconds : 0;
    return new admin.firestore.Timestamp(value.seconds, ns);
  }
  if (Array.isArray(value)) {
    return value.map(reviveFirestoreTimestamps);
  }
  if (typeof value === "object") {
    const out = {};
    for (const [k, v] of Object.entries(value)) {
      out[k] = reviveFirestoreTimestamps(v);
    }
    return out;
  }
  return value;
}

const BLOCKING_BOOKING_STATUSES = ["pending", "confirmed", "ongoing"];

/** One active booking per provider per calendar day (eventDateKey). */
exports.createBookingIfAvailable = onCall(async (request) => {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const raw = request.data && request.data.booking;
  if (!raw || typeof raw !== "object") {
    throw new HttpsError("invalid-argument", "booking payload required.");
  }
  const booking = reviveFirestoreTimestamps(raw);
  if (booking.customerId !== request.auth.uid) {
    throw new HttpsError("permission-denied", "customerId must match the signed-in user.");
  }
  const providerId = booking.providerId;
  const eventDateKey = booking.eventDateKey;
  if (!providerId || !eventDateKey) {
    throw new HttpsError("invalid-argument", "providerId and eventDateKey are required.");
  }

  const db = admin.firestore();
  const bookingRef = db.collection("bookings").doc();
  const newBookingId = bookingRef.id;
  const lockRef = db.collection("providers").doc(String(providerId))
      .collection("schedule").doc(String(eventDateKey));

  let slotUnavailable = false;
  try {
    await db.runTransaction(async (t) => {
      const q = db.collection("bookings")
          .where("providerId", "==", providerId)
          .where("eventDateKey", "==", eventDateKey)
          .where("status", "in", BLOCKING_BOOKING_STATUSES);
      const conflictSnap = await t.get(q);
      if (!conflictSnap.empty) {
        slotUnavailable = true;
        return;
      }
      const lockSnap = await t.get(lockRef);
      if (lockSnap.exists) {
        slotUnavailable = true;
        return;
      }

      const payload = Object.assign({}, booking);
      delete payload.bookingId;
      payload.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      payload.createdAt = admin.firestore.FieldValue.serverTimestamp();

      t.set(lockRef, {
        bookingId: newBookingId,
        customerId: request.auth.uid,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      t.set(bookingRef, payload);
    });
  } catch (e) {
    logger.error("createBookingIfAvailable failed", e);
    throw new HttpsError("internal", "Could not create booking.");
  }

  if (slotUnavailable) {
    throw new HttpsError("already-exists", "This date is no longer available.");
  }

  return {bookingId: newBookingId};
});

/** Free schedule lock when a booking leaves a blocking status. */
exports.onBookingReleaseScheduleSlot = onDocumentUpdated("bookings/{bookingId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!before || !after) return null;
  const blocking = new Set(BLOCKING_BOOKING_STATUSES);
  const wasBlocking = blocking.has(before.status);
  const nowBlocking = blocking.has(after.status);
  if (!(wasBlocking && !nowBlocking)) return null;
  const pid = after.providerId;
  const key = after.eventDateKey;
  const bid = event.params.bookingId;
  if (!pid || !key) return null;
  const ref = admin.firestore().collection("providers").doc(String(pid))
      .collection("schedule").doc(String(key));
  const snap = await ref.get();
  if (snap.exists && snap.data().bookingId === bid) {
    await ref.delete();
  }
  return null;
});

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
const smtpUser = defineSecret("SMTP_USER");
const smtpPass = defineSecret("SMTP_PASS");
const STRIPE_TEST_CHARGE_GBP = 2.0;
const STRIPE_TEST_CHARGE_FLAG = String(
    process.env.STRIPE_TEST_CHARGE_ENABLED || "",
).toLowerCase();

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

function paymentStatusFromEventType(eventType) {
  switch (eventType) {
    case "payment_intent.succeeded":
      return "succeeded";
    case "payment_intent.payment_failed":
      return "failed";
    case "payment_intent.canceled":
      return "canceled";
    case "payment_intent.processing":
      return "processing";
    default:
      return "processing";
  }
}

function bookingPaymentStatusFromStripeStatus(status) {
  switch (status) {
    case "succeeded":
      return "fully_paid";
    case "failed":
      return "failed";
    case "canceled":
      return "failed";
    case "processing":
      return "pending";
    default:
      return "pending";
  }
}

async function createPaymentNotification({
  userId,
  bookingId,
  paymentIntentId,
  amountMajor,
  status,
  role,
}) {
  if (!userId) return;
  const success = status === "succeeded";
  const title = success ? "Payment received" : "Payment update";
  const body = success ?
    `Payment completed for booking ${bookingId}.` :
    `Payment ${status} for booking ${bookingId}.`;

  await admin.firestore().collection("notifications").add({
    userId: String(userId),
    type: success ? "payment_success" : "payment_failed",
    title,
    body,
    data: {
      bookingId: String(bookingId),
      paymentId: String(paymentIntentId),
      customData: {
        role: String(role),
        amount: amountMajor,
        status,
      },
    },
    isRead: false,
    isDelivered: false,
    priority: success ? "normal" : "high",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    metadata: {
      source: "stripe_webhook",
      role,
      status,
    },
  });
}

async function createAdminPaymentNotifications({
  bookingId,
  paymentIntentId,
  amountMajor,
  status,
}) {
  const adminUsersSnap = await admin.firestore()
      .collection("users")
      .where("userType", "in", ["admin", "superadmin"])
      .get();
  if (adminUsersSnap.empty) return;

  await Promise.all(adminUsersSnap.docs.map((doc) => createPaymentNotification({
    userId: doc.id,
    bookingId,
    paymentIntentId,
    amountMajor,
    status,
    role: "admin",
  })));
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
        const rewardAmount = 2; // £2 reward

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
              body: `Someone signed up using your code! Complete booking to earn £${rewardAmount}`,
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

// Legacy Razorpay endpoint disabled for UK-only Stripe rollout.
exports.createRazorpayOrder = onRequest(async (request, response) => {
  response.status(410).send({
    error: "Deprecated",
    message: "Razorpay is disabled. Use Stripe GBP checkout.",
  });
});

// Legacy Razorpay endpoint disabled for UK-only Stripe rollout.
exports.verifyRazorpayPayment = onRequest(async (request, response) => {
  response.status(410).send({
    error: "Deprecated",
    message: "Razorpay verification is disabled. Use Stripe GBP webhook flow.",
  });
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
        const currency = String(payment.currency || "gbp").toLowerCase();
        if (currency !== "gbp") {
          throw new HttpsError(
              "failed-precondition",
              "Only GBP payments are supported",
          );
        }
        // Test mode default: with `sk_test` keys we charge £2 unless explicitly disabled.
        const stripeKey = resolveStripeApiKey();
        const usingLiveStripeKey = String(stripeKey || "").startsWith("sk_live");
        const forceTestCharge = STRIPE_TEST_CHARGE_FLAG === "true";
        const disableTestCharge = STRIPE_TEST_CHARGE_FLAG === "false";
        const effectiveTestChargeEnabled = forceTestCharge ||
          (!usingLiveStripeKey && !disableTestCharge);

        const stripeChargeAmount = effectiveTestChargeEnabled ?
          STRIPE_TEST_CHARGE_GBP :
          advanceAmount;
        const amountInSmallestUnit = Math.round(stripeChargeAmount * 100);
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
            customerUserId: String(uid),
            providerUserId: String(booking.providerId || ""),
            isTestChargeOverride: effectiveTestChargeEnabled ? "true" : "false",
            originalAdvanceAmount: String(advanceAmount.toFixed(2)),
            overrideChargeAmount: String(stripeChargeAmount.toFixed(2)),
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
      secrets: [
        stripeSecretKey,
        stripeWebhookSecret,
        smtpUser,
        smtpPass,
      ],
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

    if (event.type === "payment_intent.succeeded" ||
        event.type === "payment_intent.payment_failed" ||
        event.type === "payment_intent.canceled" ||
        event.type === "payment_intent.processing") {
      const paymentIntent = event.data.object;
      const bookingId = String(paymentIntent.metadata?.bookingId || "");
      const transactionId = String(paymentIntent.id || "");
      if (!bookingId || !transactionId) {
        logger.warn("Skipping payment webhook due to missing bookingId/transactionId", {
          eventType: event.type,
          eventId: event.id,
        });
      } else {
        const bookingRef = admin.firestore().collection("bookings").doc(bookingId);
        const bookingSnap = await bookingRef.get();
        if (!bookingSnap.exists) {
          logger.warn("Booking not found for payment event", {bookingId, transactionId});
        } else {
          const booking = bookingSnap.data() || {};
          const status = paymentStatusFromEventType(event.type);
          const amountMajor = (paymentIntent.amount_received || paymentIntent.amount || 0) / 100;
          const failureCode = paymentIntent.last_payment_error?.code || null;
          const failureMessage = paymentIntent.last_payment_error?.message ||
            (status === "failed" ? "Payment failed" : null);
          const paymentMethodType = paymentIntent.payment_method_types &&
            paymentIntent.payment_method_types.length > 0 ?
            String(paymentIntent.payment_method_types[0]) :
            "stripe";

          const canonicalDocRef = admin.firestore()
              .collection("payment_transactions")
              .doc(transactionId);

          await canonicalDocRef.set({
            transactionId,
            bookingId,
            customerUserId: String(
                paymentIntent.metadata?.customerUserId ||
                booking.customerId ||
                ""
            ),
            providerUserId: String(
                paymentIntent.metadata?.providerUserId ||
                booking.providerId ||
                ""
            ),
            stripeEventId: String(event.id),
            amount: amountMajor,
            currency: String(paymentIntent.currency || "gbp").toLowerCase(),
            status,
            failureCode,
            failureMessage,
            paymentMethodType,
            isLiveMode: paymentIntent.livemode === true,
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            metadata: {
              stripePaymentIntentStatus: String(paymentIntent.status || ""),
            },
          }, {merge: true});

          const bookingUpdate = {
            "payment.paymentStatus": bookingPaymentStatusFromStripeStatus(status),
            "payment.stripePaymentIntentId": transactionId,
            "payment.lastTransactionRef": transactionId,
            "payment.transactions": admin.firestore.FieldValue.arrayUnion({
              paymentId: transactionId,
              amount: amountMajor,
              method: "stripe",
              transactionId: transactionId,
              status: status === "succeeded" ? "success" : status,
              paidAt: admin.firestore.FieldValue.serverTimestamp(),
            }),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };

          if (status === "succeeded") {
            bookingUpdate.status = "confirmed";
            bookingUpdate["eventStatus.bookingConfirmed"] = admin.firestore.FieldValue.serverTimestamp();
          } else if (failureMessage) {
            bookingUpdate["payment.failureReason"] = failureMessage;
          }
          await bookingRef.update(bookingUpdate);

          if (status === "succeeded") {
            try {
              let smtpUserVal = process.env.SMTP_USER || "";
              let smtpPassVal = process.env.SMTP_PASS || "";
              if (!smtpUserVal || !smtpPassVal) {
                try {
                  if (!smtpUserVal) smtpUserVal = smtpUser.value();
                  if (!smtpPassVal) smtpPassVal = smtpPass.value();
                } catch (secErr) {
                  logger.info("SMTP secrets unavailable (emulator?)", {
                    message: String(secErr && secErr.message ? secErr.message : secErr),
                  });
                }
              }
              const smtpFrom = process.env.SMTP_FROM || smtpUserVal || "";
              await invoiceEmail.maybeSendInvoiceEmail({
                db: admin.firestore(),
                bookingRef,
                bookingId,
                bookingSnapshotData: booking,
                paymentIntent,
                logger,
                smtp: {
                  user: smtpUserVal,
                  pass: smtpPassVal,
                  from: smtpFrom,
                  host: process.env.SMTP_HOST || "smtp.gmail.com",
                  port: parseInt(process.env.SMTP_PORT || "465", 10),
                },
              });
            } catch (invErr) {
              logger.error("Invoice email error (non-fatal)", {
                bookingId,
                message: invErr && invErr.message,
              });
              try {
                await bookingRef.update({
                  "metadata.invoiceEmailError": String(invErr.message || invErr),
                  "metadata.invoiceEmailErrorAt":
                      admin.firestore.FieldValue.serverTimestamp(),
                });
              } catch (metaErr) {
                logger.warn("Could not persist invoiceEmailError", metaErr);
              }
            }
          }

          await createPaymentNotification({
            userId: String(booking.providerId || paymentIntent.metadata?.providerUserId || ""),
            bookingId,
            paymentIntentId: transactionId,
            amountMajor,
            status,
            role: "provider",
          });
          await createAdminPaymentNotifications({
            bookingId,
            paymentIntentId: transactionId,
            amountMajor,
            status,
          });
        }
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

