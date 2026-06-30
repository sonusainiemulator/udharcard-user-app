# Changelog

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
