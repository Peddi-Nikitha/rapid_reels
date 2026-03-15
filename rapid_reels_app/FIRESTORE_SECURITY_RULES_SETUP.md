# Firestore Security Rules Setup Guide

## 🔴 Error Location

The permission error is occurring at:

**File**: `lib/core/firebase/services/firestore_service.dart`  
**Line**: 37  
**Method**: `setUser()`  
**Called from**: `lib/features/auth/data/repositories/auth_repository.dart` line 192

**Error**: `PERMISSION_DENIED - Missing or insufficient permissions`

## ✅ Solution

I've created Firestore security rules files. You need to deploy them to Firebase.

### Files Created:
1. ✅ `firestore.rules` - Security rules
2. ✅ `firebase.json` - Firebase configuration
3. ✅ `firestore.indexes.json` - Required indexes

## 🚀 Deployment Steps

### Option 1: Using Firebase Console (Recommended for Quick Setup)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `rapidreels-1f937` or `rapidreelnew-de86a`
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents of `firestore.rules`
5. Paste into the rules editor
6. Click **Publish**

### Option 2: Using Firebase CLI

```bash
# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes
```

## 📋 Security Rules Summary

The rules allow:

### Users Collection:
- ✅ Users can read/write their own document
- ✅ Anyone can read public provider profiles
- ✅ Admin can read/write any user

### Bookings Collection:
- ✅ Customers can read/create/update their bookings
- ✅ Providers can read/update bookings assigned to them
- ✅ Admin can read/write any booking

### Reels Collection:
- ✅ Customers can read their reels
- ✅ Providers can create/update reels for their bookings
- ✅ Public reels can be read by anyone
- ✅ Admin can read/write any reel

### Other Collections:
- Similar permissions for reviews, referrals, wallet_transactions, notifications, etc.

## 🔒 Important Notes

1. **Authentication Required**: Most write operations require the user to be authenticated
2. **Ownership Check**: Users can only modify their own data
3. **Admin Access**: Admin users (userType == 'admin') have full access
4. **Public Data**: Some data (public reels, active providers) can be read by anyone

## 🧪 Testing Rules

After deploying, test with:

1. **Create User Profile**: Should work for authenticated users
2. **Read Own Data**: Should work
3. **Read Other User Data**: Should fail (unless public provider)
4. **Update Own Data**: Should work
5. **Update Other User Data**: Should fail

## ⚠️ Development Mode (Temporary)

If you need to test quickly, you can temporarily use these rules (NOT FOR PRODUCTION):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**WARNING**: This allows any authenticated user to read/write everything. Only use for development!

## 📝 Next Steps

1. Deploy the security rules to Firebase
2. Test user creation/login
3. Verify permissions work correctly
4. Adjust rules as needed for your use case

## 🔗 Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)

