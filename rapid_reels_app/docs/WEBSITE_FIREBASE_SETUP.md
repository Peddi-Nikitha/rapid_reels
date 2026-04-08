# RapidReels Website + Same Firebase Setup

This guide helps you run and deploy the RapidReels website using the **same Firebase project** as the mobile app.

Current Firebase project in code:
- `projectId`: `rapidreelnew-de86a`
- `messagingSenderId`: `583858856130`

---

## 1) Goal

Use one Firebase backend for:
- Flutter Android app
- Flutter Web app (website)

This means both platforms share:
- Firebase Auth users
- Firestore database
- Firebase Storage files
- Cloud Functions
- Security rules

---

## 2) Prerequisites

Install and verify:
- Flutter SDK
- Firebase CLI (`npm i -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

Login once:

```bash
firebase login
```

---

## 3) Create/Enable Web App in Firebase Console

1. Open Firebase Console for project `rapidreelnew-de86a`.
2. Go to **Project settings**.
3. In **Your apps**, click **Add app** and select **Web (`</>`)**.
4. App nickname example: `rapidreels-web`.
5. Copy the generated web config values.

Important:
- You must get a real `appId` for web.
- The current code uses a placeholder: `1:583858856130:web:YOUR_WEB_APP_ID`.

---

## 4) Update Flutter Web Firebase Options

File:
- `lib/firebase_options.dart`

Update `DefaultFirebaseOptions.web` with the exact web config from Firebase Console:
- `apiKey`
- `appId` (required, real value)
- `messagingSenderId`
- `projectId`
- `authDomain`
- `storageBucket`

After this, web and mobile are connected to the same Firebase project.

---

## 5) Firebase Auth Setup for Website

In Firebase Console:
1. Open **Authentication** -> **Sign-in method**.
2. Enable providers needed for website (Phone, Google, Email/Password, etc.).
3. Open **Settings** -> **Authorized domains**.
4. Add website domains:
   - `localhost` (for local development)
   - your production domain (for example `rapidreels.com`)
   - Firebase Hosting domain (for example `rapidreelnew-de86a.web.app`)

If Google sign-in is used on web, verify OAuth redirect domain is allowed.

---

## 6) Firestore and Storage Rules

Project already has:
- `firestore.rules`
- `storage.rules`
- `firestore.indexes.json`

Deploy rules/indexes when changed:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Because mobile + web share backend, rule changes affect both apps.

---

## 7) Local Website Run

From `rapid_reels_app`:

```bash
flutter pub get
flutter run -d chrome
```

Production build:

```bash
flutter build web --release
```

Output folder:
- `build/web`

---

## 8) Deploy Website to Firebase Hosting

If Hosting is not initialized yet:

```bash
firebase init hosting
```

Recommended answers:
- Use existing project: `rapidreelnew-de86a`
- Public directory: `build/web`
- Single-page app rewrite: `Yes`
- Overwrite `index.html`: `No`

Deploy:

```bash
flutter build web --release
firebase deploy --only hosting
```

Default hosting URL format:
- `https://rapidreelnew-de86a.web.app`

---

## 9) Optional: Use Custom Domain

Firebase Console -> Hosting -> **Add custom domain**.
Then follow DNS verification steps in Firebase.

---

## 10) Environment and Safety Notes

- Do not commit secret server keys in client code.
- Firebase web config is public by design; security must rely on:
  - Firebase Auth
  - Firestore/Storage security rules
  - Cloud Functions validation
- Keep App Check enabled where supported and configured for web when needed.

---

## 11) Quick Verification Checklist

- [ ] Website starts with `flutter run -d chrome`
- [ ] Login works on website
- [ ] Same user account visible in mobile and web
- [ ] Firestore reads/writes succeed on website
- [ ] Storage upload/download works on website
- [ ] Hosting deploy is successful
- [ ] Production domain added in Authorized domains

---

## 12) Troubleshooting

### Error: `No Firebase App '[DEFAULT]' has been created`
- Confirm app initialization runs before Firebase usage.
- Verify `DefaultFirebaseOptions.currentPlatform` is used.

### Error: auth/unauthorized-domain
- Add your domain in Firebase Auth -> Authorized domains.

### Error: Permission denied in Firestore/Storage
- Check Firebase user auth state.
- Check `firestore.rules` / `storage.rules`.

### Error: Web app connects to wrong Firebase project
- Re-check `projectId`, `appId`, `apiKey` in `lib/firebase_options.dart`.
- Confirm no stale build cache:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```
