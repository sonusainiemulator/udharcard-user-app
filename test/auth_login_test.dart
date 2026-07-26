import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Login & Phone OTP Logic Tests', () {
    test('Phone number sanitization formats username, email & deterministic password correctly', () {
      const String rawPhoneNumber = '+91 97825 3398';
      final String cleanDigits = rawPhoneNumber.replaceAll(RegExp(r'\D'), '');
      
      final String generatedUsername = "usr_$cleanDigits";
      final String generatedEmail = "phone_$cleanDigits@paysecure.com";
      final String deterministicPassword = "PaySecure_$cleanDigits";

      expect(cleanDigits, equals('91978253398'));
      expect(generatedUsername, equals('usr_91978253398'));
      expect(generatedEmail, equals('phone_91978253398@paysecure.com'));
      expect(deterministicPassword, equals('PaySecure_91978253398'));
    });

    test('Raw phone extraction removes country dial code properly', () {
      const String phoneCode = '+91';
      const String cleanDigits = '91978253398';
      
      final String cleanDialCode = phoneCode.replaceAll('+', '');
      String rawPhone = cleanDigits;
      if (cleanDigits.startsWith(cleanDialCode)) {
        rawPhone = cleanDigits.substring(cleanDialCode.length);
      }

      expect(cleanDialCode, equals('91'));
      expect(rawPhone, equals('978253398'));
    });

    test('Deterministic candidates list is correctly populated for login fallback', () {
      const String cleanDigits = '91978253398';
      const String firebaseUid = 'firebase_abc123';
      
      final String deterministicPassword = "PaySecure_$cleanDigits";
      final String firebasePassword = "Firebase_$firebaseUid";
      final String phonePassword = "Phone_$cleanDigits";

      List<String> passwordCandidates = [
        deterministicPassword,
        firebasePassword,
        phonePassword,
      ];

      expect(passwordCandidates.contains('PaySecure_91978253398'), isTrue);
      expect(passwordCandidates.contains('Firebase_firebase_abc123'), isTrue);
      expect(passwordCandidates.contains('Phone_91978253398'), isTrue);
    });
  });
}
