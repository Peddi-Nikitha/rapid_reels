# Firebase Data Model Documentation

## Overview

This document describes the comprehensive Firebase Firestore data model for Rapid Reels application. The model is designed to support all features including user management, bookings, reels, reviews, referrals, wallet, notifications, offers, live event tracking, and admin functionality.

## Collections Structure

```
firestore/
├── users/                          # User accounts
│   └── {userId}/
│       └── wallet/                 # Wallet balance (subcollection)
│       └── offer_usage/            # Offer usage tracking (subcollection)
│
├── providers/                      # Service providers
│   └── {providerId}/
│
├── bookings/                       # Event bookings
│   └── {bookingId}/
│
├── reels/                          # Video reels
│   └── {reelId}/
│
├── reviews/                         # Reviews and ratings
│   └── {reviewId}/
│
├── referrals/                      # Referral tracking
│   └── {referralId}/
│
├── wallet_transactions/            # Wallet transactions
│   └── {transactionId}/
│
├── notifications/                  # Push notifications
│   └── {notificationId}/
│
├── offers/                         # Offers and coupons
│   └── {offerId}/
│
├── live_events/                    # Live event tracking
│   └── {bookingId}/                # Same as booking ID
│
├── admin_analytics/                # Admin analytics
│   └── {date}/                     # YYYY-MM-DD format
│
└── support_tickets/                # Support tickets
    └── {ticketId}/
```

## Data Models

### 1. Users Collection (`users`)

**Document ID**: `userId` (Firebase Auth UID)

**Model**: `FirebaseUserModel`

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
- `wallet/balance` - Wallet balance document
- `offer_usage/{offerId}` - Offer usage tracking

**Indexes Required**:
- `referralCode` (for referral code lookup)
- `userType` + `isActive` (for filtering users)
- `currentLocation.city` (for location-based queries)

---

### 2. Providers Collection (`providers`)

**Document ID**: `providerId` (same as userId in users collection)

**Model**: `FirebaseProviderModel`

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
- `location.city` + `isActive` + `isVerified` (for provider search)
- `rating` + `isActive` (for sorting by rating)
- `eventTypes` (array-contains for filtering by event type)

---

### 3. Bookings Collection (`bookings`)

**Document ID**: `bookingId` (auto-generated)

**Model**: `FirebaseBookingModel`

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
- `customerId` + `status` + `eventDate` (for user bookings)
- `providerId` + `status` + `eventDate` (for provider bookings)
- `eventDate` + `status` (for upcoming events)
- `status` (for filtering by status)

---

### 4. Reels Collection (`reels`)

**Document ID**: `reelId` (auto-generated)

**Model**: `FirebaseReelModel`

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
- `customerId` + `createdAt` (for user reels)
- `bookingId` + `createdAt` (for booking reels)
- `isPublic` + `status` + `analytics.views` (for discover feed)
- `isFeatured` + `analytics.views` (for trending)
- `eventType` + `isPublic` (for filtering by event type)

---

### 5. Reviews Collection (`reviews`)

**Document ID**: `reviewId` (auto-generated)

**Model**: `FirebaseReviewModel`

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
- `providerId` + `status` + `createdAt` (for provider reviews)
- `bookingId` (for booking reviews)
- `rating` + `status` (for rating-based queries)

---

### 6. Referrals Collection (`referrals`)

**Document ID**: `referralId` (auto-generated)

**Model**: `FirebaseReferralModel`

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
- `referrerId` + `createdAt` (for referrer's referrals)
- `referredId` + `status` (for referred user's status)
- `referralCode` (for code lookup)
- `status` + `createdAt` (for pending referrals)

---

### 7. Wallet Transactions Collection (`wallet_transactions`)

**Document ID**: `transactionId` (auto-generated)

**Model**: `FirebaseWalletTransactionModel`

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
- `userId` + `createdAt` (for user transactions)
- `userId` + `type` + `status` (for filtering transactions)
- `status` + `createdAt` (for pending transactions)

---

### 8. Notifications Collection (`notifications`)

**Document ID**: `notificationId` (auto-generated)

**Model**: `FirebaseNotificationModel`

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
- `userId` + `isRead` + `createdAt` (for user notifications)
- `userId` + `type` + `createdAt` (for filtering by type)
- `isDelivered` + `createdAt` (for undelivered notifications)

---

### 9. Offers Collection (`offers`)

**Document ID**: `offerId` (auto-generated)

**Model**: `FirebaseOfferModel`

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
- `code` (for code lookup)
- `isActive` + `isPublic` + `expiresAt` (for active offers)
- `applicableEventTypes` (array-contains for filtering)

---

### 10. Live Events Collection (`live_events`)

**Document ID**: `bookingId` (same as booking ID)

**Model**: `FirebaseLiveEventModel`

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
- `metadata`: Map<String, dynamic>?

**Indexes Required**:
- `providerId` + `status` (for provider's live events)
- `customerId` + `status` (for customer's live events)
- `status` + `startedAt` (for active events)

---

### 11. Admin Analytics Collection (`admin_analytics`)

**Document ID**: `date` (YYYY-MM-DD format)

**Model**: `FirebaseAdminAnalyticsModel`

**Key Fields**:
- `date`: String (YYYY-MM-DD)
- `metrics`: AdminMetrics
- `revenue`: AdminRevenue
- `userStats`: AdminUserStats
- `providerStats`: AdminProviderStats
- `bookingStats`: AdminBookingStats
- `updatedAt`: DateTime

**Indexes Required**:
- `date` (for date-based queries)

---

### 12. Support Tickets Collection (`support_tickets`)

**Document ID**: `ticketId` (auto-generated)

**Model**: `FirebaseSupportTicketModel`

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
- `userId` + `createdAt` (for user tickets)
- `status` + `priority` + `createdAt` (for admin ticket management)
- `assignedTo` + `status` (for assigned tickets)

---

## Relationships

### Primary Relationships

1. **User ↔ Provider**: One user can be one provider (same userId)
2. **User ↔ Booking**: One user can have many bookings (customerId)
3. **Provider ↔ Booking**: One provider can have many bookings (providerId)
4. **Booking ↔ Reel**: One booking can have many reels (bookingId)
5. **Booking ↔ Review**: One booking can have one review (bookingId)
6. **User ↔ Referral**: One user can refer many users (referrerId)
7. **User ↔ Wallet Transaction**: One user can have many transactions (userId)
8. **User ↔ Notification**: One user can have many notifications (userId)
9. **Booking ↔ Live Event**: One booking has one live event (same ID)

### Data Flow Examples

**Booking Flow**:
1. User creates booking → `bookings/{bookingId}`
2. Provider accepts → Update `bookings/{bookingId}.status`
3. Event starts → Create/Update `live_events/{bookingId}`
4. Provider uploads footage → Update `live_events/{bookingId}.footageUploads`
5. Provider delivers reel → Create `reels/{reelId}` + Update `live_events/{bookingId}.reelDeliveries`
6. Customer receives notification → Create `notifications/{notificationId}`
7. Event completes → Update `bookings/{bookingId}.status` = 'completed'
8. Customer reviews → Create `reviews/{reviewId}`

**Referral Flow**:
1. User signs up with referral code → Update `users/{userId}.referredBy`
2. Create referral record → `referrals/{referralId}`
3. Referred user completes booking → Update `referrals/{referralId}.status` = 'completed'
4. Credit rewards → Create `wallet_transactions/{transactionId}` for both users

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

## Indexes Required

Create composite indexes in Firestore Console for:

1. `users`: `referralCode` (ascending)
2. `providers`: `location.city` + `isActive` + `isVerified` (ascending)
3. `bookings`: `customerId` + `status` + `eventDate` (ascending, descending)
4. `bookings`: `providerId` + `status` + `eventDate` (ascending, descending)
5. `reels`: `customerId` + `createdAt` (ascending, descending)
6. `reels`: `isPublic` + `status` + `analytics.views` (ascending, ascending, descending)
7. `reviews`: `providerId` + `status` + `createdAt` (ascending, ascending, descending)
8. `notifications`: `userId` + `isRead` + `createdAt` (ascending, ascending, descending)
9. `wallet_transactions`: `userId` + `createdAt` (ascending, descending)
10. `live_events`: `providerId` + `status` (ascending, ascending)

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

---

## Support

For questions or issues with the Firebase data model, refer to:
- FirestoreService implementation: `lib/core/firebase/services/firestore_service.dart`
- Model definitions: `lib/core/firebase/models/`
- Firebase documentation: https://firebase.google.com/docs/firestore

