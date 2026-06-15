# Mahjong Master New

This is a fully independent Flutter app scaffold created beside the existing `mahjong_app`.

## Goal

- Keep the old app untouched.
- Build a brand-new app around the rebuilt 36-lesson curriculum.

## Current Status

- New project files created in `mahjong_master_new/`.
- Curriculum data included at `lib/models/curriculum_data.dart`.
- Minimal app shell at `lib/main.dart` showing stage and lesson counts.

## Run

From this folder:

```bash
flutter pub get
flutter run
```

## One-click Web Launch (Windows)

Double-click `start_web.bat` in this folder.

It will:

- run `flutter pub get`
- start web server on `http://127.0.0.1:8090`
- open your browser automatically

Keep the terminal window open while testing. Closing it will stop the web app.
