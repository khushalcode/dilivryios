# Talabego Delivery (Driver App)

Flutter driver-side app for the Talabego multi-vendor delivery platform.

## Getting Started

- Flutter SDK: 3.35.6 (stable channel)
- Dart SDK: `>=3.2.0 <4.0.0`

## Configuration

- API base URL: `https://admin.talabego.com` (see `lib/util/app_constants.dart`)
- iOS bundle identifier: `com.talabego.delivery`
- Android application ID: `com.talabego.delivery`
- Firebase project: `talabego`
- Apple Development Team: `GYY8K392ZW` (Ahmed Ghozlane)

## Build

```bash
flutter clean
flutter pub get
dart run flutter_launcher_icons

# iOS
cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ..
flutter build ios --release --no-codesign

# Android
flutter build apk --release
```

## App Store / TestFlight demo account

When submitting to App Store Connect, use the demo account in the format
`+<country_code><phone>` (e.g. `+8434207055` for Vietnam) so the reviewer
selects the matching country code on the sign-in screen.
