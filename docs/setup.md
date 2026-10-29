---
title: Setup
sidebar_position: 2
---

# Setup

## Commands

```bash
flutter pub get
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

## Validation

Run the local validation flow before opening a pull request.

## Connect the app to the backend

The app talks to [`api-back`](https://github.com/Astrea-EIP/api-back) over plain HTTP on port `5217`.
See the `api-back` setup guide for how to start it (`dotnet run`, or `docker compose --profile api up -d --build`).

The base URL is read at build time from `API_BASE_URL` and defaults to the Android emulator alias
(`http://10.0.2.2:5217`):

| Where the app runs | Base URL | Command |
|---|---|---|
| Android emulator | `http://10.0.2.2:5217` | `flutter run` |
| iOS simulator | `http://localhost:5217` | `flutter run --dart-define=API_BASE_URL=http://localhost:5217` |
| Real phone on the same Wi-Fi | `http://<computer IP>:5217` | `flutter run --dart-define=API_BASE_URL=http://192.168.1.42:5217` |

For a real phone, start the API with the `lan` launch profile (`dotnet run --launch-profile lan`) so it
listens on all interfaces, and allow inbound TCP `5217` in the firewall.

Cleartext HTTP is allowed in the Android **debug** and **profile** manifests only
(`android/app/src/{debug,profile}/AndroidManifest.xml`); release builds keep the Android default and
need an HTTPS API.

### What is wired today

| Backend endpoint | Used by |
|---|---|
| `GET /v0/auth/anonymous` | Token pre-fetch when the onboarding profile is submitted, and lazily before the first itinerary call |
| `POST /v0/itinerary` | `HttpItineraryRepository.createItinerary` (no screen uses it yet) |

The backend has no profile endpoint yet: the accessibility profile is kept in memory only and is lost
when the app restarts.

### Troubleshooting

- **`401` on itinerary calls**: tokens live in the API's memory. The client retries once with a fresh
  token; restart the app if it still fails.
- **Connection refused / timeout**: wrong base URL for your device (see the table), API not running, or
  firewall blocking port `5217`.
- **Flutter tests fail to load on Windows** when the user folder contains an apostrophe (for example
  `C:\Users\Em's\...`): the generated test bootstrap breaks on the quote. Map the project to a drive
  letter and run from there: `subst X: "C:\Users\Em's\Documents\EIP\app-mobile"` then `cd X:\` and
  `flutter test`.
