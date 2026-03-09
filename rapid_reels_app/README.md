# Rapid Reels - Instant Event Reel Platform

## Project Status

This is a work-in-progress Flutter application for instant event reel creation and delivery.

### ✅ Completed Features

#### 1. Project Foundation
- ✓ Flutter project initialized with clean architecture
- ✓ Folder structure following feature-based organization
- ✓ All required dependencies configured in pubspec.yaml
- ✓ Asset directories created

#### 2. Core Utilities
- ✓ App colors with brand guidelines (Red #FF0033, Purple #6B0DFF)
- ✓ App strings for localization
- ✓ App assets configuration
- ✓ App routes constants
- ✓ Dark theme with Material 3
- ✓ Text styles
- ✓ Firebase service initialization
- ✓ Validators (phone, email, OTP, etc.)
- ✓ Helper functions
- ✓ Date/time utilities

#### 3. Firebase Setup
- ✓ Firebase setup guide created (FIREBASE_SETUP_GUIDE.md)
- ✓ Firebase security rules documented
- ✓ Firestore database schema defined
- ✓ Firebase Storage rules documented
- ✓ Firebase Messaging configured

#### 4. Authentication Module
- ✓ User model with location, preferences, addresses
- ✓ Auth repository (Phone OTP, Email, Google Sign-In)
- ✓ Auth providers using Riverpod
- ✓ Splash screen with gradient background
- ✓ Onboarding screen (3 slides)
- ✓ Phone login screen with +91 prefix
- ✓ OTP verification screen (6-digit input)
- ✓ Profile setup screen with image picker
- ✓ Complete authentication flow

#### 5. Home & Navigation
- ✓ Home screen with location selector
- ✓ Quick action buttons (Book Now, Schedule, My Bookings, Refer & Earn)
- ✓ Event category carousel (Wedding, Birthday, Engagement, Corporate, Brand)
- ✓ Promotional banner carousel
- ✓ Trending reels section
- ✓ Bottom navigation bar (Home, Discover, My Reels, Profile)
- ✓ Main scaffold with navigation
- ✓ Routing configured with GoRouter

#### 6. Booking Flow (In Progress)
- ✓ Booking model with venue, package, customizations, payment data
- ⏳ Booking screens (event type selection, package selection, etc.)
- ⏳ Provider models
- ⏳ Booking repository

### 📋 Pending Features

1. **Complete Booking Flow**
   - Event type selection screen
   - Package comparison screen
   - Event details form
   - Venue selection with Google Maps
   - Provider selection and filtering
   - Package customization
   - Booking summary
   - Payment integration

2. **Payment Integration**
   - Razorpay service implementation
   - Payment screens
   - Cloud Functions for payment processing

3. **Provider Dashboard**
   - Provider app features
   - Event dashboard
   - Live event mode
   - Reel editor with quick edit tools
   - Upload footage functionality

4. **Customer Reel Experience**
   - Reel gallery screen
   - Full-screen reel player
   - Social media sharing
   - My Events management

5. **Discover & Social Features**
   - TikTok-style discover feed
   - Referral system
   - Wallet management

6. **Firebase Cloud Functions**
   - Notification triggers
   - Payment processing
   - Referral rewards
   - Scheduled reminders

7. **Notifications & Analytics**
   - Push notifications with FCM
   - Firebase Analytics integration

8. **Testing**
   - Unit tests
   - Widget tests
   - Integration tests

9. **Deployment**
   - Android release build
   - iOS release build
   - Play Store setup
   - App Store setup

## Getting Started

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Dart 3.0.0 or higher
- Firebase CLI
- Android Studio / Xcode

### Installation

1. Clone the repository
```bash
cd E:\Projects\Rapid_Reels\rapid_reels_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Set up Firebase (see FIREBASE_SETUP_GUIDE.md)

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root app widget with routing
├── core/
│   ├── constants/              # App-wide constants
│   ├── theme/                  # Theme configuration
│   ├── utils/                  # Utility functions
│   └── services/               # Core services (Firebase, etc.)
├── features/
│   ├── auth/                   # Authentication feature
│   ├── home/                   # Home screen feature
│   ├── booking/                # Booking flow feature
│   ├── my_events/              # Events management
│   ├── reels/                  # Reel viewing & sharing
│   ├── discover/               # Discover feed
│   ├── referral/               # Referral system
│   ├── profile/                # User profile
│   └── provider_dashboard/     # Provider features
└── shared/
    ├── widgets/                # Shared UI components
    ├── models/                 # Shared data models
    └── providers/              # Shared state providers
```

## Tech Stack

- **Framework**: Flutter 3.16.0+
- **State Management**: Riverpod 2.4.0
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Navigation**: GoRouter 12.1.0
- **UI**: Material 3 with custom dark theme
- **Payments**: Razorpay
- **Maps**: Google Maps
- **Analytics**: Firebase Analytics

## Key Dependencies

See `pubspec.yaml` for the complete list of dependencies including:
- Firebase suite (auth, firestore, storage, messaging, analytics, crashlytics)
- google_fonts, flutter_svg, cached_network_image, shimmer, lottie
- image_picker, video_player, share_plus
- geolocator, permission_handler
- razorpay_flutter
- carousel_slider, dots_indicator, flutter_rating_bar, table_calendar

## Documentation

- [Technical Documentation](../../files/Rapid_Reels_Technical_Documentation.md)
- [Quick Start Guide](../../files/Rapid_Reels_Quick_Start_Guide.md)
- [Firebase Setup Guide](FIREBASE_SETUP_GUIDE.md)

## Development Status

Currently at **Phase 5** of 12-phase development plan:
- ✅ Phase 1: Project Setup (Week 1)
- ✅ Phase 2: Authentication Module (Week 2)
- ✅ Phase 3: Home & Navigation (Week 3)
- 🚧 Phase 4: Event Booking Flow (Week 4-5)
- ⏳ Phase 5: Payment Integration (Week 6)
- ⏳ Phase 6-12: Additional features

## Contributing

This is a private project. For questions or issues, please contact the development team.

## License

Proprietary - All rights reserved

---

**Last Updated**: February 16, 2026
**Version**: 0.1.0 (Alpha)
**Build Status**: In Development 🚧
