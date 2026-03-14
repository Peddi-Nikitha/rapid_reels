# Rapid Reels - Technical Documentation

## Project Overview

### App Description
Rapid Reels is a revolutionary instant reel creation and editing platform for events. The app connects event hosts with professional videographers, photographers, and editors who capture and deliver stunning, instantly-edited reels for weddings, birthday parties, engagements, brand collaborations, and corporate events. The unique value proposition is INSTANT reel delivery - guests can share event highlights on social media while the event is still happening.

### Key Highlights
- **Platform**: Mobile (iOS & Android)
- **Framework**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions)
- **Primary Function**: Instant event reel creation and delivery
- **Core Services**: Wedding reels, Birthday reels, Engagement reels, Brand collaboration reels, Corporate event reels
- **Unique Value**: Real-time or same-day reel delivery
- **Dual Interface**: Customer app + Provider management dashboard
- **Monetization**: Package-based pricing with commission model

---

## Tech Stack

### Frontend
- **Flutter SDK**: 3.16.0 or higher
- **Dart**: 3.0.0 or higher
- **State Management**: Provider / Riverpod / Bloc (Recommended: Riverpod)
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences / Hive

### Backend & Services
- **Firebase Authentication**: User authentication (Phone, Email, Google, Facebook)
- **Cloud Firestore**: Real-time database
- **Firebase Storage**: Media storage (images, videos)
- **Firebase Cloud Messaging**: Push notifications
- **Firebase Cloud Functions**: Backend logic, payment processing
- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Crash reporting

### Third-Party Integrations
- **Payment Gateway**: Razorpay / Stripe / PayU
- **Maps**: Google Maps API
- **SMS**: Firebase Phone Auth / Twilio
- **Image Picker**: image_picker package
- **Video Player**: video_player package
- **Share**: share_plus package

### UI/UX Libraries
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0
  
  # UI Components
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
  # Navigation
  go_router: ^12.1.0
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.2.2
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
  image_picker: ^1.0.5
  video_player: ^2.8.1
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Maps
  google_maps_flutter: ^2.5.0
  
  # Payments
  razorpay_flutter: ^1.3.6
  
  # Other
  carousel_slider: ^4.2.1
  dots_indicator: ^3.0.0
  flutter_rating_bar: ^4.0.1
  table_calendar: ^3.0.9
```

---

## App Architecture

### Folder Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_assets.dart
│   │   └── app_routes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── helpers.dart
│   │   └── date_utils.dart
│   └── services/
│       ├── firebase_service.dart
│       ├── location_service.dart
│       ├── notification_service.dart
│       └── payment_service.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── home/
│   ├── booking/
│   ├── schedule/
│   ├── my_bookings/
│   ├── referral/
│   ├── discover/
│   └── profile/
└── shared/
    ├── widgets/
    ├── models/
    └── providers/
```

---

## Features & Modules

### Customer App Features

#### 1. Authentication Module
**Features:**
- Phone number authentication (OTP-based)
- Email/Password authentication
- Google Sign-In
- Facebook Sign-In
- User profile management
- Session management

**Screens:**
- Splash Screen
- Onboarding Screens (Showcasing instant reel delivery)
- Login Screen
- OTP Verification Screen
- Profile Setup Screen

#### 2. Home Module
**Features:**
- Personalized greeting with user's location
- Location selector dropdown
- Quick action buttons (Book Event, My Events, My Reels, Refer & Earn)
- Event category carousel (Wedding, Birthday, Engagement, Corporate, Brand)
- "Trending Reels" section showcasing sample work
- Package highlights
- Bottom navigation bar

**Screens:**
- Home Dashboard

#### 3. Event Booking Module
**Features:**
- Event type selection (Wedding, Birthday, Engagement, Brand Collaboration, Corporate)
- Package selection (Bronze, Silver, Gold, Platinum)
- Date and time picker
- Duration selection
- Venue/location input with map
- Guest count estimation
- Special requirements (editing style, music preference, delivery timeline)
- Videographer/photographer selection
- Booking summary and confirmation
- Payment integration
- Instant booking receipt

**Screens:**
- Event Type Selection Screen
- Package Comparison Screen
- Event Details Form Screen
- Venue Selection Screen (with map)
- Provider Selection Screen
- Package Customization Screen
- Booking Summary Screen
- Payment Screen
- Booking Confirmation Screen

**Package Tiers:**
- **Bronze**: 2-hour coverage, 1 instant reel (30-60 sec), basic editing, delivered in 2 hours
- **Silver**: 4-hour coverage, 3 instant reels, standard editing, delivered in 1 hour
- **Gold**: 6-hour coverage, 5 instant reels + 1 highlight video (2-3 min), premium editing, delivered instantly + full video next day
- **Platinum**: Full-day coverage, unlimited instant reels, cinematic editing, live reel station, instant delivery + full edited video same day

#### 4. My Events Module
**Features:**
- Upcoming events list
- Active/ongoing events with live status
- Past events archive
- Event details view
- Reschedule/cancel functionality
- Event countdown timer
- Provider contact information
- Real-time event tracking

**Screens:**
- My Events Screen (with tabs: Upcoming, Live, Past)
- Event Details Screen
- Event Tracking Screen (live coverage status)

#### 5. My Reels Module
**Features:**
- All received reels gallery
- Organized by event
- Video player with controls
- Download reel to device
- Direct share to Instagram, Facebook, WhatsApp, TikTok
- Reel analytics (views, shares)
- Favorite/save reels
- Request re-edit (with additional fee)
- QR code for easy sharing

**Screens:**
- Reels Gallery Screen
- Reel Player Screen (full-screen video)
- Share Options Screen
- Reel Details Screen

#### 6. Discover/Trending Reels Module
**Features:**
- Curated feed of sample reels from different events
- Filter by event type
- Filter by editing style
- Like and save reels
- View provider portfolio
- Book provider directly from reel
- Inspiration gallery

**Screens:**
- Discover Feed Screen (TikTok-style vertical video feed)
- Provider Portfolio Screen

#### 7. Referral & Earn Module
**Features:**
- Referral code generation
- Share referral link
- Referral tracking dashboard
- Rewards wallet
- Redemption options (discount on bookings, cash withdrawal)
- Referral history and statistics

**Screens:**
- Referral Dashboard Screen
- Wallet Screen
- Referral History Screen
- Redemption Screen

#### 8. Profile Module
**Features:**
- User profile view/edit
- Saved venues/addresses
- Payment methods
- Notification preferences
- App settings
- Event preferences (favorite styles, music)
- Help & Support
- Terms & Privacy
- Logout

**Screens:**
- Profile Screen
- Edit Profile Screen
- Saved Venues Screen
- Payment Methods Screen
- Settings Screen
- Support Screen

---

### Provider App/Dashboard Features

#### 1. Provider Profile Management
**Features:**
- Business profile setup
- Portfolio upload (sample reels and photos)
- Service areas configuration
- Pricing and package management
- Availability calendar
- Team member management
- Equipment inventory
- Certifications/awards showcase

#### 2. Booking Management
**Features:**
- New booking notifications
- Accept/decline bookings
- View booking details
- Event calendar view
- Booking timeline
- Customer contact information
- Navigation to venue
- Pre-event checklist

#### 3. Reel Management System (CORE FEATURE)
**Features:**
- Active event dashboard
- Upload raw footage during event
- Quick edit tools (trim, filters, transitions, music)
- AI-assisted editing suggestions
- Reel preview before delivery
- Batch reel creation
- Delivery queue management
- Quality control check
- Delivered reels archive
- Performance analytics (delivery time, customer satisfaction)

**Screens:**
- Event Dashboard Screen
- Upload Footage Screen
- Reel Editor Screen (mobile editing interface)
- Preview Screen
- Delivery Confirmation Screen
- Reel History Screen

#### 4. Live Event Mode
**Features:**
- Start event coverage
- Real-time footage upload
- Instant reel creation workflow
- Push notification to customer when reel is ready
- Live event timer
- Shot checklist (for ensuring all key moments captured)
- Customer milestone notifications

#### 5. Financial Management
**Features:**
- Earnings dashboard
- Payment history
- Pending payments
- Commission breakdown
- Payout requests
- Tax documentation
- Performance metrics

#### 6. Analytics & Insights
**Features:**
- Booking statistics
- Customer ratings and reviews
- Popular packages
- Peak booking times
- Revenue trends
- Reel performance metrics

---

## Firebase Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: "rapid-reels-app"
4. Enable Google Analytics (recommended)
5. Create project

### Step 2: Add Android App
1. Click "Add App" → Android
2. Register app:
   - Package name: `com.rapidreels.app`
   - App nickname: "Rapid Reels Android"
   - SHA-1 certificate: Generate using `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
3. Download `google-services.json`
4. Place in `android/app/` directory
5. Update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```
6. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        applicationId "com.rapidreels.app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

### Step 3: Add iOS App
1. Click "Add App" → iOS
2. Register app:
   - Bundle ID: `com.rapidreels.app`
   - App nickname: "Rapid Reels iOS"
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` in Xcode
5. Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

### Step 4: Enable Firebase Services

#### Authentication
1. Navigate to Authentication → Sign-in method
2. Enable:
   - Phone (with reCAPTCHA)
   - Email/Password
   - Google
   - Facebook (with App ID and Secret)

#### Firestore Database
1. Navigate to Firestore Database
2. Create database
3. Start in **production mode**
4. Choose location: `asia-south1` (Mumbai)
5. Set up security rules (see Database Structure section)

#### Storage
1. Navigate to Storage
2. Get Started
3. Use default security rules initially
4. Update rules (see below)

#### Cloud Messaging
1. Navigate to Cloud Messaging
2. Configure for Android and iOS
3. Upload APNs certificate for iOS

#### Cloud Functions
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Initialize functions: `firebase init functions`
3. Choose JavaScript or TypeScript

---

## Database Structure (Firestore)

### Collections Schema

#### 1. users (Customers)
```javascript
{
  userId: "auto-generated-id",
  phoneNumber: "+919876543210",
  email: "user@example.com",
  fullName: "Rajesh Kumar",
  profileImage: "https://...",
  currentLocation: {
    city: "Siddipet",
    state: "Telangana",
    country: "India",
    coordinates: {
      latitude: 18.1023,
      longitude: 78.8514
    }
  },
  savedVenues: [
    {
      venueId: "venue_1",
      label: "Home Address",
      address: "123 Main St, Siddipet",
      city: "Siddipet",
      pincode: "502103",
      coordinates: {...}
    }
  ],
  preferences: {
    favoriteEditingStyles: ["cinematic", "vintage"],
    favoriteMusic: ["bollywood", "edm"],
    defaultEventType: "wedding"
  },
  referralCode: "RAJESH2024",
  walletBalance: 500.00,
  totalEventsBooked: 5,
  totalReelsReceived: 23,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 2. providers (Videographers/Photographers/Editors)
```javascript
{
  providerId: "provider_1",
  businessName: "Rapid Reels Studios",
  ownerName: "Priya Sharma",
  email: "priya@rapidreels.com",
  phoneNumber: "+919876543211",
  profileImage: "https://...",
  coverImages: ["https://...", "https://..."],
  bio: "Specializing in instant wedding reels with cinematic quality",
  
  // Event types they cover
  eventTypes: ["wedding", "engagement", "birthday", "corporate", "brand"],
  
  // Packages offered
  packages: [
    {
      packageId: "pkg_bronze",
      name: "Bronze",
      price: 8000,
      duration: 120, // minutes
      reelsCount: 1,
      editingStyle: "basic",
      deliveryTime: 120, // minutes
      features: [
        "2-hour coverage",
        "1 instant reel (30-60 sec)",
        "Basic editing",
        "Delivered in 2 hours"
      ]
    },
    {
      packageId: "pkg_silver",
      name: "Silver",
      price: 15000,
      duration: 240,
      reelsCount: 3,
      editingStyle: "standard",
      deliveryTime: 60,
      features: [
        "4-hour coverage",
        "3 instant reels",
        "Standard editing with transitions",
        "Delivered in 1 hour"
      ]
    },
    {
      packageId: "pkg_gold",
      name: "Gold",
      price: 25000,
      duration: 360,
      reelsCount: 5,
      editingStyle: "premium",
      deliveryTime: 30,
      highlightVideo: true,
      features: [
        "6-hour coverage",
        "5 instant reels + 1 highlight video (2-3 min)",
        "Premium editing with effects",
        "Instant delivery",
        "Full edited video next day"
      ]
    },
    {
      packageId: "pkg_platinum",
      name: "Platinum",
      price: 45000,
      duration: 600, // full day
      reelsCount: -1, // unlimited
      editingStyle: "cinematic",
      deliveryTime: 15,
      liveReelStation: true,
      features: [
        "Full-day coverage",
        "Unlimited instant reels",
        "Cinematic editing",
        "Live reel station at event",
        "Instant delivery",
        "Full edited video same day",
        "4K quality",
        "Drone footage included"
      ]
    }
  ],
  
  // Portfolio
  portfolio: [
    {
      reelId: "reel_sample_1",
      eventType: "wedding",
      thumbnailUrl: "https://...",
      videoUrl: "https://...",
      duration: 45,
      views: 12500,
      likes: 890
    }
  ],
  
  // Location and service areas
  location: {
    address: "456 Studio Lane, Hyderabad",
    city: "Hyderabad",
    state: "Telangana",
    pincode: "500001",
    coordinates: {...}
  },
  serviceAreas: ["Siddipet", "Hyderabad", "Karimnagar", "Warangal"],
  serviceRadius: 50, // km
  
  // Team information
  teamSize: 3,
  equipment: ["4K Camera", "Gimbal", "Drone", "Professional Lighting"],
  
  // Ratings and stats
  rating: 4.9,
  totalReviews: 156,
  totalEventsCompleted: 245,
  totalReelsDelivered: 1234,
  averageDeliveryTime: 35, // minutes
  
  // Availability
  availability: {
    monday: { isAvailable: true, slots: [...] },
    tuesday: { isAvailable: true, slots: [...] },
    // ... other days
  },
  
  // Blocked dates (already booked or unavailable)
  blockedDates: [
    {
      date: Timestamp,
      reason: "Booked - Wedding Event",
      bookingId: "event_123"
    }
  ],
  
  // Financial
  bankDetails: {
    accountNumber: "123456789",
    ifscCode: "SBIN0001234",
    accountHolderName: "Priya Sharma",
    upiId: "priya@paytm"
  },
  commissionRate: 15, // percentage taken by platform
  
  isVerified: true,
  isActive: true,
  isFeatured: false,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 3. events (Bookings)
```javascript
{
  eventId: "event_1",
  customerId: "user_1",
  providerId: "provider_1",
  
  // Event details
  eventType: "wedding", // wedding, birthday, engagement, corporate, brand
  eventName: "Rajesh & Priya Wedding",
  eventDate: Timestamp,
  eventTime: "10:00 AM",
  duration: 360, // minutes
  guestCount: 500,
  
  // Venue details
  venue: {
    name: "Green Gardens Convention Hall",
    address: "123 Garden Road, Siddipet",
    city: "Siddipet",
    pincode: "502103",
    coordinates: {
      latitude: 18.1023,
      longitude: 78.8514
    }
  },
  
  // Package selected
  packageId: "pkg_gold",
  packageName: "Gold",
  packagePrice: 25000,
  
  // Customizations
  customizations: {
    editingStyle: "cinematic",
    musicPreference: "bollywood",
    colorGrading: "warm",
    includeDrone: true,
    additionalReels: 2,
    additionalCost: 3000
  },
  
  // Special requirements
  specialRequirements: "Please focus on couple entry and ring ceremony. Need reels ready before reception starts.",
  keyMoments: [
    "Bride Entry",
    "Groom Entry",
    "Varmala Ceremony",
    "Ring Exchange",
    "First Dance"
  ],
  
  // Status tracking
  status: "confirmed", // pending, confirmed, ongoing, completed, cancelled
  eventStatus: {
    bookingConfirmed: Timestamp,
    providerAccepted: Timestamp,
    eventStarted: Timestamp,
    firstReelDelivered: Timestamp,
    eventCompleted: Timestamp,
    allReelsDelivered: Timestamp
  },
  
  // Payment
  totalAmount: 28000, // base + customizations
  advanceAmount: 14000, // 50% advance
  remainingAmount: 14000,
  paymentStatus: "advance_paid", // pending, advance_paid, fully_paid, refunded
  payments: [
    {
      paymentId: "pay_123",
      amount: 14000,
      method: "razorpay",
      transactionId: "txn_abc123",
      status: "success",
      paidAt: Timestamp
    }
  ],
  
  // Contact
  contactPerson: "Rajesh Kumar",
  contactNumber: "+919876543210",
  alternateContact: "+919876543211",
  
  // Delivery expectations
  expectedReelsCount: 5,
  deliveryTimeline: "instant", // instant, same_day, next_day
  
  createdAt: Timestamp,
  updatedAt: Timestamp,
  cancelledAt: Timestamp,
  cancellationReason: "",
  completedAt: Timestamp
}
```

#### 4. reels
```javascript
{
  reelId: "reel_1",
  eventId: "event_1",
  customerId: "user_1",
  providerId: "provider_1",
  
  // Reel details
  title: "Wedding Entry - Rajesh & Priya",
  description: "Cinematic entry of the beautiful couple",
  eventType: "wedding",
  eventMoment: "Bride Entry", // which key moment this covers
  
  // Video details
  videoUrl: "https://storage.googleapis.com/rapid-reels/reels/reel_1.mp4",
  thumbnailUrl: "https://...",
  duration: 45, // seconds
  resolution: "1080p", // 720p, 1080p, 4K
  aspectRatio: "9:16", // vertical for Instagram/TikTok
  fileSize: 25.5, // MB
  
  // Editing details
  editingStyle: "cinematic",
  filters: ["warm_tone", "soft_glow"],
  transitions: ["cross_dissolve", "zoom"],
  musicTrack: {
    name: "Tum Hi Ho",
    artist: "Arijit Singh",
    duration: 45,
    license: "royalty_free"
  },
  colorGrading: "warm",
  
  // Processing status
  status: "delivered", // processing, ready, delivered, archived
  uploadedAt: Timestamp, // when provider uploaded raw footage
  processedAt: Timestamp, // when editing completed
  deliveredAt: Timestamp, // when sent to customer
  processingTime: 25, // minutes from upload to delivery
  
  // Quality metrics
  qualityScore: 95, // internal quality check score
  
  // Engagement
  views: 1234,
  likes: 89,
  shares: 23,
  downloads: 5,
  
  // Customer feedback
  customerRating: 5,
  customerFeedback: "Absolutely loved it! Perfect capture!",
  
  // Visibility
  isPublic: false, // can be shown in provider portfolio
  isHighlight: true, // featured reel for this event
  
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 5. reviews
```javascript
{
  reviewId: "rev_1",
  eventId: "event_1",
  customerId: "user_1",
  providerId: "provider_1",
  
  // Overall ratings
  overallRating: 5,
  
  // Detailed ratings
  ratings: {
    quality: 5, // video quality
    editing: 5, // editing quality
    creativity: 5,
    professionalism: 5,
    timeliness: 5, // delivery speed
    valueForMoney: 4
  },
  
  // Review content
  title: "Outstanding instant reel service!",
  comment: "Priya and her team did an amazing job! We received our first reel while the event was still going on. Guests were amazed when we shared it. Highly recommend the Gold package!",
  images: ["https://..."], // optional review images
  
  // Provider response
  providerResponse: "Thank you so much! It was a pleasure capturing your special day!",
  providerRespondedAt: Timestamp,
  
  isVerified: true, // verified booking
  isHighlighted: false, // featured review
  helpfulCount: 45, // how many found this review helpful
  
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 6. referrals
```javascript
{
  referralId: "ref_1",
  referrerId: "user_1", // who referred
  referredUserId: "user_2", // who was referred
  referralCode: "RAJESH2024",
  
  status: "completed", // pending, completed, expired
  
  // Rewards
  rewardAmount: 200, // ₹200 for each successful referral
  rewardType: "wallet_credit", // wallet_credit, discount_coupon
  rewardCredited: true,
  
  // Conditions
  referredUserFirstBooking: "event_5", // referred user must complete first booking
  referredUserFirstBookingCompleted: true,
  
  createdAt: Timestamp,
  completedAt: Timestamp,
  expiresAt: Timestamp
}
```

#### 7. wallet_transactions
```javascript
{
  transactionId: "txn_1",
  userId: "user_1",
  type: "credit", // credit, debit
  amount: 200,
  description: "Referral bonus for inviting Amit",
  
  referenceType: "referral", // referral, event_booking, refund, withdrawal
  referenceId: "ref_1",
  
  balanceBefore: 500,
  balanceAfter: 700,
  
  status: "completed", // pending, completed, failed
  
  createdAt: Timestamp
}
```

#### 8. trending_reels (Public showcase)
```javascript
{
  contentId: "trending_1",
  reelId: "reel_1",
  providerId: "provider_1",
  
  title: "Cinematic Wedding Entry",
  description: "Stunning bride entry captured and edited instantly",
  
  videoUrl: "https://...",
  thumbnailUrl: "https://...",
  duration: 45,
  
  eventType: "wedding",
  editingStyle: "cinematic",
  
  // Engagement
  views: 25000,
  likes: 2100,
  shares: 350,
  saves: 890,
  
  // Featured status
  isFeatured: true,
  featuredUntil: Timestamp,
  displayOrder: 1,
  
  tags: ["wedding", "bride_entry", "cinematic", "trending"],
  
  isActive: true,
  createdAt: Timestamp
}
```

#### 9. notifications
```javascript
{
  notificationId: "notif_1",
  userId: "user_1",
  userType: "customer", // customer, provider
  
  title: "Your reel is ready! 🎉",
  body: "Your bride entry reel is ready to view and share!",
  
  type: "reel_delivered", // booking_confirmed, event_started, reel_delivered, payment_reminder, promotion
  
  data: {
    reelId: "reel_1",
    eventId: "event_1",
    screen: "reel_player", // deep link screen
    action: "view_reel"
  },
  
  imageUrl: "https://...", // thumbnail for rich notification
  
  priority: "high", // high, normal, low
  isRead: false,
  readAt: Timestamp,
  
  createdAt: Timestamp
}
```

#### 10. event_templates (Pre-made packages for quick booking)
```javascript
{
  templateId: "template_1",
  name: "Classic Wedding Package",
  eventType: "wedding",
  description: "Perfect for traditional wedding ceremonies",
  
  basePrice: 20000,
  duration: 360,
  reelsCount: 4,
  
  features: [
    "Full ceremony coverage",
    "4 instant reels",
    "1 highlight video",
    "Same-day delivery"
  ],
  
  keyMoments: [
    "Bride Entry",
    "Groom Entry",
    "Varmala",
    "Phere"
  ],
  
  popularityScore: 95,
  timesBooked: 234,
  
  isActive: true
}
```

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isProvider(providerId) {
      return isAuthenticated() && request.auth.uid == providerId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // Providers collection
    match /providers/{providerId} {
      allow read: if true; // public profiles
      allow create: if isAuthenticated();
      allow update: if isProvider(providerId);
      allow delete: if isProvider(providerId);
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if isAuthenticated() && 
        (resource.data.customerId == request.auth.uid || 
         resource.data.providerId == request.auth.uid);
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        (resource.data.customerId == request.auth.uid ||
         resource.data.providerId == request.auth.uid);
      allow delete: if false; // cannot delete, only cancel
    }
    
    // Reels collection
    match /reels/{reelId} {
      allow read: if isAuthenticated() && 
        (resource.data.customerId == request.auth.uid || 
         resource.data.providerId == request.auth.uid ||
         resource.data.isPublic == true);
      allow create: if isAuthenticated() && isProvider(request.resource.data.providerId);
      allow update: if isAuthenticated() && 
        (resource.data.providerId == request.auth.uid ||
         resource.data.customerId == request.auth.uid);
      allow delete: if false;
    }
    
    // Reviews
    match /reviews/{reviewId} {
      allow read: if true; // public reviews
      allow create: if isAuthenticated() && isOwner(request.resource.data.customerId);
      allow update: if isAuthenticated() && 
        (resource.data.customerId == request.auth.uid ||
         resource.data.providerId == request.auth.uid);
      allow delete: if isOwner(resource.data.customerId);
    }
    
    // Referrals
    match /referrals/{referralId} {
      allow read: if isAuthenticated() && 
        (resource.data.referrerId == request.auth.uid || 
         resource.data.referredUserId == request.auth.uid);
      allow create: if isAuthenticated();
      allow update: if false; // Cloud Functions only
      allow delete: if false;
    }
    
    // Wallet transactions (read-only for users)
    match /wallet_transactions/{transactionId} {
      allow read: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow write: if false; // Cloud Functions only
    }
    
    // Trending reels (public)
    match /trending_reels/{contentId} {
      allow read: if true;
      allow write: if false; // Admin only
    }
    
    // Notifications
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow create, delete: if false; // Cloud Functions only
    }
    
    // Event templates (public read)
    match /event_templates/{templateId} {
      allow read: if true;
      allow write: if false; // Admin only
    }
  }
}
```

---

## UI/UX Flow

### User Journey Map

#### 1. First Time User Flow
```
Splash Screen (Rapid Reels Logo)
    ↓
Onboarding Screens (3 slides)
    • Slide 1: "Instant Reels for Your Special Moments"
    • Slide 2: "Book → Capture → Edit → Share - All in Real-Time"
    • Slide 3: "From Weddings to Birthdays, We've Got You Covered"
    ↓
Login/Signup Screen
    ↓
Phone Number Input
    ↓
OTP Verification
    ↓
Profile Setup (Name, Photo, Location)
    ↓
Event Preferences (Select favorite event types & editing styles)
    ↓
Location Permission Request
    ↓
Home Dashboard
```

#### 2. Event Booking Flow (Customer)
```
Home Dashboard
    ↓
Tap "Book Event" or Select Event Type
    ↓
Event Type Selection
    • Wedding
    • Birthday Party
    • Engagement
    • Brand Collaboration
    • Corporate Event
    ↓
Package Selection Screen
    • Compare: Bronze, Silver, Gold, Platinum
    • View sample reels for each package
    • See delivery timeline for each
    ↓
Event Details Form
    • Event Name
    • Date & Time
    • Duration
    • Guest Count
    • Venue/Location (with map picker)
    ↓
Provider Selection (Optional)
    • Browse available providers
    • Filter by rating, price, style
    • View provider portfolio
    • Or "Auto-assign best match"
    ↓
Customize Package
    • Add extra reels (+₹1500 each)
    • Select editing style preference
    • Choose music genre
    • Add drone footage (+₹3000)
    • Specify key moments to capture
    ↓
Review Booking Summary
    • Event details
    • Package breakdown
    • Total cost
    • Expected deliverables
    • Delivery timeline
    ↓
Special Instructions (Optional)
    • Text input for specific requirements
    • Upload reference reel style
    ↓
Payment Screen
    • Choose payment method
    • Pay advance (50%) or full amount
    ↓
Payment Success
    ↓
Booking Confirmation Screen
    • Booking ID
    • Provider details
    • Pre-event checklist
    • Contact provider button
    • Add to calendar
    ↓
Receive Confirmation Notification
    ↓
(2 days before) Pre-Event Reminder
    ↓
(Event Day) Provider Arrives & Starts Coverage
```

#### 3. Live Event & Reel Delivery Flow
```
Event Day - Provider starts coverage
    ↓
Customer receives notification: "Coverage started! 📹"
    ↓
Provider captures moments & uploads footage
    ↓
Provider edits first reel
    ↓
Notification: "Your first reel is ready! 🎉"
    ↓
Customer opens app → My Reels
    ↓
Watch reel in full-screen player
    ↓
Options available:
    • Download to device
    • Share to Instagram (direct integration)
    • Share to WhatsApp
    • Share via QR code
    • Add to favorites
    ↓
Customer shares while event is ongoing
    ↓
Additional reels delivered throughout event
    ↓
Event completes
    ↓
Final notification: "All reels delivered! Check your gallery 📱"
    ↓
(If Gold/Platinum) Next day: Highlight video delivered
```

#### 4. My Events Management Flow
```
Home Dashboard
    ↓
Tap "My Events"
    ↓
Tabs: Upcoming | Live | Completed
    ↓
Select an event
    ↓
Event Details Screen shows:
    • Event countdown (if upcoming)
    • Live status (if ongoing)
    • All delivered reels (if completed)
    • Provider contact
    • Payment status
    • Package details
    ↓
Actions available:
    • Contact provider
    • Reschedule (if upcoming)
    • View reels (if live/completed)
    • Download invoice
    • Write review (if completed)
    • Re-book similar event
```

#### 5. Reel Gallery & Sharing Flow
```
Home Dashboard
    ↓
Tap "My Reels" or Bottom Nav → Reels
    ↓
Reels Gallery (organized by event)
    ↓
Select a reel
    ↓
Full-Screen Video Player
    • Swipe up/down for next/previous reel
    • Tap for controls
    • Double-tap to like
    ↓
Actions:
    • Download (HD/4K options)
    • Share → Instagram Reels
    • Share → Instagram Story
    • Share → WhatsApp Status
    • Share → Facebook
    • Share → TikTok
    • Copy link
    • Generate QR code for easy sharing
    • Request re-edit (paid)
    • Report issue
    ↓
Analytics visible:
    • Views on platform
    • Times downloaded
    • Times shared
```

#### 6. Discover/Trending Flow
```
Home Dashboard or Bottom Nav → Discover
    ↓
Trending Reels Feed
    • Vertical scroll (TikTok-style)
    • Auto-play as you scroll
    ↓
Filters:
    • Event Type (Wedding, Birthday, etc.)
    • Editing Style (Cinematic, Vintage, Modern)
    • Provider
    ↓
Tap on a reel
    ↓
Full-screen playback
    • View provider profile
    • See package used
    • Book this provider
    • Save as inspiration
    ↓
Tap provider name
    ↓
Provider Portfolio Page
    • All sample reels
    • Ratings & reviews
    • Packages & pricing
    • Book now button
```

#### 7. Referral Flow
```
Home Dashboard
    ↓
Tap "Refer & Earn"
    ↓
Referral Dashboard
    • Your unique code: RAJESH2024
    • Wallet balance: ₹500
    • Total referrals: 3
    • Pending rewards: ₹200
    ↓
Tap "Share Code"
    ↓
Share Options:
    • WhatsApp: "Join Rapid Reels with my code RAJESH2024 and get ₹100 off!"
    • Instagram Story (branded template)
    • Copy link
    • Generate QR code
    ↓
Friend signs up & books event
    ↓
Notification: "Your friend Amit booked an event! ₹200 added to wallet 💰"
    ↓
Use wallet balance for next booking discount
```

---

### Provider App Journey

#### 1. Provider Onboarding
```
Download Provider App
    ↓
Sign Up
    • Business details
    • Upload portfolio (min 5 reels)
    • Bank details
    • Service areas
    • Pricing & packages
    ↓
Verification Process
    • Document upload (GST, business license)
    • Phone verification
    • Quality check of sample work
    ↓
Approval notification
    ↓
Profile goes live
```

#### 2. Receiving & Accepting Bookings
```
New Booking Request Notification
    ↓
Provider Dashboard → Pending Requests
    ↓
View Booking Details:
    • Event type & name
    • Date, time, duration
    • Venue location
    • Package selected
    • Customer requirements
    • Payment: ₹14,000 advance
    ↓
Options:
    • Accept (if available)
    • Decline (with reason)
    • Counter-offer (different price/package)
    ↓
If Accepted:
    • Event added to calendar
    • Customer notified
    • Event checklist generated
```

#### 3. Live Event Coverage & Reel Creation
```
Event Day
    ↓
Provider Dashboard → Today's Events
    ↓
Tap event → "Start Coverage"
    ↓
Live Event Mode activated
    • Timer starts
    • Customer notified: "Coverage started"
    • Shot checklist displayed
    ↓
Capture footage
    ↓
Upload raw clips via app
    • Wifi/mobile data
    • Automatic compression
    • Background upload
    ↓
Quick Edit Interface:
    • Select clips for reel
    • Trim & arrange
    • Apply filters
    • Add music from library
    • Add transitions
    • Preview
    ↓
Submit for delivery
    ↓
Reel processes (30 seconds)
    ↓
Reel delivered to customer
    ↓
Customer notification sent
    ↓
Provider sees delivery confirmation
    ↓
Repeat for additional reels
    ↓
End coverage when event completes
    ↓
Mark event as completed
```

#### 4. Reel Management Dashboard
```
Provider Dashboard → Reel Management
    ↓
Tabs:
    • In Progress (currently editing)
    • Delivered (sent to customers)
    • Pending Upload (footage captured, not edited)
    • Archive (all historical reels)
    ↓
Performance Metrics:
    • Average delivery time: 25 mins
    • Customer satisfaction: 4.9/5
    • Total reels created: 234
    • This month's earnings: ₹1,24,000
    ↓
Quality Control:
    • Flag reels for quality issues
    • Customer feedback on each reel
    • Re-edit requests
```

### Screen Wireframes Description

#### Customer App - Home Screen
**Layout:**
- **Status Bar**: Time, network, battery
- **Header Section**:
  - Logo: "Rapid Reels" (stylized with play button)
  - Location: "Siddipet, Telangana" with dropdown
  - Greeting: "Hi, Rajesh! 👋"
- **Hero Section**:
  - Large text: "Instant Reels for Your Special Moments"
  - Subtext: "Book now, share tonight"
- **Event Type Quick Select** (Horizontal scroll cards):
  - 💍 Wedding
  - 🎂 Birthday
  - 💑 Engagement
  - 🏢 Corporate
  - 🤝 Brand Collab
- **Quick Actions Grid** (2x2):
  - 📅 Book Event (primary button, larger, red gradient)
  - 📱 My Events
  - 🎬 My Reels
  - 💰 Refer & Earn
- **Trending Reels Carousel**:
  - Auto-scrolling video thumbnails
  - "Trending This Week" header
  - Dot indicators
- **Featured Packages**:
  - Horizontal cards showing Bronze, Silver, Gold, Platinum
  - Price, features, popular badge
- **Bottom Navigation**:
  - 🏠 Home (active - red)
  - 🔥 Trending
  - ➕ Book (center, elevated)
  - 🎬 Reels
  - 👤 Profile

**Color Scheme:**
- Primary: Vibrant Red (#FF0033)
- Secondary: Deep Purple (#6B0DFF)
- Gradient: Red to Purple for premium feel
- Background: Dark theme (#0A0A0A)
- Cards: Dark gray (#1A1A1A)
- Text: White (#FFFFFF)
- Accent text: Light gray (#B0B0B0)

**Typography:**
- Logo: Bold, modern sans-serif
- Headings: Bold, 26-30pt
- Body: Regular, 15-16pt
- Buttons: Semi-bold, 16-18pt

#### Event Booking Screen
**Layout:**
- Progress indicator (5 steps)
- Event type selection with large icon cards
- Package comparison table
- Date/time picker (calendar view)
- Venue map with search
- Customization options (chips for add-ons)
- Floating "Continue" button
- Cost summary sticky at bottom

#### Reel Player Screen
**Layout:**
- Full-screen vertical video
- Gradient overlay at bottom
- Reel title and event name
- Provider watermark (subtle)
- Action buttons:
  - ❤️ Like
  - 💬 Comment
  - 📤 Share
  - ⬇️ Download
- Swipe gestures for navigation
- Progress bar
- Instagram-style share integration

---

## Implementation Guide

### Phase 1: Project Setup (Week 1)

#### Day 1-2: Initialize Flutter Project
```bash
flutter create rapid_reels_app
cd rapid_reels_app
```

Add dependencies in `pubspec.yaml` (see Tech Stack section)

Create folder structure:
```bash
mkdir -p lib/{core/{constants,theme,utils,services},features/{auth,home,event_booking,my_events,reels,discover,referral,profile,provider_dashboard}/{data/{models,repositories},domain/{entities,usecases},presentation/{providers,screens,widgets}},shared/{widgets,models,providers}}
```

#### Day 3-4: Firebase Setup
- Create Firebase project
- Add Android and iOS apps
- Configure authentication methods
- Set up Firestore database
- Configure Storage
- Enable Cloud Messaging

#### Day 5-7: Core Setup
**1. Create constants:**

`lib/core/constants/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFFFF0033); // Vibrant red
  static const Color primaryDark = Color(0xFFCC0029);
  static const Color secondary = Color(0xFF6B0DFF); // Deep purple
  
  // Backgrounds
  static const Color background = Color(0xFF0A0A0A); // Almost black
  static const Color surface = Color(0xFF1A1A1A); // Dark gray
  static const Color cardBackground = Color(0xFF252525);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);
  
  // Status colors
  static const Color success = Color(0xFF00D66B);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
  
  // Event type colors
  static const Color wedding = Color(0xFFFF6B9D);
  static const Color birthday = Color(0xFFFFD700);
  static const Color engagement = Color(0xFFFF1493);
  static const Color corporate = Color(0xFF4169E1);
  static const Color brand = Color(0xFF9370DB);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF0033), Color(0xFF6B0DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF252525)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

**2. Create theme:**

`lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
```

**3. Setup Firebase service:**

`lib/core/services/firebase_service.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await _setupMessaging();
  }
  
  static Future<void> _setupMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }
    
    // Get FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
    });
  }
}
```

**4. Main app setup:**

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  runApp(const ProviderScope(child: RapidReelsApp()));
}

class RapidReelsApp extends StatelessWidget {
  const RapidReelsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapid Reels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
```

### Phase 2: Authentication (Week 2)

#### Authentication Implementation

**1. Create User Model:**

`lib/features/auth/data/models/user_model.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String? phoneNumber;
  final String? email;
  final String fullName;
  final String? profileImage;
  final LocationData? currentLocation;
  final List<Address>? savedAddresses;
  final String? referralCode;
  final double walletBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    this.phoneNumber,
    this.email,
    required this.fullName,
    this.profileImage,
    this.currentLocation,
    this.savedAddresses,
    this.referralCode,
    this.walletBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      fullName: data['fullName'] ?? '',
      profileImage: data['profileImage'],
      currentLocation: data['currentLocation'] != null
          ? LocationData.fromMap(data['currentLocation'])
          : null,
      savedAddresses: data['savedAddresses'] != null
          ? (data['savedAddresses'] as List)
              .map((addr) => Address.fromMap(addr))
              .toList()
          : null,
      referralCode: data['referralCode'],
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'fullName': fullName,
      'profileImage': profileImage,
      'currentLocation': currentLocation?.toMap(),
      'savedAddresses': savedAddresses?.map((addr) => addr.toMap()).toList(),
      'referralCode': referralCode,
      'walletBalance': walletBalance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class LocationData {
  final String city;
  final String state;
  final String country;
  final Coordinates coordinates;

  LocationData({
    required this.city,
    required this.state,
    required this.country,
    required this.coordinates,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      coordinates: Coordinates.fromMap(map['coordinates']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'state': state,
      'country': country,
      'coordinates': coordinates.toMap(),
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Address {
  final String addressId;
  final String label;
  final String address;
  final String city;
  final String pincode;
  final Coordinates coordinates;

  Address({
    required this.addressId,
    required this.label,
    required this.address,
    required this.city,
    required this.pincode,
    required this.coordinates,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      addressId: map['addressId'] ?? '',
      label: map['label'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '',
      coordinates: Coordinates.fromMap(map['coordinates']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addressId': addressId,
      'label': label,
      'address': address,
      'city': city,
      'pincode': pincode,
      'coordinates': coordinates.toMap(),
    };
  }
}
```

**2. Authentication Repository:**

`lib/features/auth/data/repositories/auth_repository.dart`:
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Email Authentication
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create or update user profile
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
```

**3. Auth Provider (Riverpod):**

`lib/features/auth/presentation/providers/auth_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  return ref.watch(authRepositoryProvider).getUserProfile(userId);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _authRepository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> verifyPhone(String phoneNumber, Function(String) onCodeSent) async {
    await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = await _authRepository.verifyOTP(
        verificationId: verificationId,
        otp: otp,
      );
      state = AsyncValue.data(credential.user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
```

**4. Phone Login Screen:**

`lib/features/auth/presentation/screens/phone_login_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String phoneNumber = '+91${_phoneController.text}';

    await ref.read(authNotifierProvider.notifier).verifyPhone(
      phoneNumber,
      (verificationId) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Welcome to Flashoot',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your phone number to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Phase 3: Home Screen (Week 3)

**Home Screen Implementation:**

`lib/features/home/presentation/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/location_selector.dart';
import '../widgets/discover_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hi, Siddipet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const LocationSelector(),
                    const SizedBox(height: 16),
                    const Text(
                      'You are just in\nthe right place!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: QuickActionButton(
                        icon: Icons.add,
                        label: 'Book Now',
                        isPrimary: true,
                        onTap: () {
                          // Navigate to booking
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          QuickActionButton(
                            icon: Icons.calendar_today,
                            label: 'Schedule',
                            onTap: () {
                              // Navigate to schedule
                            },
                          ),
                          const SizedBox(height: 12),
                          QuickActionButton(
                            icon: Icons.receipt_long,
                            label: 'My Bookings',
                            onTap: () {
                              // Navigate to bookings
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          QuickActionButton(
                            icon: Icons.account_balance_wallet,
                            label: 'Refer & Earn',
                            onTap: () {
                              // Navigate to referral
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Promotional Carousel
              CarouselSlider(
                items: [
                  _buildPromoBanner(
                    'Your reel\'s ready\nbefore the vibe fades.',
                    'assets/images/promo1.jpg',
                  ),
                  _buildPromoBanner(
                    'Capture memories\nthat last forever.',
                    'assets/images/promo2.jpg',
                  ),
                ],
                options: CarouselOptions(
                  height: 180,
                  viewportFraction: 0.9,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() => _currentBannerIndex = index);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentBannerIndex == index
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Discover Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discover with Vibe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to discover
                      },
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: DiscoverCard(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(String text, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE31E24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Quick Action Button Widget:**

`lib/features/home/presentation/widgets/quick_action_button.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isPrimary ? 140 : 64,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isPrimary ? 32 : 24,
              color: AppColors.textPrimary,
            ),
            if (isPrimary) const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isPrimary ? 16 : 12,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Phase 4: Booking Flow (Week 4-5)

#### Service Category Screen

`lib/features/booking/data/models/service_category_model.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCategory {
  final String categoryId;
  final String name;
  final String description;
  final String icon;
  final String coverImage;
  final bool isActive;
  final int displayOrder;

  ServiceCategory({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.icon,
    required this.coverImage,
    required this.isActive,
    required this.displayOrder,
  });

  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceCategory(
      categoryId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '',
      coverImage: data['coverImage'] ?? '',
      isActive: data['isActive'] ?? true,
      displayOrder: data['displayOrder'] ?? 0,
    );
  }
}
```

#### Service Provider Model

`lib/features/booking/data/models/service_provider_model.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvider {
  final String providerId;
  final String businessName;
  final String ownerName;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final List<String> coverImages;
  final List<String> categories;
  final List<Service> services;
  final ProviderLocation location;
  final List<String> serviceAreas;
  final double rating;
  final int totalReviews;
  final int totalBookings;
  final Map<String, DayAvailability> availability;
  final bool isVerified;
  final bool isActive;

  ServiceProvider({
    required this.providerId,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.coverImages,
    required this.categories,
    required this.services,
    required this.location,
    required this.serviceAreas,
    required this.rating,
    required this.totalReviews,
    required this.totalBookings,
    required this.availability,
    required this.isVerified,
    required this.isActive,
  });

  factory ServiceProvider.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceProvider(
      providerId: doc.id,
      businessName: data['businessName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImage: data['profileImage'] ?? '',
      coverImages: List<String>.from(data['coverImages'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      services: (data['services'] as List?)
              ?.map((s) => Service.fromMap(s))
              .toList() ??
          [],
      location: ProviderLocation.fromMap(data['location']),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      totalBookings: data['totalBookings'] ?? 0,
      availability: (data['availability'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DayAvailability.fromMap(value)),
          ) ??
          {},
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
    );
  }
}

class Service {
  final String serviceId;
  final String name;
  final String description;
  final double price;
  final int duration; // in minutes
  final List<String> images;

  Service({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.images,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      serviceId: map['serviceId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'images': images,
    };
  }
}

class ProviderLocation {
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;

  ProviderLocation({
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  factory ProviderLocation.fromMap(Map<String, dynamic> map) {
    return ProviderLocation(
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: map['coordinates']['latitude'].toDouble(),
      longitude: map['coordinates']['longitude'].toDouble(),
    );
  }
}

class DayAvailability {
  final bool isOpen;
  final List<TimeSlot> slots;

  DayAvailability({required this.isOpen, required this.slots});

  factory DayAvailability.fromMap(Map<String, dynamic> map) {
    return DayAvailability(
      isOpen: map['isOpen'] ?? false,
      slots: (map['slots'] as List?)
              ?.map((s) => TimeSlot.fromMap(s))
              .toList() ??
          [],
    );
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final int slotDuration;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      slotDuration: map['slotDuration'] ?? 60,
    );
  }
}
```

#### Booking Repository

`lib/features/booking/data/repositories/booking_repository.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/service_category_model.dart';
import '../models/service_provider_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all service categories
  Future<List<ServiceCategory>> getCategories() async {
    QuerySnapshot snapshot = await _firestore
        .collection('service_categories')
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .get();

    return snapshot.docs
        .map((doc) => ServiceCategory.fromFirestore(doc))
        .toList();
  }

  // Get service providers by category and location
  Future<List<ServiceProvider>> getProvidersByCategory({
    required String categoryId,
    required String city,
  }) async {
    QuerySnapshot snapshot = await _firestore
        .collection('service_providers')
        .where('categories', arrayContains: categoryId)
        .where('serviceAreas', arrayContains: city)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => ServiceProvider.fromFirestore(doc))
        .toList();
  }

  // Get provider details
  Future<ServiceProvider?> getProviderDetails(String providerId) async {
    DocumentSnapshot doc =
        await _firestore.collection('service_providers').doc(providerId).get();
    if (doc.exists) {
      return ServiceProvider.fromFirestore(doc);
    }
    return null;
  }

  // Create booking
  Future<String> createBooking(BookingModel booking) async {
    DocumentReference docRef =
        await _firestore.collection('bookings').add(booking.toFirestore());
    return docRef.id;
  }

  // Get user bookings
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  // Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Cancel booking
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
```

#### Provider List Screen

`lib/features/booking/presentation/screens/provider_list_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/provider_card.dart';
import '../../data/models/service_provider_model.dart';
import '../providers/booking_provider.dart';

class ProviderListScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const ProviderListScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(providersProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: providersAsync.when(
        data: (providers) {
          if (providers.isEmpty) {
            return const Center(
              child: Text('No providers found in your area'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              return ProviderCard(provider: providers[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
```

### Phase 5: Payment Integration (Week 6)

#### Razorpay Integration

`lib/core/services/payment_service.dart`:
```dart
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class PaymentService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void startPayment({
    required double amount,
    required String orderId,
    required String name,
    required String email,
    required String phone,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
  }) {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;

    var options = {
      'key': 'YOUR_RAZORPAY_KEY_ID',
      'amount': (amount * 100).toInt(), // amount in paise
      'name': 'Flashoot',
      'description': 'Service Booking Payment',
      'order_id': orderId,
      'prefill': {
        'contact': phone,
        'email': email,
      },
      'theme': {
        'color': '#E31E24',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) {
      onFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}
```

#### Payment Screen

`lib/features/booking/presentation/screens/payment_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/payment_service.dart';
import '../../data/models/booking_model.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentService _paymentService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _processPayment() {
    setState(() => _isProcessing = true);

    _paymentService.startPayment(
      amount: widget.booking.amount,
      orderId: widget.booking.bookingId,
      name: 'User Name', // Get from user profile
      email: 'user@email.com', // Get from user profile
      phone: '+919876543210', // Get from user profile
      onSuccess: (response) {
        setState(() => _isProcessing = false);
        // Update booking with payment details
        _handlePaymentSuccess(response);
      },
      onFailure: (response) {
        setState(() => _isProcessing = false);
        _handlePaymentFailure(response);
      },
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Update booking status to confirmed
    // Save payment ID
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          bookingId: widget.booking.bookingId,
          paymentId: response.paymentId ?? '',
        ),
      ),
    );
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Service', widget.booking.serviceName),
                  _buildSummaryRow(
                    'Date',
                    widget.booking.bookingDate.toString(),
                  ),
                  _buildSummaryRow(
                    'Time',
                    '${widget.booking.timeSlot.startTime} - ${widget.booking.timeSlot.endTime}',
                  ),
                  const Divider(height: 32),
                  _buildSummaryRow(
                    'Total Amount',
                    '₹${widget.booking.amount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Pay ₹${widget.booking.amount.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Phase 6: Cloud Functions (Week 7)

#### Setup Cloud Functions

```bash
cd flashoot_app
firebase init functions
```

Choose JavaScript or TypeScript.

#### Create Booking Function

`functions/index.js`:
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification when booking is created
exports.onBookingCreated = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snap, context) => {
    const booking = snap.data();
    const bookingId = context.params.bookingId;

    // Get user's FCM token
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(booking.userId)
      .get();
    
    const fcmToken = userDoc.data().fcmToken;

    if (fcmToken) {
      const message = {
        notification: {
          title: 'Booking Confirmed',
          body: `Your booking for ${booking.serviceName} is confirmed!`,
        },
        data: {
          bookingId: bookingId,
          type: 'booking_created',
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
    }

    // Create notification document
    await admin.firestore().collection('notifications').add({
      userId: booking.userId,
      title: 'Booking Confirmed',
      body: `Your booking for ${booking.serviceName} is confirmed!`,
      type: 'booking',
      data: { bookingId: bookingId },
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return null;
  });

// Process referral when user signs up
exports.processReferral = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data();
    const userId = context.params.userId;

    if (user.referredBy) {
      const referralCode = user.referredBy;
      
      // Find referrer
      const referrerQuery = await admin.firestore()
        .collection('users')
        .where('referralCode', '==', referralCode)
        .limit(1)
        .get();

      if (!referrerQuery.empty) {
        const referrerId = referrerQuery.docs[0].id;
        const rewardAmount = 100; // ₹100 reward

        // Create referral record
        await admin.firestore().collection('referrals').add({
          referrerId: referrerId,
          referredUserId: userId,
          referralCode: referralCode,
          status: 'completed',
          rewardAmount: rewardAmount,
          rewardCredited: true,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Get current wallet balance
        const referrerDoc = await admin.firestore()
          .collection('users')
          .doc(referrerId)
          .get();
        
        const currentBalance = referrerDoc.data().walletBalance || 0;
        const newBalance = currentBalance + rewardAmount;

        // Update wallet balance
        await admin.firestore()
          .collection('users')
          .doc(referrerId)
          .update({
            walletBalance: newBalance,
          });

        // Create wallet transaction
        await admin.firestore().collection('wallet_transactions').add({
          userId: referrerId,
          type: 'credit',
          amount: rewardAmount,
          description: 'Referral bonus',
          referenceType: 'referral',
          referenceId: userId,
          balanceBefore: currentBalance,
          balanceAfter: newBalance,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Send notification
        const fcmToken = referrerDoc.data().fcmToken;
        if (fcmToken) {
          await admin.messaging().send({
            notification: {
              title: 'Referral Bonus!',
              body: `You earned ₹${rewardAmount} for referring a friend!`,
            },
            token: fcmToken,
          });
        }
      }
    }

    return null;
  });

// Create Razorpay order
exports.createRazorpayOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const Razorpay = require('razorpay');
  const razorpay = new Razorpay({
    key_id: functions.config().razorpay.key_id,
    key_secret: functions.config().razorpay.key_secret,
  });

  try {
    const order = await razorpay.orders.create({
      amount: data.amount * 100, // amount in paise
      currency: 'INR',
      receipt: data.bookingId,
    });

    return { orderId: order.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Verify Razorpay payment
exports.verifyRazorpayPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const crypto = require('crypto');
  
  const signature = crypto
    .createHmac('sha256', functions.config().razorpay.key_secret)
    .update(`${data.orderId}|${data.paymentId}`)
    .digest('hex');

  if (signature === data.signature) {
    // Update booking with payment details
    await admin.firestore()
      .collection('bookings')
      .doc(data.bookingId)
      .update({
        paymentId: data.paymentId,
        paymentStatus: 'paid',
        status: 'confirmed',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { verified: true };
  } else {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid signature');
  }
});

// Send booking reminder (scheduled)
exports.sendBookingReminders = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const oneHourLater = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 60 * 60 * 1000
    );

    // Get bookings in next hour
    const bookingsSnapshot = await admin.firestore()
      .collection('bookings')
      .where('bookingDate', '>=', now)
      .where('bookingDate', '<=', oneHourLater)
      .where('status', '==', 'confirmed')
      .get();

    const promises = [];

    bookingsSnapshot.forEach((doc) => {
      const booking = doc.data();
      
      promises.push(
        admin.firestore()
          .collection('users')
          .doc(booking.userId)
          .get()
          .then((userDoc) => {
            const fcmToken = userDoc.data().fcmToken;
            if (fcmToken) {
              return admin.messaging().send({
                notification: {
                  title: 'Booking Reminder',
                  body: `Your booking for ${booking.serviceName} is in 1 hour!`,
                },
                token: fcmToken,
              });
            }
          })
      );
    });

    await Promise.all(promises);
    return null;
  });
```

Deploy functions:
```bash
firebase deploy --only functions
```

### Phase 7: Testing Strategy

#### Unit Tests

`test/unit/models/user_model_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flashoot_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromFirestore creates UserModel correctly', () {
      // Test implementation
    });

    test('toFirestore converts UserModel correctly', () {
      // Test implementation
    });
  });
}
```

#### Widget Tests

`test/widget/login_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashoot_app/features/auth/presentation/screens/phone_login_screen.dart';

void main() {
  testWidgets('PhoneLoginScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PhoneLoginScreen()),
    );

    expect(find.text('Welcome to Flashoot'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
```

#### Integration Tests

`integration_test/booking_flow_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flashoot_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete booking flow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate through booking flow
    await tester.tap(find.text('Book Now'));
    await tester.pumpAndSettle();

    // Continue with test steps
  });
}
```

Run tests:
```bash
flutter test
flutter test integration_test
```

### Phase 8: Deployment (Week 8)

#### Android Release Build

1. **Configure app signing:**

`android/app/build.gradle`:
```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

2. **Build release APK:**
```bash
flutter build apk --release
```

3. **Build App Bundle:**
```bash
flutter build appbundle --release
```

#### iOS Release Build

1. **Update version in `pubspec.yaml`:**
```yaml
version: 1.0.0+1
```

2. **Build iOS archive:**
```bash
flutter build ios --release
```

3. **Open in Xcode and archive:**
```bash
open ios/Runner.xcworkspace
```

#### Play Store Setup

1. Create Google Play Console account
2. Create new application
3. Fill in store listing details
4. Upload app bundle
5. Set up content rating
6. Configure pricing & distribution
7. Submit for review

#### App Store Setup

1. Create App Store Connect account
2. Create new app
3. Fill in app information
4. Upload build from Xcode
5. Submit for review

---

## Performance Optimization

### Image Optimization
- Use `cached_network_image` for network images
- Implement lazy loading for lists
- Use appropriate image formats (WebP)
- Compress images before upload

### Database Optimization
- Use Firestore indexes for complex queries
- Implement pagination for large lists
- Use `limit()` and `orderBy()` efficiently
- Cache frequently accessed data

### Code Optimization
```dart
// Use const constructors
const Text('Hello');

// Avoid rebuilding entire trees
Consumer(
  builder: (context, ref, child) {
    return child!; // Reuse child widget
  },
  child: const ExpensiveWidget(),
);

// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);
```

---

## Security Best Practices

### 1. Secure API Keys
- Never commit API keys to version control
- Use environment variables
- Use Firebase Security Rules

### 2. Input Validation
```dart
class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }
}
```

### 3. Secure Storage
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Store sensitive data
await storage.write(key: 'auth_token', value: token);

// Read sensitive data
String? token = await storage.read(key: 'auth_token');
```

---

## Analytics & Monitoring

### Firebase Analytics

`lib/core/services/analytics_service.dart`:
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logBookingCreated({
    required String serviceId,
    required double amount,
  }) async {
    await _analytics.logEvent(
      name: 'booking_created',
      parameters: {
        'service_id': serviceId,
        'amount': amount,
      },
    );
  }

  Future<void> logPaymentCompleted({
    required String paymentId,
    required double amount,
  }) async {
    await _analytics.logEvent(
      name: 'payment_completed',
      parameters: {
        'payment_id': paymentId,
        'amount': amount,
        'currency': 'INR',
      },
    );
  }
}
```

### Crashlytics

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pass all uncaught errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(MyApp());
}
```

---

## Maintenance & Updates

### Version Management
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Document changes in CHANGELOG.md
- Use Git tags for releases

### Continuous Integration
Use GitHub Actions or similar:

`.github/workflows/flutter.yml`:
```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release
```

---

## Additional Features to Consider

### 1. Social Sharing
```dart
import 'package:share_plus/share_plus.dart';

void shareReferralCode(String code) {
  Share.share(
    'Join Flashoot using my code $code and get ₹100 bonus!',
    subject: 'Join Flashoot',
  );
}
```

### 2. Deep Linking
Configure deep links for:
- Booking details
- Service provider profiles
- Referral links

### 3. Push Notifications
- Booking confirmations
- Booking reminders
- Promotional offers
- Referral rewards

### 4. Offline Support
```dart
import 'package:hive_flutter/hive_flutter.dart';

// Cache data locally
await Hive.initFlutter();
final box = await Hive.openBox('bookings');
await box.put('lastBooking', booking.toMap());
```

### 5. Multi-language Support
```dart
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
    Locale('te', 'IN'),
  ],
);
```

---

## Conclusion

This documentation provides a comprehensive guide to building the Flashoot booking application. The implementation is structured in phases, making it easier to track progress and ensure quality at each stage.

### Development Timeline Summary
- **Week 1**: Project Setup & Firebase Configuration
- **Week 2**: Authentication Module
- **Week 3**: Home Screen & Navigation
- **Week 4-5**: Booking Flow
- **Week 6**: Payment Integration
- **Week 7**: Cloud Functions & Backend Logic
- **Week 8**: Testing, Optimization & Deployment

### Key Considerations
1. Always test on both Android and iOS
2. Follow Material Design and iOS Human Interface Guidelines
3. Implement proper error handling
4. Optimize for performance
5. Ensure security best practices
6. Monitor analytics and crashes
7. Gather user feedback and iterate

### Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Razorpay Documentation](https://razorpay.com/docs/)
- [Material Design Guidelines](https://material.io/design)

---

**Document Version**: 1.0  
**Last Updated**: February 2026  
**Author**: Technical Documentation Team
