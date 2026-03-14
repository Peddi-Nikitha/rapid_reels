# Build 3 - Dynamic Screens Implementation Plan

## Overview
This document outlines the plan for implementing 3 fully dynamic screens using Firebase models and shared domain models.

## Screens to Implement

### 1. Profile Screen (`DynamicProfileScreen`)
**Location**: `lib/features/profile/presentation/screens/dynamic_profile_screen.dart`

**Features**:
- Real-time user data from Firebase
- Profile statistics (events booked, reels received, wallet balance)
- Quick actions (Edit Profile, Wallet, Settings, Support)
- Recent activity feed
- Referral code display and sharing
- Profile completion indicator

**Data Sources**:
- `FirebaseUserModel` from Firestore
- Real-time updates using StreamBuilder
- Wallet balance from subcollection

**Key Components**:
- Profile header with avatar and stats
- Action buttons grid
- Recent bookings preview
- Recent reels preview
- Referral section

---

### 2. My Events Screen (`DynamicMyEventsScreen`)
**Location**: `lib/features/my_events/presentation/screens/dynamic_my_events_screen.dart`

**Features**:
- List of all user bookings from Firebase
- Filter by status (Upcoming, Ongoing, Completed, Cancelled)
- Search functionality
- Event details with real-time status
- Quick actions (View Details, Track Live, Cancel)
- Empty states for each filter

**Data Sources**:
- `FirebaseBookingModel` from Firestore
- Real-time updates for event status
- Filtered queries by status and date

**Key Components**:
- Status filter tabs
- Search bar
- Event cards with status indicators
- Pull-to-refresh
- Infinite scroll pagination

---

### 3. My Reels Screen (`DynamicMyReelsScreen`)
**Location**: `lib/features/reels/presentation/screens/dynamic_my_reels_screen.dart`

**Features**:
- Grid/list view of user reels
- Filter by status (All, Processing, Delivered, Published)
- Filter by event type
- Reel analytics display
- Download and share functionality
- Video player integration

**Data Sources**:
- `FirebaseReelModel` from Firestore
- Real-time analytics updates
- Filtered queries by customerId and status

**Key Components**:
- View toggle (Grid/List)
- Filter chips
- Reel cards with thumbnails
- Status badges
- Analytics overlay
- Empty states

---

## Implementation Strategy

### Phase 1: Setup
1. Create providers for each screen using Riverpod
2. Create repository methods for Firebase queries
3. Set up error handling and loading states

### Phase 2: UI Implementation
1. Build screen layouts with proper structure
2. Implement real-time data binding
3. Add loading and error states
4. Implement pull-to-refresh

### Phase 3: Features
1. Add filtering and search
2. Implement pagination
3. Add empty states
4. Add animations and transitions

### Phase 4: Integration
1. Connect to Firebase services
2. Test real-time updates
3. Add error handling
4. Optimize performance

---

## Technical Requirements

### Dependencies
- `flutter_riverpod` - State management
- `cloud_firestore` - Firebase Firestore
- `cached_network_image` - Image caching
- `shimmer` - Loading animations
- `pull_to_refresh` - Pull to refresh

### Firebase Queries

**Profile Screen**:
```dart
// Get user data
FirestoreService.getUser(userId)

// Get wallet balance
FirestoreService.getWalletBalance(userId)

// Get recent bookings (limit 5)
FirestoreService.getUserBookings(userId, limit: 5)

// Get recent reels (limit 5)
FirestoreService.getUserReels(userId, limit: 5)
```

**My Events Screen**:
```dart
// Get all bookings
FirestoreService.getUserBookings(userId)

// Filter by status
FirestoreService.getUserBookingsByStatus(userId, status)

// Search bookings
FirestoreService.searchUserBookings(userId, query)
```

**My Reels Screen**:
```dart
// Get all reels
FirestoreService.getUserReels(userId)

// Filter by status
FirestoreService.getUserReelsByStatus(userId, status)

// Filter by event type
FirestoreService.getUserReelsByEventType(userId, eventType)
```

---

## UI/UX Guidelines

### Loading States
- Use shimmer effects for list items
- Show skeleton screens during initial load
- Display progress indicators for actions

### Error States
- Show user-friendly error messages
- Provide retry options
- Handle network errors gracefully

### Empty States
- Display meaningful empty state messages
- Provide action buttons to create content
- Use illustrations/icons for visual appeal

### Real-time Updates
- Use StreamBuilder for live data
- Show update indicators when data changes
- Smooth transitions between states

---

## Testing Checklist

- [ ] Profile data loads correctly
- [ ] Real-time updates work
- [ ] Filters work correctly
- [ ] Search functionality works
- [ ] Pagination works
- [ ] Empty states display correctly
- [ ] Error handling works
- [ ] Loading states display correctly
- [ ] Pull-to-refresh works
- [ ] Performance is optimized

---

## Next Steps

1. Implement DynamicProfileScreen
2. Implement DynamicMyEventsScreen
3. Implement DynamicMyReelsScreen
4. Add unit tests
5. Add integration tests
6. Performance optimization
7. Documentation

