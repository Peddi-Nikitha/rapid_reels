# 🔴 FIX: Wrong Project Number (551503664846)

## The Problem
```
cloudProjectNumber=551503664846  ❌ (WRONG!)
```
Your app is using project `551503664846` but your Firebase project is `583858856130`.

## Root Cause
Play Integrity API is enabled on the **wrong Google Cloud project** (`551503664846`), not your current Firebase project (`rapidreelnew-de86a` / `583858856130`).

## Solution: Enable Play Integrity on CORRECT Project

### Step 1: Go to Google Cloud Console
1. Open: https://console.cloud.google.com/
2. **Select the CORRECT project:** `rapidreelnew-de86a`
   - Project Number should be: **583858856130**
   - If you don't see it, click project dropdown → search "rapidreelnew-de86a"

### Step 2: Enable Play Integrity API
1. Go to **APIs & Services** → **Library**
2. Search: **"Play Integrity API"**
3. Click on it
4. Click **ENABLE**
5. Wait for confirmation

### Step 3: Verify Project Number
1. Go to **APIs & Services** → **Dashboard**
2. Check **Project number** is: `583858856130` ✅
3. If you see `551503664846`, you're in the wrong project!

### Step 4: Clean Build Completely
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

# Uninstall old app from device
# Then rebuild
flutter run
```

### Step 5: Wait 10-15 Minutes
After enabling Play Integrity API, wait for changes to propagate.

---

## ⚡ IMMEDIATE WORKAROUND: Use Test Phone Numbers

**This works RIGHT NOW without waiting:**

1. **Firebase Console** → **Authentication** → **Sign-in method** → **Phone**
2. Scroll to **"Phone numbers for testing"**
3. Click **Add phone number**
4. Enter: `+919440665655` (your number)
5. Enter OTP: `123456`
6. Click **Save**
7. **Test immediately** - works right away! ✅

Test numbers bypass Play Integrity completely.

---

## Verify After Fix

After enabling Play Integrity on the correct project, check logs for:
```
cloudProjectNumber=583858856130  ✅ (correct project)
```

Instead of:
```
cloudProjectNumber=551503664846  ❌ (wrong project)
```

