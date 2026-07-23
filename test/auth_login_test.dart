import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Login & Phone OTP Logic Tests', () {
    test('Phone number sanitization formats username and email correctly', () {
      const String rawPhoneNumber = '+91 97825 3398';
      final String cleanDigits = rawPhoneNumber.replaceAll(RegExp(r'\D'), '');
      
      final String generatedUsername = "usr_$cleanDigits";
      final String generatedEmail = "phone_$cleanDigits@paysecure.com";
      const String firebaseUid = "test_uid_123456";
      final String generatedPassword = "Firebase_$firebaseUid";

      expect(cleanDigits, equals('91978253398'));
      expect(generatedUsername, equals('usr_91978253398'));
      expect(generatedEmail, equals('phone_91978253398@paysecure.com'));
      expect(generatedPassword, equals('Firebase_test_uid_123456'));
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

    test('Test phone number +91978253398 verification payload format', () {
      const String testPhoneNumber = '+91978253398';
      expect(testPhoneNumber.startsWith('+91'), isTrue);
      expect(testPhoneNumber.length, equals(12));
    });
  });
}
