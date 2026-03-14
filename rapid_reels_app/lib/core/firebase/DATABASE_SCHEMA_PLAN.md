# Rapid Reels - Firebase Database Schema Plan

## Overview

This document provides a comprehensive database schema plan for the Rapid Reels application. The schema is designed to support all features including user management, bookings, reels, reviews, referrals, wallet, notifications, offers, live event tracking, and admin functionality.

## Database Architecture

### Firestore Collections Structure

```
firestore/
├── users/                          # User accounts (Main collection)
│   └── {userId}/
│       ├── wallet/                 # Wallet balance (subcollection)
│       │   └── balance/            # Single document with balance info
│       └── offer_usage/            # Offer usage tracking (subcollection)
│           └── {offerId}/          # Usage per offer
│
├── providers/                      # Service providers (Main collection)
│   └── {providerId}/               # Same as userId
│
├── bookings/                       # Event bookings (Main collection)
│   └── {bookingId}/
│
├── reels/                          # Video reels (Main collection)
│   └── {reelId}/
│
├── reviews/                        # Reviews and ratings (Main collection)
│   └── {reviewId}/
│
├── referrals/                      # Referral tracking (Main collection)
│   └── {referralId}/
│
├── wallet_transactions/            # Wallet transactions (Main collection)
│   └── {transactionId}/
│
├── notifications/                  # Push notifications (Main collection)
│   └── {notificationId}/
│
├── offers/                         # Offers and coupons (Main collection)
│   └── {offerId}/
│
├── live_events/                    # Live event tracking (Main collection)
│   └── {bookingId}/                # Same as booking ID
│
├── admin_analytics/                # Admin analytics (Main collection)
│   └── {date}/                     # YYYY-MM-DD format
│
└── support_tickets/                # Support tickets (Main collection)
    └── {ticketId}/
```

## Collection Details

### 1. Users Collection (`users`)

**Purpose**: Store user account information

**Document ID**: `userId` (Firebase Auth UID)

**Model Class**: `FirebaseUserModel`

**Key Fields**:
- `userId`: String (document ID)
- `phoneNumber`: String?
- `email`: String?
- `fullName`: String
- `profileImage`: String?
- `userType`: String ('customer', 'provider', 'admin')
- `currentLocation`: LocationData?
- `savedAddresses`: List<SavedAddress>?
- `preferences`: PreferencesData?
- `referralCode`: String?
- `referredBy`: String? (userId of referrer)
- `walletBalance`: double
- `totalEventsBooked`: int
- `totalReelsReceived`: int
- `isActive`: bool
- `isVerified`: bool
- `createdAt`: DateTime
- `updatedAt`: DateTime
- `lastLoginAt`: DateTime?

**Subcollections**:
- `wallet/balance` - Wallet balance document (`FirebaseWalletBalanceModel`)
- `offer_usage/{offerId}` - Offer usage tracking (`FirebaseUserOfferUsageModel`)

**Indexes Required**:
- `referralCode` (ascending) - for referral code lookup
- `userType` + `isActive` (ascending, ascending) - for filtering users
- `currentLocation.city` (ascending) - for location-based queries

**Relationships**:
- One-to-one with `providers` (if user is a provider)
- One-to-many with `bookings` (as customerId)
- One-to-many with `reels` (as customerId)
- One-to-many with `reviews` (as customerId)
- One-to-many with `referrals` (as referrerId or referredId)
- One-to-many with `wallet_transactions` (as userId)
- One-to-many with `notifications` (as userId)

---

### 2. Providers Collection (`providers`)

**Purpose**: Store service provider profiles

**Document ID**: `providerId` (same as userId in users collection)

**Model Class**: `FirebaseProviderModel`

**Key Fields**:
- `providerId`: String (document ID)
- `businessName`: String
- `ownerName`: String
- `email`: String
- `phoneNumber`: String
- `profileImage`: String
- `coverImages`: List<String>
- `bio`: String
- `eventTypes`: List<String> (wedding, birthday, etc.)
- `packages`: List<PackageOffering>
- `portfolio`: List<PortfolioItem>
- `location`: ProviderLocation
- `serviceAreas`: List<String>
- `serviceRadius`: int (km)
- `teamSize`: int
- `equipment`: List<String>
- `rating`: double
- `totalReviews`: int
- `totalEventsCompleted`: int
- `totalReelsDelivered`: int
- `averageDeliveryTime`: int (minutes)
- `availability`: Map<String, DayAvailability>
- `blockedDates`: List<BlockedDate>
- `bankDetails`: BankDetails?
- `commissionRate`: double
- `isVerified`: bool
- `isActive`: bool
- `isFeatured`: bool
- `createdAt`: DateTime
- `updatedAt`: DateTime

**Indexes Required**:
- `location.city` + `isActive` + `isVerified` (ascending, ascending, ascending) - for provider search
- `rating` + `isActive` (descending, ascending) - for sorting by rating
- `eventTypes` (array-contains) - for filtering by event type

**Relationships**:
- One-to-one with `users` (same ID)
- One-to-many with `bookings` (as providerId)
- One-to-many with `reels` (as providerId)
- One-to-many with `reviews` (as providerId)
- One-to-many with `live_events` (as providerId)

---

### 3. Bookings Collection (`bookings`)

**Purpose**: Store event booking information

**Document ID**: `bookingId` (auto-generated)

**Model Class**: `FirebaseBookingModel`

**Key Fields**:
- `bookingId`: String (document ID)
- `customerId`: String (reference to users)
- `providerId`: String (reference to providers)
- `eventType`: String (wedding, birthday, etc.)
- `eventName`: String
- `eventDate`: DateTime
- `eventTime`: String
- `duration`: int (minutes)
- `guestCount`: int
- `venue`: VenueData
- `package`: PackageData
- `customizations`: CustomizationsData?
- `specialRequirements`: String?
- `keyMoments`: List<String>?
- `status`: String (pending, confirmed, ongoing, completed, cancelled)
- `eventStatus`: EventStatusTimestamps
- `payment`: PaymentData
- `contactPerson`: String
- `contactNumber`: String
- `alternateContact`: String?
- `expectedReelsCount`: int
- `deliveryTimeline`: String (instant, same_day, next_day)
- `createdAt`: DateTime
- `updatedAt`: DateTime
- `cancelledAt`: DateTime?
- `cancellationReason`: String?
- `completedAt`: DateTime?

**Indexes Required**:
- `customerId` + `status` + `eventDate` (ascending, ascending, descending) - for user bookings
- `providerId` + `status` + `eventDate` (ascending, ascending, descending) - for provider bookings
- `eventDate` + `status` (ascending, ascending) - for upcoming events
- `status` (ascending) - for filtering by status

**Relationships**:
- Many-to-one with `users` (as customerId)
- Many-to-one with `providers` (as providerId)
- One-to-many with `reels` (as bookingId)
- One-to-one with `reviews` (as bookingId)
- One-to-one with `live_events` (same ID)

---

### 4. Reels Collection (`reels`)

**Purpose**: Store video reel information

**Document ID**: `reelId` (auto-generated)

**Model Class**: `FirebaseReelModel`

**Key Fields**:
- `reelId`: String (document ID)
- `bookingId`: String (reference to bookings)
- `customerId`: String (reference to users)
- `providerId`: String (reference to providers)
- `eventType`: String
- `eventName`: String
- `title`: String
- `description`: String?
- `videoUrl`: String (Firebase Storage URL)
- `thumbnailUrl`: String (Firebase Storage URL)
- `duration`: int (seconds)
- `status`: String (processing, ready, delivered, published, archived)
- `metadata`: ReelMetadata
- `analytics`: ReelAnalytics
- `tags`: List<String>?
- `hashtags`: List<String>?
- `isPublic`: bool (for discover feed)
- `isFeatured`: bool (for trending)
- `createdAt`: DateTime
- `deliveredAt`: DateTime?
- `publishedAt`: DateTime?
- `editingDetails`: Map<String, dynamic>?

**Indexes Required**:
- `customerId` + `createdAt` (ascending, descending) - for user reels
- `bookingId` + `createdAt` (ascending, descending) - for booking reels
- `isPublic` + `status` + `analytics.views` (ascending, ascending, descending) - for discover feed
- `isFeatured` + `analytics.views` (ascending, descending) - for trending
- `eventType` + `isPublic` (ascending, ascending) - for filtering by event type

**Relationships**:
- Many-to-one with `bookings` (as bookingId)
- Many-to-one with `users` (as customerId)
- Many-to-one with `providers` (as providerId)

---

### 5. Reviews Collection (`reviews`)

**Purpose**: Store reviews and ratings

**Document ID**: `reviewId` (auto-generated)

**Model Class**: `FirebaseReviewModel`

**Key Fields**:
- `reviewId`: String (document ID)
- `bookingId`: String (reference to bookings)
- `customerId`: String (reference to users)
- `providerId`: String (reference to providers)
- `rating`: double (1.0 to 5.0)
- `title`: String?
- `comment`: String?
- `photos`: List<String>?
- `categories`: ReviewCategories
- `isVerified`: bool
- `isPublic`: bool
- `isHelpful`: bool
- `helpfulCount`: int
- `status`: String (pending, approved, rejected, hidden)
- `createdAt`: DateTime
- `updatedAt`: DateTime?
- `response`: String? (provider's response)
- `respondedAt`: DateTime?

**Indexes Required**:
- `providerId` + `status` + `createdAt` (ascending, ascending, descending) - for provider reviews
- `bookingId` (ascending) - for booking reviews
- `rating` + `status` (descending, ascending) - for rating-based queries

**Relationships**:
- One-to-one with `bookings` (as bookingId)
- Many-to-one with `users` (as customerId)
- Many-to-one with `providers` (as providerId)

---

### 6. Referrals Collection (`referrals`)

**Purpose**: Track referral program

**Document ID**: `referralId` (auto-generated)

**Model Class**: `FirebaseReferralModel`

**Key Fields**:
- `referralId`: String (document ID)
- `referrerId`: String (reference to users)
- `referredId`: String (reference to users)
- `referralCode`: String
- `status`: String (pending, completed, expired, cancelled)
- `reward`: ReferralReward
- `createdAt`: DateTime
- `completedAt`: DateTime?
- `expiredAt`: DateTime?
- `completedBookingId`: String? (booking that triggered reward)

**Indexes Required**:
- `referrerId` + `createdAt` (ascending, descending) - for referrer's referrals
- `referredId` + `status` (ascending, ascending) - for referred user's status
- `referralCode` (ascending) - for code lookup
- `status` + `createdAt` (ascending, descending) - for pending referrals

**Relationships**:
- Many-to-one with `users` (as referrerId)
- Many-to-one with `users` (as referredId)
- Optional one-to-one with `bookings` (as completedBookingId)

---

### 7. Wallet Transactions Collection (`wallet_transactions`)

**Purpose**: Track wallet transactions

**Document ID**: `transactionId` (auto-generated)

**Model Class**: `FirebaseWalletTransactionModel`

**Key Fields**:
- `transactionId`: String (document ID)
- `userId`: String (reference to users)
- `type`: String (credit, debit, refund, referral_reward, booking_payment, withdrawal)
- `amount`: double
- `currency`: String (INR)
- `status`: String (pending, completed, failed, cancelled)
- `description`: String?
- `reference`: WalletTransactionReference?
- `createdAt`: DateTime
- `completedAt`: DateTime?
- `failureReason`: String?

**Indexes Required**:
- `userId` + `createdAt` (ascending, descending) - for user transactions
- `userId` + `type` + `status` (ascending, ascending, ascending) - for filtering transactions
- `status` + `createdAt` (ascending, descending) - for pending transactions

**Relationships**:
- Many-to-one with `users` (as userId)

---

### 8. Notifications Collection (`notifications`)

**Purpose**: Store push notifications

**Document ID**: `notificationId` (auto-generated)

**Model Class**: `FirebaseNotificationModel`

**Key Fields**:
- `notificationId`: String (document ID)
- `userId`: String (reference to users)
- `type`: String (booking_update, reel_delivered, payment, referral, system, promotion)
- `title`: String
- `body`: String
- `imageUrl`: String?
- `data`: NotificationData?
- `isRead`: bool
- `isDelivered`: bool
- `priority`: String (high, normal, low)
- `actionUrl`: String? (deep link)
- `createdAt`: DateTime
- `readAt`: DateTime?
- `deliveredAt`: DateTime?

**Indexes Required**:
- `userId` + `isRead` + `createdAt` (ascending, ascending, descending) - for user notifications
- `userId` + `type` + `createdAt` (ascending, ascending, descending) - for filtering by type
- `isDelivered` + `createdAt` (ascending, descending) - for undelivered notifications

**Relationships**:
- Many-to-one with `users` (as userId)

---

### 9. Offers Collection (`offers`)

**Purpose**: Store offers and coupons

**Document ID**: `offerId` (auto-generated)

**Model Class**: `FirebaseOfferModel`

**Key Fields**:
- `offerId`: String (document ID)
- `code`: String (coupon code)
- `title`: String
- `description`: String?
- `type`: String (discount_percentage, discount_amount, cashback, referral_bonus)
- `discount`: OfferDiscount
- `validity`: OfferValidity
- `eligibility`: OfferEligibility
- `maxUses`: int
- `usedCount`: int
- `isActive`: bool
- `isPublic`: bool
- `imageUrl`: String?
- `applicableEventTypes`: List<String>?
- `applicablePackages`: List<String>?
- `createdAt`: DateTime
- `expiresAt`: DateTime?

**Indexes Required**:
- `code` (ascending) - for code lookup
- `isActive` + `isPublic` + `expiresAt` (ascending, ascending, ascending) - for active offers
- `applicableEventTypes` (array-contains) - for filtering

**Relationships**:
- One-to-many with `users/offer_usage` (subcollection)

---

### 10. Live Events Collection (`live_events`)

**Purpose**: Track live event progress

**Document ID**: `bookingId` (same as booking ID)

**Model Class**: `FirebaseLiveEventModel`

**Key Fields**:
- `bookingId`: String (document ID, same as booking)
- `providerId`: String (reference to providers)
- `customerId`: String (reference to users)
- `status`: String (not_started, active, paused, completed)
- `startedAt`: DateTime?
- `pausedAt`: DateTime?
- `completedAt`: DateTime?
- `totalDuration`: int (minutes)
- `elapsedTime`: int (minutes)
- `progress`: LiveEventProgress
- `milestones`: List<EventMilestone>
- `footageUploads`: List<FootageUpload>
- `reelDeliveries`: List<ReelDelivery>
- `currentLocation`: LiveEventLocation?

**Indexes Required**:
- `providerId` + `status` (ascending, ascending) - for provider's live events
- `customerId` + `status` (ascending, ascending) - for customer's live events
- `status` + `startedAt` (ascending, descending) - for active events

**Relationships**:
- One-to-one with `bookings` (same ID)
- Many-to-one with `providers` (as providerId)
- Many-to-one with `users` (as customerId)

---

### 11. Admin Analytics Collection (`admin_analytics`)

**Purpose**: Store daily analytics data

**Document ID**: `date` (YYYY-MM-DD format)

**Model Class**: `FirebaseAdminAnalyticsModel`

**Key Fields**:
- `date`: String (YYYY-MM-DD)
- `metrics`: AdminMetrics
- `revenue`: AdminRevenue
- `userStats`: AdminUserStats
- `providerStats`: AdminProviderStats
- `bookingStats`: AdminBookingStats
- `updatedAt`: DateTime

**Indexes Required**:
- `date` (ascending) - for date-based queries

**Relationships**:
- Aggregated data from other collections

---

### 12. Support Tickets Collection (`support_tickets`)

**Purpose**: Store customer support tickets

**Document ID**: `ticketId` (auto-generated)

**Model Class**: `FirebaseSupportTicketModel`

**Key Fields**:
- `ticketId`: String (document ID)
- `userId`: String (reference to users)
- `providerId`: String? (reference to providers)
- `type`: String (booking_issue, payment_issue, technical, general, complaint)
- `priority`: String (low, medium, high, urgent)
- `status`: String (open, in_progress, resolved, closed)
- `subject`: String
- `description`: String
- `attachments`: List<String>?
- `bookingId`: String? (related booking)
- `messages`: List<SupportMessage>
- `assignedTo`: String? (admin user ID)
- `createdAt`: DateTime
- `resolvedAt`: DateTime?
- `closedAt`: DateTime?

**Indexes Required**:
- `userId` + `createdAt` (ascending, descending) - for user tickets
- `status` + `priority` + `createdAt` (ascending, ascending, descending) - for admin ticket management
- `assignedTo` + `status` (ascending, ascending) - for assigned tickets

**Relationships**:
- Many-to-one with `users` (as userId)
- Optional many-to-one with `providers` (as providerId)
- Optional one-to-one with `bookings` (as bookingId)

---

## Data Flow Examples

### Booking Flow
1. User creates booking → `bookings/{bookingId}`
2. Provider accepts → Update `bookings/{bookingId}.status` = 'confirmed'
3. Event starts → Create/Update `live_events/{bookingId}`
4. Provider uploads footage → Update `live_events/{bookingId}.footageUploads`
5. Provider delivers reel → Create `reels/{reelId}` + Update `live_events/{bookingId}.reelDeliveries`
6. Customer receives notification → Create `notifications/{notificationId}`
7. Event completes → Update `bookings/{bookingId}.status` = 'completed'
8. Customer reviews → Create `reviews/{reviewId}`

### Referral Flow
1. User signs up with referral code → Update `users/{userId}.referredBy`
2. Create referral record → `referrals/{referralId}`
3. Referred user completes booking → Update `referrals/{referralId}.status` = 'completed'
4. Credit rewards → Create `wallet_transactions/{transactionId}` for both users

### Payment Flow
1. User makes booking payment → Create `wallet_transactions/{transactionId}` (type: booking_payment)
2. Update booking payment status → Update `bookings/{bookingId}.payment.paymentStatus`
3. On completion, credit provider → Create `wallet_transactions/{transactionId}` (type: credit)

---

## Security Rules Considerations

When implementing Firestore security rules, consider:

1. **Users**: Users can read/write their own data, read public provider data
2. **Providers**: Providers can read/write their own data, read their bookings
3. **Bookings**: Users can read their bookings, providers can read their bookings
4. **Reels**: Users can read their reels, providers can create/update reels for their bookings
5. **Reviews**: Users can create reviews for their bookings, providers can respond
6. **Wallet**: Users can only read their own transactions
7. **Notifications**: Users can only read their own notifications
8. **Admin**: Only admin users can access admin collections

---

## Indexes Summary

Create composite indexes in Firestore Console for:

1. `users`: `referralCode` (ascending)
2. `users`: `userType` + `isActive` (ascending, ascending)
3. `users`: `currentLocation.city` (ascending)
4. `providers`: `location.city` + `isActive` + `isVerified` (ascending, ascending, ascending)
5. `providers`: `rating` + `isActive` (descending, ascending)
6. `bookings`: `customerId` + `status` + `eventDate` (ascending, ascending, descending)
7. `bookings`: `providerId` + `status` + `eventDate` (ascending, ascending, descending)
8. `reels`: `customerId` + `createdAt` (ascending, descending)
9. `reels`: `isPublic` + `status` + `analytics.views` (ascending, ascending, descending)
10. `reviews`: `providerId` + `status` + `createdAt` (ascending, ascending, descending)
11. `notifications`: `userId` + `isRead` + `createdAt` (ascending, ascending, descending)
12. `wallet_transactions`: `userId` + `createdAt` (ascending, descending)
13. `live_events`: `providerId` + `status` (ascending, ascending)

---

## Best Practices

1. **Use Subcollections**: For frequently accessed data related to a parent document
2. **Batch Writes**: Use batch writes for related operations (e.g., create booking + update user stats)
3. **Transactions**: Use transactions for critical operations (e.g., wallet balance updates)
4. **Real-time Listeners**: Use streams for live data (bookings, live events, notifications)
5. **Pagination**: Always use `.limit()` and pagination for large collections
6. **Error Handling**: Implement proper error handling for all Firestore operations
7. **Offline Support**: Enable offline persistence for better UX
8. **Data Validation**: Validate data before writing to Firestore
9. **Index Management**: Monitor and optimize indexes based on query patterns
10. **Security Rules**: Implement comprehensive security rules for all collections

---

## Model Files Location

All Firebase models are located in:
```
lib/core/firebase/models/
```

- `firebase_user_model.dart`
- `firebase_provider_model.dart`
- `firebase_booking_model.dart`
- `firebase_reel_model.dart`
- `firebase_review_model.dart`
- `firebase_referral_model.dart`
- `firebase_wallet_model.dart`
- `firebase_notification_model.dart`
- `firebase_offer_model.dart`
- `firebase_live_event_model.dart`
- `firebase_admin_model.dart` (includes support tickets)

---

## Migration Notes

When migrating from mock data to Firebase:

1. Create user accounts using Firebase Auth
2. Migrate user data to `users` collection
3. Create provider profiles in `providers` collection
4. Migrate bookings to `bookings` collection
5. Upload reels to Firebase Storage and create `reels` documents
6. Migrate reviews, referrals, and wallet transactions
7. Set up Cloud Functions for automated operations (notifications, analytics, etc.)
8. Configure Firestore security rules
9. Set up required indexes
10. Test all queries and operations

---

## Support

For questions or issues with the Firebase database schema:
- Model definitions: `lib/core/firebase/models/`
- FirestoreService: `lib/core/firebase/services/firestore_service.dart`
- Documentation: `lib/core/firebase/FIREBASE_DATA_MODEL.md`
- Firebase documentation: https://firebase.google.com/docs/firestore

