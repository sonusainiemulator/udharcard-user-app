import 'package:flutter_test/flutter_test.dart';
import 'package:paysecure/utils/qr_parser_helper.dart';

void main() {
  group('QrParserHelper Tests', () {
    test('extracts raw phone and email strings correctly', () {
      expect(QrParserHelper.extractMerchantIdentifier('9876543210'), equals('9876543210'));
      expect(QrParserHelper.extractMerchantIdentifier('store@udharcard.shop'), equals('store@udharcard.shop'));
    });

    test('extracts merchant from JSON formats', () {
      const json1 = '{"merchant": "sharma_general_store", "id": 42}';
      expect(QrParserHelper.extractMerchantIdentifier(json1), equals('sharma_general_store'));

      const json2 = '{"phone": "9998887776", "name": "Kirana"}';
      expect(QrParserHelper.extractMerchantIdentifier(json2), equals('9998887776'));

      const json3 = '{"merchant_email": "kirana@udharcard.shop"}';
      expect(QrParserHelper.extractMerchantIdentifier(json3), equals('kirana@udharcard.shop'));
    });

    test('extracts pa parameter from UPI URLs', () {
      const upiUrl = 'upi://pay?pa=sharmastore@okhdfcbank&pn=Sharma%20Store&am=150.00';
      expect(QrParserHelper.extractMerchantIdentifier(upiUrl), equals('sharmastore@okhdfcbank'));
    });

    test('extracts query param from HTTP URLs', () {
      const webUrl = 'https://udharcard.shop/pay?merchant=9123456780';
      expect(QrParserHelper.extractMerchantIdentifier(webUrl), equals('9123456780'));

      const pathUrl = 'https://udharcard.shop/store/store_99';
      expect(QrParserHelper.extractMerchantIdentifier(pathUrl), equals('store_99'));
    });

    test('handles empty or whitespace strings', () {
      expect(QrParserHelper.extractMerchantIdentifier(''), equals(''));
      expect(QrParserHelper.extractMerchantIdentifier('   '), equals(''));
    });
  });
}
