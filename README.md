# app-mobile

`app-mobile` is the Astrea-EIP mobile application repository.
It owns mobile user journeys, platform integration, and mobile-specific build and test workflows.

## What belongs here

This repository owns:

- mobile UI and navigation
- device-specific integration and permissions
- mobile build and test configuration
- repository-local mobile documentation

This repository does not own:

- backend business logic
- deployment environment state
- organization-wide engineering standards maintained in `docs`

## Local development

Use the Flutter toolchain required by the project.

```bash
flutter pub get
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

## Backend

The app consumes [`api-back`](https://github.com/Astrea-EIP/api-back). The base URL defaults to the
Android emulator alias `http://10.0.2.2:5217` and can be overridden with
`--dart-define=API_BASE_URL=...`. See `docs/setup.md` for the per-device table.

## Documentation

Repository-specific mobile documentation lives under `docs/`.
The shared engineering handbook lives in `Astrea-EIP/docs`.
