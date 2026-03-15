# 🔴 QUICK FIX: Firestore Permission Error

## Problem
You're seeing "Failed to create profile" error because Firestore security rules are blocking the write operation.

## ⚡ Quick Solution (2 minutes)

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **rapidreels-1f937** or **rapidreelnew-de86a**

### Step 2: Deploy Security Rules
1. Click on **Firestore Database** in the left menu
2. Click on the **Rules** tab
3. **Copy and paste** the following rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

4. Click **Publish** button

### Step 3: Test Again
- Go back to your app
- Try creating the profile again
- It should work now! ✅

## 📋 What These Rules Do

- **Users can read/write their own user document** (when authenticated)
- **All authenticated users can read/write other collections** (for development)

## ⚠️ Important Notes

1. **These are development rules** - They allow any authenticated user to access most collections
2. **For production**, use the full security rules from `firestore.rules` file
3. **The rules take effect immediately** after publishing

## 🔍 Verify It Worked

After deploying:
1. Try creating a profile again
2. Check Firebase Console → Firestore Database → Data tab
3. You should see a new document in the `users` collection

## 🚨 If Still Not Working

1. **Check Authentication**: Make sure user is logged in
   - Check if `currentUserProvider` returns a valid user
   - User ID should match the document ID

2. **Check Firebase Project**: Make sure you're using the correct project
   - Check `firebase_options.dart` for project ID
   - Verify `google-services.json` matches the project

3. **Check Rules Deployment**: 
   - Go to Firestore → Rules tab
   - Verify the rules are published (not just saved as draft)

4. **Check Error Logs**:
   - Look at Android Studio Logcat
   - Search for "PERMISSION_DENIED" to see exact error

## 📝 Full Security Rules

For production, use the comprehensive rules from `firestore.rules` file which includes:
- Proper user ownership checks
- Provider access rules
- Booking permissions
- Admin access
- And more...

## 🎯 Next Steps

1. ✅ Deploy the quick rules above (for immediate fix)
2. ✅ Test profile creation
3. ✅ Later: Deploy full security rules from `firestore.rules` for production

