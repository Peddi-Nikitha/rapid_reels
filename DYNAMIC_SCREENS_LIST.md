# Dynamic Screens List - Rapid Reels App

## Overview
This document lists all screens in the Rapid Reels app that load data dynamically from Firebase or other data sources.

---

## ✅ Fully Dynamic Screens (Firebase Integration)

### 1. **Dynamic Profile Screen**
- **Location**: `rapid_reels_app/lib/features/profile/presentation/screens/dynamic_profile_screen.dart`
- **Data Source**: Firebase Firestore
- **Providers Used**:
  - `userProfileProvider` - StreamProvider (real-time user data)
  - `recentBookingsProvider` - FutureProvider (recent bookings)
  - `recentReelsProvider` - FutureProvider (recent reels)
  - `walletBalanceProvider` - Provider (wallet balance)
- **Features**:
  - Real-time user profile updates
  - Profile statistics (Events, Reels, Wallet)
  - Recent bookings preview
  - Recent reels preview
  - Pull-to-refresh
  - Loading/Error states

---

### 2. **Dynamic My Events Screen**
- **Location**: `rapid_reels_app/lib/features/my_events/presentation/screens/dynamic_my_events_screen.dart`
- **Data Source**: Firebase Firestore
- **Providers Used**:
  - `myEventsProvider` - StreamProvider (real-time bookings stream)
  - `filteredEventsProvider` - Provider (filtered by status)
  - `searchEventsProvider` - Provider (search results)
  - `eventStatsProvider` - Provider (statistics)
- **Features**:
  - Real-time bookings list
  - Filter tabs (All, Upcoming, Ongoing, Completed, Cancelled)
  - Search functionality
  - Statistics bar
  - Pull-to-refresh
  - Empty states

---

### 3. **Dynamic My Reels Screen**
- **Location**: `rapid_reels_app/lib/features/reels/presentation/screens/dynamic_my_reels_screen.dart`
- **Data Source**: Firebase Firestore
- **Providers Used**:
  - `myReelsProvider` - FutureProvider (user reels)
  - `filteredReelsProvider` - Provider (filtered by status/event type)
  - `reelStatsProvider` - Provider (statistics)
- **Features**:
  - Grid/List view toggle
  - Real-time reels list
  - Status filters (All, Processing, Delivered, Published)
  - Event type filters
  - Reel analytics display
  - Pull-to-refresh

---

### 4. **Profile Screen** (Standard)
- **Location**: `rapid_reels_app/lib/features/profile/presentation/screens/profile_screen.dart`
- **Data Source**: Firebase Firestore
- **Providers Used**:
  - `userProfileProvider` - StreamProvider (real-time user data)
- **Features**:
  - Real-time user profile
  - Profile information display

---

## User-Requested Static Screens -> Firebase-Backed Dynamic

The sections below map each of your listed static UI issues to the existing Firebase collections/models in this repo, and what needs to change in the UI layer and admin workflows.

### 1) Notifications
- **Static Location**: `rapid_reels_app/lib/features/notifications/presentation/screens/notifications_screen.dart`
- **Current Problem**: Uses a hardcoded `_allNotifications` list and local “mark all read”.
- **Target UI Sections**:
  - `Notifications` AppBar (with conditional `Mark all read`)
  - Tabs: `All`, `Bookings`, `Updates`
  - Notification cards + per-card action
- **Firebase Integration (existing)**:
  - Collection: `notifications`
  - Model: `FirebaseNotificationModel`
  - Reads: `FirestoreService().streamUserNotifications(userId)`
  - Updates:
    - `FirestoreService().markNotificationAsRead(notificationId)` to set `isRead=true` and `readAt`
- **Behavior Rules**:
  - `Mark all read` iterates only unread notifications from the stream.
  - On card tap:
    - mark as read
    - deep-link/open the relevant screen based on `notification.type` (add a small type->route mapping if needed)
- **Admin Flow**:
  - Admin generally does not manage these directly; Cloud Functions (already present) create notifications for booking/reel events.

---

### 2) Homepage Banner Section (Admin Editable)
- **Static Location**: `rapid_reels_app/lib/features/home/presentation/screens/home_screen.dart`
- **Current Problem**: Carousel banner items are hardcoded inline (no Firestore backing).
- **Target UI Sections**:
  - Promotional carousel (autoplay)
  - Each item renders `image + overlay text (and optional CTA)`
- **Firebase Integration (recommended reuse)**:
  - Collection: `offers`
  - Model: `FirebaseOfferModel`
  - Existing read: `FirestoreService().getActiveOffers(eventType: ...)`
- **Admin Flow to implement**:
  - Add an “Admin Offers Management” UI that CRUDs `offers` docs:
    - `imageUrl`, `title`, `description`
    - `isActive`, `isPublic`
    - `applicableEventTypes` (optional)
  - Customer side:
    - show only offers where `isActive=true && isPublic=true`
    - optionally filter by current event type/city if your UX supports it
- **No-flow-break fallback**:
  - If no active offers exist, keep current hardcoded banner content as a fallback until the admin UI is ready.

---

### 3) Customer Review Section (Admin Editable)
- **Static Location**: `rapid_reels_app/lib/features/home/presentation/screens/home_screen.dart` (city-based review carousel)
- **Current Problem**: `_getCityReview(...)` returns hardcoded city review maps.
- **Target UI Sections**:
  - Review header (`What Our Customers Say`)
  - City selector (if present)
  - Review cards in the carousel
- **Firebase Integration**:
  - Collection: `reviews`
  - Model: `FirebaseReviewModel`
  - Reading requirement (client-side join):
    - Query approved + public reviews: `status == 'approved' && isPublic == true`
    - Join review -> provider -> provider.location.city to support city selection
- **Admin Flow to implement**:
  - Add “Admin Review Moderation” UI:
    - list reviews by status (pending/approved)
    - update `status` and `isPublic`
  - Security rules already allow admin full read/write on `/reviews/*`.
- **Card Mapping**:
  - rating: use `ReviewCategories.averageRating` (or add `rating` if your schema already has it)
  - text: use `comment` (fallback to `title`)
- **No-flow-break behavior**:
  - Preserve existing city selector behavior; only replace the backing data.

---

### 4) Profile Picture Not Working (Make Dynamic Upload)
- **Static Location**: `rapid_reels_app/lib/features/profile/presentation/screens/edit_profile_screen.dart`
- **Current Problem**: `_changeProfilePicture()` is stubbed (“Camera feature coming soon!”). Save changes does not persist a new `profileImage`.
- **Target UI Sections**:
  - Avatar camera button (open modal bottom sheet)
  - Bottom sheet: `Take Photo` / `Choose from Gallery`
  - Preview + “Save Changes”
- **Firebase Integration (existing)**:
  - Storage: use `firebase_storage` to upload the image and get a download URL
  - Firestore update:
    - collection: `users`
    - field: `profileImage`
    - update via existing profile flow: `authNotifierProvider.notifier.updateUserProfile(...)`
- **No-flow-break**:
  - Keep name/email/city update logic intact; just extend `_saveChanges()` to include `profileImage` after upload.

---

### 5) Profile -> “My Venues” Address Not Added (Make Dynamic CRUD)
- **Static Location**: `rapid_reels_app/lib/features/profile/presentation/screens/saved_venues_screen.dart`
- **Current Problem**:
  - “Add New Venue” opens a placeholder dialog
  - edit/delete actions are mostly placeholders
- **Target UI Sections**:
  - Empty state: `No Saved Venues`
  - Venue cards with menu actions
  - `Add New Venue` form
- **Firebase Integration (existing)**:
  - collection: `users`
  - field: `savedAddresses` on `FirebaseUserModel`
  - model: `SavedAddress` (in `rapid_reels_app/lib/shared/models/user_model.dart`)
- **Write Behavior**:
  - Add:
    - build a `SavedAddress` with a generated `addressId`
    - update user doc with the new full `savedAddresses` list
  - Edit:
    - replace the item by `addressId`
  - Delete:
    - remove by `addressId`
- **No-flow-break notes**:
  - Prefer full list replacement over `arrayUnion` with map equality.

---

### 6) Submit Ticket + My Tickets (Make Dynamic)
- **Static Location**:
  - Submit form: `rapid_reels_app/lib/features/profile/presentation/screens/support_screen.dart`
  - “My Tickets” list: does not currently exist as a dedicated customer screen
- **Current Problem**:
  - `_submitTicket()` only shows a snackbar; no Firestore write
- **Target UI Sections**:
  - Support screen: category dropdown + subject + message + submit
  - My Tickets screen (new):
    - ticket list/cards
    - optional status filter
    - ticket detail with message thread + message input
- **Firebase Integration (existing)**:
  - collection: `support_tickets`
  - model: `FirebaseSupportTicketModel`
  - service methods already exist:
    - `FirestoreService().createSupportTicket(ticket)`
    - `FirestoreService().getSupportTickets(status/priority/limit)` (admin-oriented; you may add a customer-scoped method)
- **Write Behavior**:
  - On submit:
    - create a ticket with:
      - `userId = currentUser.uid`
      - `status = 'open'`
      - `messages = [initial message]`
      - map category -> `type` and pick default `priority`
- **No-flow-break**:
  - Keep current Support screen layout and only replace the submit handler + add new navigation to My Tickets.

---

### 7) Like / Commit(Comment) / Share in Reels (Make Dynamic)
- **Static Locations**:
  - Reel player: `rapid_reels_app/lib/features/reels/presentation/screens/reel_player_screen.dart`
  - Discover feed (action buttons): `rapid_reels_app/lib/features/discover/presentation/screens/discover_feed_screen.dart`
  - Share UI: `rapid_reels_app/lib/features/reels/presentation/screens/reel_share_screen.dart` (already fetches reel dynamically)
- **Current Problems**:
  - Like: local toggle only (`_likedReels`), not persisted
  - Commit(Comment): placeholder (`onTap: () {}`) and fixed comment count
  - Share: navigation works, but analytics counters aren’t updated
- **Target UI Behavior**:
  - Like toggles and persists consistently
  - Commit(Comment) opens a composer; persists + updates count
  - Share updates `reel.analytics.shares`
- **Firebase Integration Challenge (rules)**:
  - Client-side writes to `/reels/{reelId}` analytics are restricted by Firestore rules (owner/admin).
- **Recommended Implementation**:
  - Use Cloud Function/callable to increment reel analytics server-side (likes/comments/shares) safely.
  - Keep UI optimistic and reconcile with the updated reel doc afterward.
- **No-flow-break**:
  - Replace the no-op handlers and placeholders without changing the overall screen structure.

---

### 8) Account Name Click Should Navigate
- **Static Location**: `rapid_reels_app/lib/features/profile/presentation/screens/profile_screen.dart`
- **Current Problem**: Display name/account area is rendered as `Text(displayName)` with no tap handler.
- **Target UI Behavior**:
  - Make the user name/account area tap to navigate to the intended destination (match your UX; typically `AppRoutes.editProfile`).
- **No-flow-break**:
  - Keep the existing navigation menu items and only add the missing navigation handler.

---

### 9) Reels Search + Filter by Tag Should Be Functional
- **Static Location**: `rapid_reels_app/lib/features/discover/presentation/screens/discover_feed_screen.dart`
- **Current Problems**:
  - Filter chips are functional only for `eventType` (via `getDiscoverReels(eventType: ...)`)
  - Search bottom sheet has a `TextField` but no search logic/controller
- **Target UI Sections**:
  - Search bottom sheet:
    - input + (optional) suggestions
    - results that update the reel pager
  - Filter chips:
    - define what “tag” means:
      - `eventType` (already implemented)
      - or `reels.tags` / `reels.hashtags` (extend filtering)
- **Firebase Integration**:
  - Extend `FirestoreService` with a discover search method that queries:
    - `reels.title`, `reels.eventName`
    - and optionally `reels.tags/hashtags`
- **No-flow-break**:
  - Keep the same reel rendering path; only swap in real search + tag filtering.

---

## 🔄 Partially Dynamic Screens (Using Mock Data Service)

These screens have dynamic loading mechanisms but currently use `MockDataService` instead of Firebase:

### 5. **Home Screen**
- **Location**: `rapid_reels_app/lib/features/home/presentation/screens/home_screen.dart`
- **Data Source**: MockDataService + Location Services
- **Features**:
  - Dynamic location detection
  - Nearby venues loading
  - City selection
  - Trending reels (mock data)
  - Featured providers (mock data)

---

### 6. **Provider Selection Screen**
- **Location**: `rapid_reels_app/lib/features/booking/presentation/screens/provider_selection_screen.dart`
- **Data Source**: MockDataService
- **Features**:
  - Dynamic provider loading by city
  - Filtering and sorting
  - Loading states
  - Pull-to-refresh

---

### 7. **Discover Feed Screen**
- **Location**: `rapid_reels_app/lib/features/discover/presentation/screens/discover_feed_screen.dart`
- **Data Source**: MockDataService
- **Features**:
  - Dynamic reel feed
  - Filter by event type
  - Follow/unfollow creators
  - Search functionality

---

### 8. **Venue Selection Screen**
- **Location**: `rapid_reels_app/lib/features/booking/presentation/screens/venue_selection_screen.dart`
- **Data Source**: Google Maps API + Location Services
- **Features**:
  - Dynamic map loading
  - Nearby venues detection
  - Location search
  - Real-time location updates

---

## 📊 Screens with Dynamic Providers (Ready for Firebase)

These screens have providers set up but may need Firebase integration:

### 9. **My Events Screen** (Standard)
- **Location**: `rapid_reels_app/lib/features/my_events/presentation/screens/my_events_screen.dart`
- **Status**: Uses mock data, but has provider structure

### 10. **My Reels Gallery Screen**
- **Location**: `rapid_reels_app/lib/features/reels/presentation/screens/my_reels_gallery_screen.dart`
- **Status**: Uses mock data, but has provider structure

### 11. **Referral Dashboard Screen**
- **Location**: `rapid_reels_app/lib/features/referral/presentation/screens/referral_dashboard_screen.dart`
- **Providers**: `referralStatsProvider`, `referralHistoryProvider`
- **Status**: Has provider structure ready

### 12. **Wallet Screen**
- **Location**: `rapid_reels_app/lib/features/referral/presentation/screens/wallet_screen.dart`
- **Providers**: `walletTransactionsProvider`
- **Status**: Has provider structure ready

### 13. **Transaction History Screen**
- **Location**: `rapid_reels_app/lib/features/wallet/presentation/screens/transaction_history_screen.dart`
- **Status**: Has provider structure ready

---

## 🔧 Provider-Based Dynamic Screens

### Booking Module
- **Provider Selection**: Uses `providersProvider`, `allProvidersProvider`, `featuredProvidersProvider`
- **User Bookings**: Uses `userBookingsProvider` (StreamProvider)
- **Upcoming Bookings**: Uses `userUpcomingBookingsProvider` (StreamProvider)
- **Past Bookings**: Uses `userPastBookingsProvider` (StreamProvider)

### Reels Module
- **User Reels**: Uses `userReelsProvider` (FutureProvider)
- **Public Reels**: Uses `publicReelsProvider` (FutureProvider)
- **Trending Reels**: Uses `trendingReelsProvider` (FutureProvider)

### Provider Module
- **Provider Stats**: Uses `providerStatsProvider` (FutureProvider)
- **Provider Earnings**: Uses `providerEarningsProvider` (FutureProvider)

---

## 📝 Summary

### Fully Dynamic (Firebase):
1. ✅ Dynamic Profile Screen
2. ✅ Dynamic My Events Screen
3. ✅ Dynamic My Reels Screen
4. ✅ Profile Screen (Standard)

### Partially Dynamic (Mock Data):
5. ⚠️ Home Screen
6. ⚠️ Provider Selection Screen
7. ⚠️ Discover Feed Screen
8. ⚠️ Venue Selection Screen

### Ready for Dynamic (Provider Structure Exists):
9. 🔄 My Events Screen (Standard)
10. 🔄 My Reels Gallery Screen
11. 🔄 Referral Dashboard Screen
12. 🔄 Wallet Screen
13. 🔄 Transaction History Screen

---

## 🎯 Key Indicators of Dynamic Screens

A screen is considered "dynamic" if it:
- ✅ Uses `StreamProvider` or `FutureProvider` from Riverpod
- ✅ Fetches data from Firebase Firestore
- ✅ Has loading states and error handling
- ✅ Supports pull-to-refresh
- ✅ Updates in real-time (for StreamProvider)
- ✅ Has empty states for no data

---

## 📌 Notes

- **Dynamic screens** = Screens that load data from external sources (Firebase, API, etc.)
- **Static screens** = Screens with hardcoded data or simple forms
- Some screens may appear static but have dynamic components (e.g., forms that submit to Firebase)

---

**Last Updated**: Based on current codebase analysis
**Total Dynamic Screens**: 13+ screens with dynamic data loading capabilities

---

## Firebase Implementation Appendix (Service + Rules)

### FirestoreService: required additions (to support items 1–9)

1. **Notifications**
   - Already exists:
     - `streamUserNotifications(userId)`
     - `markNotificationAsRead(notificationId)`
   - Optional:
     - add a helper to group notifications by type (for `All/Bookings/Updates`) if you want to centralize logic.

2. **Homepage Banner (Admin -> offers -> carousel)**
   - Customer reads already exists:
     - `getActiveOffers({eventType})`
   - Admin CRUD methods to add (if not already present in repo):
     - `createOffer(offer)`
     - `updateOffer(offerId, updates)`
     - `deleteOffer(offerId)`
     - optional: `streamOffers({isActive/isPublic})`

3. **Customer Reviews (Admin moderation -> approved/public homepage feed)**
   - Existing reads already exist for provider reviews:
     - `getProviderReviews(providerId)` (approved only)
   - For homepage city-based carousel, you’ll likely need one of:
     - `getApprovedPublicReviews(limit)` (query `/reviews` with `status == approved && isPublic == true`)
     - plus a client-side join to `/providers/{providerId}` to compute city-specific results.

4. **My Venues (users.savedAddresses)**
   - No new FirestoreService methods are strictly required because:
     - `FirestoreService.updateUser(userId, updates)` already exists
   - You may add a small helper:
     - `upsertSavedAddress(userId, SavedAddress address)` (appends/replaces then writes full list)

5. **Support Tickets (Submit Ticket + My Tickets)**
   - Existing:
     - `createSupportTicket(ticket)`
   - You will likely add:
     - `getUserSupportTickets(userId, {status, limit})` (customer-scoped query on `support_tickets`)
     - `appendSupportTicketMessage(ticketId, message)` (append to `messages` array + update `updatedAt`)

6. **Reels Engagement (Like/Commit/Share analytics)**
   - Existing:
     - `incrementReelViews(reelId)` updates `reels.analytics.views`
   - Missing (recommended):
     - `incrementReelLikes/reel.analytics.likes`
     - `incrementReelComments/reel.analytics.comments`
     - `incrementReelShares/reel.analytics.shares`
   - Because `/reels/{reelId}` analytics updates are restricted by rules (see below), implement these as:
     - callable/Cloud Function operations, or
     - server-side transactions, rather than direct client writes.

7. **Reels Search (Discover page)**
   - Extend FirestoreService with:
     - `searchDiscoverReels({query, eventType, tag})`
   - Use existing `getDiscoverReels(eventType, limit)` as the base and apply keyword filtering in-memory if indexes are a concern.

---

### Firestore Rules Impact Points (most important: reels analytics)

1. **Notifications (`/notifications`)**
   - Users can:
     - read only where `resource.data.userId == request.auth.uid`
     - update only the allowed keys for marking read:
       - `isRead`, `readAt`

2. **Support Tickets (`/support_tickets`)**
   - Users can:
     - read only their own tickets (`isOwner(resource.data.userId)`)
     - create tickets where `request.resource.data.userId == request.auth.uid`
     - update their own tickets (message updates)

3. **Saved Venues (update `users/{uid}`)**
   - Users can update their own user document.
   - This means writing to `users.savedAddresses` is allowed, as long as you write under `users/{request.auth.uid}`.

4. **Reels Analytics (`/reels/{reelId}`)**
   - Customer-driven engagement updates must not directly update `/reels/{reelId}.analytics` from the client unless you change rules.
   - Current rules allow updating `/reels/{reelId}` for:
     - provider owner (`isOwner(resource.data.providerId)`) or admin (`isAdmin()`)
   - Therefore, likes/comments/shares should be incremented server-side (callable/Cloud Function) OR you must implement narrow rules + idempotency (more risky).

5. **Reviews (`/reviews`)**
   - Homepage reads should be filtered to:
     - `status == approved && isPublic == true`
   - Admin has full access.

---

## Notes / Rollout Recommendations
- Implement each section behind a feature flag if possible.
- Validate Firestore operations with a test user:
  - ensure reads work (no composite index issues)
  - ensure writes succeed under current `firestore.rules`
- For reel analytics and engagement:
  - verify the server-side write path first before wiring UI taps.

