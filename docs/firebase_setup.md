# Firebase Setup

This project already includes Firebase SDK dependencies and a cloud sync layer.
Complete the steps below to enable Firebase in your environment.

## 1) Install prerequisites

- Install Git and ensure `git` is in your terminal PATH.
- Install Firebase CLI:
  - `npm install -g firebase-tools`
- Login:
  - `firebase login`

## 2) Install FlutterFire CLI

Use your Flutter SDK bundled Dart:

```powershell
& "C:\Users\Gary\Desktop\Marvis\flutter\bin\dart.bat" pub global activate flutterfire_cli
```

Add pub cache bin to PATH for current terminal:

```powershell
$env:PATH += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
```

## 3) Configure this app

From repo root:

```powershell
flutterfire configure --project <your-firebase-project-id> --platforms=android,ios,web
```

This command generates:

- `lib/firebase_options.dart`
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## 4) Deploy Firestore rules

Rules file is already created: `firestore.rules`

Deploy:

```powershell
firebase deploy --only firestore:rules
```

## 5) Verify in app

- Launch app and complete one lesson.
- Confirm a document appears at:
  - `users/<uid>/app/progress`

## Notes

- App falls back to local persistence when Firebase is not configured.
- Cloud sync uses anonymous auth for MVP.
