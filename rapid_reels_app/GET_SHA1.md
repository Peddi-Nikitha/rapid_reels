# How to Get SHA-1 Fingerprint

## Method 1: Using keytool (if Java is installed)

### For Debug Build:
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### For Release Build:
```powershell
keytool -list -v -keystore "path\to\your\keystore.jks" -alias your-key-alias
```

Look for the line that says:
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

---

## Method 2: Using Android Studio

1. Open Android Studio
2. Open your project
3. Click on **Gradle** tab (right side)
4. Navigate to: `rapid_reels_app` → `Tasks` → `android` → `signingReport`
5. Double-click `signingReport`
6. Look for SHA1 in the output

---

## Method 3: Using Flutter (if configured)

```bash
cd android
flutter build apk --debug
# Then check the build output or use keytool
```

---

## After Getting SHA-1:

1. Go to Firebase Console
2. Project Settings → Your apps → Android app
3. Scroll to "SHA certificate fingerprints"
4. Click "Add fingerprint"
5. Paste your SHA-1
6. Save

**Note:** You can skip this step for now if you want to test first. Firebase will work, but you might see reCAPTCHA warnings in logs.

