# ✅ Enable Play Integrity API on CORRECT Project

## Your Project Details (Confirmed ✅)
- **Project Name:** rapidreelnew
- **Project Number:** 583858856130
- **Project ID:** rapidreelnew-de86a

## The Problem
Play Integrity API is currently enabled on project `551503664846` (wrong), but your Firebase project is `583858856130` (correct).

## Solution: Enable Play Integrity on CORRECT Project

### Step 1: Go to Google Cloud Console
1. Open: https://console.cloud.google.com/
2. **IMPORTANT:** Click the project dropdown at the top
3. **Select:** `rapidreelnew-de86a` (Project Number: 583858856130)
   - Verify the project number shows: **583858856130**
   - If you see a different number, you're in the wrong project!

### Step 2: Enable Play Integrity API
1. In left menu: **APIs & Services** → **Library**
2. Search box: Type **"Play Integrity API"**
3. Click on **"Play Integrity API"** (by Google)
4. Click the blue **"ENABLE"** button
5. Wait for confirmation (10-30 seconds)

### Step 3: Verify It's Enabled
1. Go to **APIs & Services** → **Enabled APIs**
2. You should see **"Play Integrity API"** in the list
3. Status: **"Enabled"** ✅

### Step 4: Clean Build and Test
```powershell
cd e:\Projects\Rapid_Reels\rapid_reels_app

# Clean everything
flutter clean
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Android
cd android
.\gradlew clean
cd ..

# Get dependencies
flutter pub get

# Uninstall app from device first, then:
flutter run
```

### Step 5: Wait 10-15 Minutes
After enabling Play Integrity API, wait for changes to propagate to Google Play Services.

---

## ⚡ IMMEDIATE TEST: Use Test Phone Numbers

**While waiting for Play Integrity to propagate, use test numbers:**

1. **Firebase Console:**
   - https://console.firebase.google.com/project/rapidreelnew-de86a
   - **Authentication** → **Sign-in method** → **Phone**

2. **Add Test Phone Number:**
   - Scroll to **"Phone numbers for testing"**
   - Click **Add phone number**
   - Phone: `+919440665655`
   - Code: `123456`
   - Click **Save**

3. **Test in App:**
   - Enter: `+919440665655`
   - Click "Send OTP"
   - Enter: `123456`
   - ✅ **Works immediately!**

---

## Verify After Fix

After enabling Play Integrity on the correct project and rebuilding, check logs:
```
cloudProjectNumber=583858856130  ✅ (correct!)
```

Instead of:
```
cloudProjectNumber=551503664846  ❌ (wrong)
```

---

## Why This Happens

- Google Play Services caches the project number
- If Play Integrity was enabled on a different project first, it might use that cached value
- Enabling it on the correct project and rebuilding fixes the cache

