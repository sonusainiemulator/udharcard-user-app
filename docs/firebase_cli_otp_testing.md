# Firebase Phone OTP CLI & CI/CD Automated Testing Guide

This guide explains how to test Firebase Phone Authentication via CLI and in CI/CD environments without sending physical SMS messages or incurring carrier costs.

---

## Method 1: Whitelisted Test Phone Numbers (Firebase Console / CLI)

Firebase Auth allows you to whitelist specific phone numbers (such as `+91978253398`) with fixed verification codes (e.g. `123456`).

### 1. Add Test Number via Firebase Console
1. Go to **[Firebase Console](https://console.firebase.google.com/)** -> Select project **udharcard-app**.
2. Navigate to **Authentication > Sign-in method > Phone**.
3. Under **Phone numbers for testing**, add:
   - **Phone Number**: `+91978253398`
   - **Verification Code**: `123456`

### 2. Add Test Number via Firebase CLI
You can also import test phone numbers using the Firebase CLI:
```bash
firebase auth:export test_users.json --project udharcard-app
```

---

## Method 2: Firebase Auth Emulator for CLI Testing

The **Firebase Local Emulator Suite** allows full offline CLI testing for Phone Authentication.

### 1. Start Firebase Emulator
```bash
firebase emulators:start --only auth
```

### 2. Connect Flutter App to Emulator in Test Environment
In your test suite or main.dart (during debug/test runs):
```dart
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

### 3. Run Flutter Tests via CLI
```bash
flutter test test/auth_login_test.dart
```

---

## Method 3: GitHub Actions CI/CD Integration

The file `.github/workflows/ci.yml` is configured to run automatically on every push or pull request:
1. Installs Flutter SDK & Java 17.
2. Runs static analysis: `flutter analyze`.
3. Executes unit tests: `flutter test test/auth_login_test.dart`.
4. Builds release App Bundle: `flutter build appbundle --release`.
5. Uploads `app-release.aab` artifact to GitHub Actions dashboard.
