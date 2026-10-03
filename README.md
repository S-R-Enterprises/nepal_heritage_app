# Nepal Heritage

A Flutter app for exploring Nepal's heritage sites, festivals, hidden gems and
local guides — temples and UNESCO sites, a cultural event calendar, community
gem submissions, ticket booking with a QR wallet, and a heritage assistant
chat.

The app runs entirely against in-repo mock data today; the API layer
(`AuthService` and friends) keeps production-shaped interfaces so swapping in
the real backend is a local change.

## Features

- **Heritage sites** — detail screens with About/Photos/Reviews tabs and
  ticket booking → QR wallet
- **Hidden gems** — filterable community feed (category + near-me filters),
  gem detail with map and submitter card, and a submit-for-verification flow
- **Festivals** — list/month calendar, festival detail with forecast, stays
  and offers
- **Guides** — profiles with booking form and confirmation summary
- **Auth** — register, login (email or phone), password reset, onboarding
- **Chat** — rule-based heritage assistant (mock)
- **Display languages** — English, Nepali, Hindi, Chinese, French, Spanish,
  German, Japanese, Korean, Arabic (framework chrome localises; app copy is
  English-only for now)

## Getting started

Prerequisites: [Flutter](https://docs.flutter.dev/get-started/install) (stable,
Dart ≥ 3.13).

```sh
flutter pub get
flutter run            # any connected device, or -d chrome for web
```

Auth is mocked locally — sign in with any identifier and a password of at
least 6 characters (the demo account `visitor@nepalheritage.app` skips
registration; `AuthService.demoPassword` is a test fixture, not a
credential).

## Quality gates

```sh
flutter analyze        # zero issues expected
flutter test           # full suite
flutter build web --release
```

CI (`.github/workflows/ci.yml`) runs analyze, tests with coverage, a web
release build and a gitleaks secret scan on every push and pull request.

## Project layout

```
lib/
  app.dart            Root widget: router, locale, screen switch
  navigation/         AppRouter (push/pop stack with payloads), locale scope
  screens/            One file per screen (~18 screens)
  widgets/            Shared cards, pills, buttons, sheets, network photos
  data/               Mock data, models, auth service, chat service
  theme/              Colours, type scale, radii, shadows
test/                 Widget/unit tests + shared helpers
```

## Status

Client prototype with mock data. Not yet: real API, payments
(eSewa/Khalti), Android release build in CI (needs Android SDK), and full
string translation.
