# ✅ Enable Play Integrity API - Step by Step

## Your SHA-1 is Correct ✅
- SHA-1: `1F:7E:5C:CC:96:8A:4B:44:EF:01:31:1A:DD:A8:E2:00:95:80:A4:24`
- Already added in Firebase Console ✅

## The Problem
Error 17093 = Play Integrity API is **not enabled** in Google Cloud Console

## Solution: Enable Play Integrity API

### Step 1: Go to Google Cloud Console
1. Open: https://console.cloud.google.com/
2. **Select project:** `rapidreelnew-de86a` (Project Number: 583858856130)
   - If you don't see it, click the project dropdown at the top
   - Search for "rapidreelnew-de86a"

### Step 2: Enable Play Integrity API
1. In the left menu, click **APIs & Services** → **Library**
2. In the search box, type: **"Play Integrity API"**
3. Click on **"Play Integrity API"** (by Google)
4. Click the blue **"ENABLE"** button
5. Wait for it to enable (takes 10-30 seconds)

### Step 3: Verify It's Enabled
1. Go to **APIs & Services** → **Enabled APIs**
2. You should see **"Play Integrity API"** in the list
3. Status should be **"Enabled"**

### Step 4: Wait and Test
1. **Wait 10-15 minutes** for changes to propagate
2. **Rebuild your app:**
   ```powershell
   cd e:\Projects\Rapid_Reels\rapid_reels_app
   flutter clean
   flutter pub get
   flutter run
   ```
3. **Test OTP** - should work now! ✅

---

## ⚡ Quick Alternative: Use Test Phone Numbers

If you want to test **right now** without waiting:

1. **Firebase Console** → **Authentication** → **Sign-in method** → **Phone**
2. Scroll to **"Phone numbers for testing"**
3. Click **Add phone number**
4. Enter: `+918688538590`
5. Enter OTP: `123456`
6. Click **Save**
7. **Test immediately** - works right away! ✅

---

## Why This Happens

- Firebase uses **Play Integrity API** to verify your app is legitimate
- Even with SHA-1 added, the API must be **enabled** in Google Cloud Console
- This is a **one-time setup** - once enabled, it works for all future builds

---

## After Enabling

Once Play Integrity API is enabled:
- ✅ Real phone numbers will work
- ✅ OTP will be sent via SMS
- ✅ No need for test numbers (but you can keep them for testing)

