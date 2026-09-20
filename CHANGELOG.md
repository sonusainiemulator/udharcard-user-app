# Changelog

## [2.2.0+15] - 2026-09-21 01:18:00 IST

### Added & Fixed
- **Firebase Phone Auth reCAPTCHA URL Scheme**: Added `CFBundleURLTypes` with `app-1-91651925903-ios-0bead75cde4bab14db8dfa` to `ios/Runner/Info.plist` for Firebase phone authentication reCAPTCHA redirect on iOS.
- **App Store Privacy Purpose Strings**: Added `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` to `Info.plist` required by Apple for Gemini AI Voice Mode and Speech-to-Text APIs.
- **App Store Export Compliance**: Added `ITSAppUsesNonExemptEncryption` set to `false` in `Info.plist` for instant TestFlight processing without manual compliance forms.
- **Flutter SDK Modernization**: Upgraded Flutter SDK to `v3.47.5` (Dart `3.13.4`), modernized outdated packages (`file_picker: ^13.1.0`, `firebase_core: ^4.15.0`, `firebase_auth: ^6.7.0`, `dio: ^5.11.1`), and resolved all deprecation warnings (`withValues`, `RadioGroup`, `activeThumbColor`).
- **Binary Releases**: Built and published `app-debug.apk` directly to GitHub Releases.
- **Build Increment**: Bumped build number to 15 (`2.2.0+15`) for TestFlight re-upload and GitHub Release.

## [2.2.0+14] - 2026-09-20 19:25:00 IST

### Upgraded
- **Flutter SDK Support**: Upgraded Flutter SDK to the latest stable release (`v3.47.5`, Dart `3.13.4`).
- **Flutter Environment Constraint**: Configured `pubspec.yaml` environment to `sdk: '>=3.7.2 <5.0.0'` and `flutter: '>=3.47.0'`.
- **Dependencies Modernization**: Upgraded outdated dependencies to latest compatible versions (`file_picker: ^13.1.0`, `dio: ^5.11.1`, `firebase_core: ^4.15.0`, `firebase_auth: ^6.7.0`, `lottie: ^3.6.1`, `mobile_scanner: ^7.4.2`, `flutter_local_notifications: ^22.3.1`, `speech_to_text: ^7.5.0`, `razorpay_flutter: ^1.4.6`, `logger: ^2.8.0`, `emoji_picker_flutter: ^4.5.4`, `connectivity_plus: ^7.3.1`).
- **FilePicker 13 Integration**: Modernized file picker handling in `support_ticket_controller.dart` to match `file_picker 13`'s `Future<List<PlatformFile>>` API.

### Fixed & Cleaned
- **Deprecations Removed**: Replaced deprecated `.withOpacity()` calls with modern `.withValues(alpha:)`.
- **Controls Deprecations**: Migrated `Radio` widgets to `RadioGroup` and replaced `Switch.activeColor` with `activeThumbColor`.
- **iOS AppDelegate**: Modernized `AppDelegate.swift` by removing redundant iOS 10 check and configuring notification delegates directly.
- **Clean Verification**: All static analysis warnings resolved (`flutter analyze` shows 0 issues) and all unit tests verified (`flutter test` passes 6/6).

## [2.1.8+13] - 2026-09-19

### Added
- **60-Second Resend OTP Timer**: Integrated a real-time 60-second countdown timer for both Login and Registration screens with automatic button enablement upon expiry and Firebase Auth `forceResendingToken` resend support.
- **Pinput with SMS Auto-Fill & Reading**: Added `pinput: ^6.0.2` and `smart_auth: ^3.2.0` with `SmsRetrieverImpl` using Android SMS User Consent API and iOS One-Time-Code autofill hints for seamless 6-digit OTP autofill and instant submission.
- **Premium Success Notification**: Added `Helpers.showSuccessSnackBar` featuring emerald teal gradient, animated icons, and subtle elevation to replace any incorrect red header alerts upon OTP dispatch.
- **Unit Tests**: Added test cases for OTP countdown formatting, digit sanitization, and 6-digit validation in `test/auth_login_test.dart`.

### Fixed
- **Sent OTP Header Alert**: Fixed incorrect red alert being displayed when an OTP is dispatched; now shows a reassuring, elegant confirmation banner.
- **Widget Test**: Fixed boilerplate counter smoke test in `test/widget_test.dart` to validate Udharcard app branding and configuration.

## [2.1.7+12] - 2026-07-28

### Added
- **Gemini AI Voice Mode**: Integrated `google_generative_ai` (`gemini-1.5-flash`), `speech_to_text`, and `flutter_tts` for hands-free voice commands with Hindi audio responses (`lib/services/ai_service.dart`, `lib/services/voice_service.dart`, `lib/views/screens/voice_mode/voice_mode_screen.dart`).
- **Lottie Onboarding Screen**: Added Lottie animation onboarding step for Voice Mode (`onbording_screen.dart`, `onbording_data.dart`).
- **Coming Soon Placeholder**: Added `ComingSoonScreen` UI for upcoming features.
- **GitOps Agent Framework**: Added `.agents/AGENTS.md`, `.github/AGENTS.md`, and `AGENTS.md` specifying GitOps guidelines, commit rules, and automatic changelog maintenance.
- **GitHub Release & Debug APK Workflow**: Created `.github/workflows/release.yml` to automatically build Debug APK (`app-debug.apk`), Release APK (`app-release.apk`), and App Bundle (`app-release.aab`) and publish them directly to GitHub Releases.

### Changed
- **Rebranding**: Complete rebranding from PaySecure to **Udharcard** across Android, iOS, Web, Windows, and Linux.

## [2.1.6+10] - 2026-07-23

### Changed
- **Version Code**: Bumped build number to 10 (`2.1.6+10`) for Google Play Store upload.

### Added
- **Unit Test Suite**: Added `test/auth_login_test.dart` for AuthController, phone number sanitization, dial code handling, and verification payloads.
- **CI/CD Workflow**: Added GitHub Actions pipeline (`.github/workflows/ci.yml`) to automatically run static analysis, execute test suites, and build the release Android App Bundle (`app-release.aab`).
- **Firebase CLI OTP Testing Guide**: Added `docs/firebase_cli_otp_testing.md` for Firebase Auth Emulator and CLI automated testing workflows.

## [2.1.6+9] - 2026-07-22

### Changed
- **Version Bump**: Increment version code to 9 (`versionCode 9`, `2.1.6+9`) for Google Play Console compatibility.

## [2.1.5+8] - 2026-07-22

### Fixed
- **Bottom Navigation Bar Safe Area**: Fixed bottom menu tab rendering and clipping issues across all device screen aspect ratios by integrating `SafeArea` wrapping on the main bottom navigation screen.

## [2.1.4+7] - 2026-07-21

### Added
- Added dynamic color-coded balance to the Udharcard Passbook (Green for positive/advance balance, Red for negative/owing balance).
- Redesigned the Virtual Card component on the home screen to act as an "Udharcard Passbook" portal.
- Added walkthrough text instructing users to tap the passbook to view their merchant-wise assigned virtual cards list.

### Changed
- Simplified the bottom navigation bar to statically display 4 core screens for Udharcard Customers.
- Temporarily disabled the "Request Virtual Card" feature from the Virtual Card Screen and added a "Coming Soon" label.

### Removed
- Removed the "Recent Activity" and QR Code features from the Home Screen for a more lightweight experience.
- Removed the "You will get" and "You will give" statistics cards from the bottom of the home screen.
- Removed the unused `_ChipPainter` to clean up the codebase.

### Fixed
- Fixed a race condition bug where navigating to the Virtual Card Request Form happened before the form data was fully fetched from the backend.

## [2.1.3+6] - 2026-07-19

### Added
- **Firebase Phone Authentication**: Replaced username/password login with mobile OTP verification using Firebase Auth. Users can log in and register using their phone number with a 6-digit OTP.
- **Persistent Login Session**: Removed session timeout logic (`SessionTimeoutManager`) — users stay logged in indefinitely after first authentication.
- **Hindi Audio Notification (Planned)**: Infrastructure added for Hindi TTS audio alerts on Udhar credit/debit notifications with user-controlled enable/disable and Male/Female voice selection.

### Fixed
- **Post-Login ANR Freeze**: Resolved "Udharcard isn't responding" freeze after login. Moved all heavy initializations (Pusher connect, Profile API, Dashboard API) out of the synchronous UI thread into `addPostFrameCallback` with staggered `Future.microtask` + `Future.delayed` sequencing.
- **Home Screen Performance**: Moved `Get.put(TransactionController())` and `Get.delete<CardController>()` from `build()` into `initState()` to prevent redundant re-initialization on every widget rebuild.
- **Notification Controller Import**: Fixed broken relative import path for `CustomerUdharController` in `notification_controller.dart`.

### Changed
- **Gradle**: Upgraded from `8.10.2` → `8.14.1`
- **Android Gradle Plugin (AGP)**: Upgraded from `8.6.0` → `8.11.1`
- **Kotlin**: Upgraded from `2.0.20` → `2.2.0`
- **google-services**: Upgraded from `4.4.2` → `4.4.3`
- **targetSdkVersion**: Bumped from `35` → `36`
- **desugar_jdk_libs**: Upgraded from `2.1.4` → `2.1.5`
- **androidx.window**: Upgraded from `1.0.0` → `1.3.0`
- **108 Flutter/Dart packages upgraded** to latest compatible versions including:
  - `flutter_tts` 3.8.3 → 4.2.5
  - `flutter_stripe` 11.5.0 → 13.1.0
  - `stripe_android` override 11.0.0 → 13.1.0
  - `connectivity_plus` 5.0.2 → 7.3.0
  - `flutter_local_notifications` 19.4.0 → 22.1.0
  - `pusher_channels_flutter` 2.2.0 → 2.6.0
  - `get` 4.7.2 → 4.7.3
  - `http` 1.4.0 → 1.6.0
  - `dio` 5.8.0+1 → 5.10.0
  - `webview_flutter` 4.13.0 → 4.14.1
  - `mobile_scanner` 7.0.1 → 7.3.0
  - `package_info_plus` 8.3.0 → 10.2.1
  - `image_picker` 1.1.2 → 1.2.3
  - `razorpay_flutter` 1.4.0 → 1.4.5
  - `open_file` 3.5.10 → 4.0.0
  - `lottie` 3.3.1 → 3.5.1
  - `intl` 0.20.2 → 0.20.3
  - `flutter_lints` 2.0.0 → 5.0.0

### Removed
- `local_session_timeout` package removed (no longer needed — persistent login enabled).



## [2.1.2+5] - 2026-07-11

### Added
- Added merchant-wise Udhar cards.
- Added ledger transaction history.

## [2.1.1+4] - 2026-06-30

### Added
- Added Profile, Support Tickets, and Notifications menu items to the left sidebar (drawer).
- Enabled 16KB memory page size support for Android 15 compatibility.

### Changed
- Updated NDK version to 28.0.13004108 to ensure 16KB page alignment.
- Disabled `useLegacyPackaging` for JNI libraries in Android app `build.gradle` to allow proper uncompressed library alignment.
- Updated Android Gradle Plugin (AGP) version to 8.6.0 in `android/settings.gradle`.
- Upgraded Gradle wrapper to 8.10.2.
- Updated Kotlin version to 2.0.20 to meet Flutter's minimum requirements.
