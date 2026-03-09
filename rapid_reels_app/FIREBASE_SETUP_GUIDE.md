# Firebase Setup Guide for Rapid Reels

This guide will help you set up Firebase for the Rapid Reels app.

## Prerequisites
- Google account
- Flutter project created
- Firebase CLI installed (`npm install -g firebase-tools`)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: **rapid-reels-app**
4. Enable Google Analytics (recommended)
5. Click "Create Project"

## Step 2: Add Android App

1. In Firebase Console, click on Android icon
2. Register app with details:
   - **Package name**: `com.rapidreels.app`
   - **App nickname**: Rapid Reels Android
   - **Debug signing certificate SHA-1**: (Optional for now, required for Google Sign-In)

3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

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

## Step 3: Add iOS App

1. In Firebase Console, click on iOS icon
2. Register app with details:
   - **Bundle ID**: `com.rapidreels.app`
   - **App nickname**: Rapid Reels iOS

3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` directory in Xcode
5. Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

6. Run: `cd ios && pod install && cd ..`

## Step 4: Enable Firebase Services

### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable:
   - ✅ **Phone** (with reCAPTCHA verification)
   - ✅ **Email/Password**
   - ✅ **Google**
   - ⚪ **Facebook** (requires App ID and Secret from Facebook Developers)

### Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Select **Production mode**
4. Choose location: **asia-south1** (Mumbai, India)
5. Click "Enable"

### Storage
1. Go to **Storage**
2. Click "Get started"
3. Select **Production mode**
4. Click "Done"

### Cloud Messaging
1. Go to **Cloud Messaging**
2. Configuration is automatic for Android
3. For iOS, upload APNs certificate (can be done later)

### Analytics
1. Go to **Analytics**
2. Already enabled if you chose it during project creation
3. No additional configuration needed

### Crashlytics
1. Go to **Crashlytics**
2. Click "Enable Crashlytics"
3. Follow the setup instructions

## Step 5: Configure Security Rules

### Firestore Security Rules

Go to **Firestore Database** → **Rules** and paste:

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

### Storage Security Rules

Go to **Storage** → **Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Helper function
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // User profile images
    match /users/{userId}/profile/{fileName} {
      allow read: if true;
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // Provider portfolio images/videos
    match /providers/{providerId}/portfolio/{fileName} {
      allow read: if true;
      allow write: if isAuthenticated() && request.auth.uid == providerId;
    }
    
    // Event footage (raw)
    match /events/{eventId}/raw/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated(); // Provider or customer upload
    }
    
    // Reels (final videos)
    match /reels/{reelId}/{fileName} {
      allow read: if true; // Can be shared publicly
      allow write: if isAuthenticated();
    }
  }
}
```

## Step 6: Initialize Firebase in Your App

The app is already configured to initialize Firebase in `lib/main.dart` and `lib/core/services/firebase_service.dart`.

## Step 7: Test the Connection

Run your app:
```bash
flutter run
```

Check the console for "Firebase initialized successfully" message.

## Step 8: Set Up Cloud Functions (Optional, for later)

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize functions:
```bash
firebase init functions
```
4. Choose JavaScript or TypeScript
5. Functions code will be in the `functions/` directory

## Troubleshooting

### Android Issues
- If build fails, check that `google-services.json` is in `android/app/`
- Ensure `apply plugin: 'com.google.gms.google-services'` is at the bottom of `android/app/build.gradle`
- Run `flutter clean` and rebuild

### iOS Issues
- Make sure `GoogleService-Info.plist` is added via Xcode (not just copied)
- Run `cd ios && pod install` to update pods
- Clean build folder in Xcode (Cmd+Shift+K)

### Firebase Connection Issues
- Check your internet connection
- Verify that Firebase project has the correct package name/bundle ID
- Check that all required Firebase services are enabled in console

## Next Steps

After Firebase is set up:
1. ✅ Authentication is ready to use
2. ✅ Firestore database is ready
3. ✅ Storage is ready for media uploads
4. ✅ Cloud Messaging is configured
5. ⏳ Continue with authentication module implementation

---

**Note**: Keep your `google-services.json` and `GoogleService-Info.plist` files secure and never commit them to public repositories.

