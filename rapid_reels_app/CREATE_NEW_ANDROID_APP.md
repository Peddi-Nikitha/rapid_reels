# Create New Android App in Firebase - Step by Step

## Step 1: Create the Android App

1. **In Firebase Console:**
   - Click **Add app** → **Android** (or the Android icon)

2. **Register the app:**
   - **Android package name**: `com.rapidreels.app`
   - **App nickname** (optional): `Rapid Reels App` or leave default
   - Click **Register app**

3. **Download config file:**
   - Click **Download google-services.json**
   - **Save it** - we'll replace the existing one

---

## Step 2: Add SHA Fingerprints

1. **Scroll to "Add a SHA certificate fingerprint"**
   - Or go to **Project Settings** → **Your apps** → **Android app**

2. **Add SHA-1:**
   - Click **Add fingerprint**
   - Paste: `1F:7E:5C:CC:96:8A:4B:44:EF:01:31:1A:DD:A8:E2:00:95:80:A4:24`
   - Click **Save**

3. **Add SHA-256:**
   - Click **Add fingerprint** again
   - Paste: `85:47:C4:31:0C:F4:F5:BB:35:5A:44:02:0A:C5:69:0A:61:69:33:0A:F0:B3:92:3F:B0:AE:C9:14:91:C5:C7:91`
   - Click **Save**

---

## Step 3: Replace google-services.json

1. **Copy the downloaded `google-services.json`**
2. **Replace** `android/app/google-services.json` with the new file
3. **Verify** it has the correct project number: `1013661439723`

---

## Step 4: Clean and Rebuild

```bash
cd E:\Projects\Rapid_Reels\rapid_reels_app

# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Rebuild and run
flutter run
```

---

## Step 5: Verify It Works

After the app launches:

1. **Check logs** - Look for:
   ```
   cloudProjectNumber=1013661439723  ✅ (should be new project, not old)
   ```

2. **Test OTP:**
   - Enter phone number
   - Click "Send OTP"
   - Should work now! ✅

---

## Important Notes

- The **package name stays the same**: `com.rapidreels.app`
- The **new app will have a different App ID** (that's fine)
- This creates a **fresh association** with the new Firebase project
- Play Integrity should now use the correct project number

---

## If You See Errors

- **"Package name already exists"** - Wait a few minutes, Firebase might still be processing the deletion
- **Still seeing old project number** - Wipe emulator completely (see FIX_EXISTING_APP.md)
- **OTP still fails** - Verify Phone Authentication is enabled in Firebase Console

---

**After creating the new app and adding SHA fingerprints, let me know and I'll help you replace the google-services.json file!**

