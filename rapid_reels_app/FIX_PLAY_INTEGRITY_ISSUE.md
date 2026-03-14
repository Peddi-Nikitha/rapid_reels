# Fix Play Integrity API Project Number Mismatch

## Problem
The app is using the wrong Google Cloud project number (`551503664846`) instead of the correct one (`1013661439723`). This causes the "Invalid app info in play_integrity_token" error.

## Solution Steps

### Step 1: Verify Google Cloud Console Project

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Select project: **rapidreels-1f937** (Project Number: 1013661439723)

2. **Enable Play Integrity API:**
   - Go to **APIs & Services** → **Library**
   - Search for "Play Integrity API"
   - Click on it
   - Click **Enable** (if not already enabled)

3. **Verify Project Number:**
   - Go to **APIs & Services** → **Dashboard**
   - Check that the project number is **1013661439723**
   - If you see a different project number, you're in the wrong project

### Step 2: Check Firebase Project Link

1. **In Firebase Console:**
   - Go to: https://console.firebase.google.com/project/rapidreels-1f937/settings/general
   - Scroll to **Project settings** → **General**
   - Verify the **Project number** is: `1013661439723`
   - Verify the **Project ID** is: `rapidreels-1f937`

### Step 3: Clear All Caches and Rebuild

```powershell
# Stop the app completely
# Then run:

cd E:\Projects\Rapid_Reels\rapid_reels_app

# Clean everything
flutter clean
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue

# Clean Android build
cd android
.\gradlew clean
cd ..

# Get dependencies
flutter pub get

# Rebuild
flutter run -d emulator-5554
```

### Step 4: Uninstall App from Emulator

**Before running the app:**
1. On the emulator, go to **Settings** → **Apps**
2. Find **Rapid Reels** (or `com.rapidreel.app`)
3. **Uninstall** it completely
4. Then run `flutter run` again

### Step 5: Wait for Propagation

After enabling Play Integrity API in Google Cloud Console:
- Wait **10-15 minutes** for changes to propagate
- Then test OTP again

## Alternative: Check if Multiple Projects Exist

If you have multiple Firebase/Google Cloud projects:

1. **List all projects:**
   - Firebase Console: https://console.firebase.google.com/
   - Google Cloud Console: https://console.cloud.google.com/

2. **Check which project has the app registered:**
   - Look for `com.rapidreel.app` in each project
   - Make sure SHA certificates are added to the **correct** project

3. **If app exists in wrong project:**
   - Either delete the app from the wrong project
   - Or ensure both projects have the same SHA certificates

## Verification

After fixing, check the logs for:
```
cloudProjectNumber=1013661439723  ✅ (should match your project)
```

Instead of:
```
cloudProjectNumber=551503664846  ❌ (wrong project)
```

