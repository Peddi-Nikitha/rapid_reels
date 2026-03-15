# 🔴 QUICK FIX: Play Integrity Error (17093)

## Error You're Seeing
```
SMS verification code request failed: unknown status code: 17093
This request is missing a valid app identifier, meaning that Play Integrity checks, and reCAPTCHA checks were unsuccessful
```

## ⚡ Immediate Solution: Use Test Phone Numbers

This bypasses Play Integrity completely and works immediately!

### Step 1: Add Test Phone Number in Firebase Console

1. **Go to Firebase Console:**
   - https://console.firebase.google.com/
   - Select your project: **rapidreelnew-de86a**
   - Go to **Authentication** → **Sign-in method** → **Phone**

2. **Add Test Phone Number:**
   - Scroll down to **"Phone numbers for testing"** section
   - Click **Add phone number**
   - **Phone number:** `+918688538590` (your actual number)
   - **Verification code:** `123456` (any 6 digits)
   - Click **Save**

3. **Test in App:**
   - Enter: `+918688538590`
   - Click "Send OTP"
   - Enter: `123456` (the code you set)
   - ✅ **Should work immediately!**

---

## 🔧 Permanent Fix: Enable Play Integrity API

If you want real OTP (not test numbers), you need to enable Play Integrity API:

### Step 1: Enable Play Integrity API in Google Cloud Console

1. **Go to Google Cloud Console:**
   - https://console.cloud.google.com/
   - Select project: **rapidreelnew-de86a** (Project Number: 583858856130)

2. **Enable Play Integrity API:**
   - Go to **APIs & Services** → **Library**
   - Search for **"Play Integrity API"**
   - Click on it
   - Click **Enable** (if not already enabled)

3. **Wait 10-15 minutes** for changes to propagate

### Step 2: Verify SHA-1 Matches

1. **Get your actual SHA-1:**
   ```powershell
   cd android
   .\gradlew signingReport
   ```
   
   Look for the SHA1 value in the output

2. **Compare with Firebase Console:**
   - Go to Firebase Console → Project Settings → Your apps → Android app
   - Check if the SHA-1 matches what you got from `signingReport`
   - If different, add the correct one

### Step 3: Rebuild App

```powershell
cd e:\Projects\Rapid_Reels\rapid_reels_app
flutter clean
flutter pub get
flutter run
```

---

## ✅ Recommended: Use Test Numbers for Now

**For immediate testing, use test phone numbers** - they work instantly and bypass all verification checks!

You can add multiple test numbers for different testers.

---

## 📝 Why This Happens

- **Play Integrity API** is Google's way to verify your app is legitimate
- On real devices, Firebase requires either:
  1. ✅ Play Integrity API enabled + proper app signing
  2. ✅ SHA-1/SHA-256 fingerprints (but Play Integrity still needs to be enabled)
  3. ✅ Test phone numbers (bypasses everything - easiest!)

The error happens because Play Integrity checks are failing, even though SHA-1 is added.

