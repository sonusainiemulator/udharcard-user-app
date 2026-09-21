import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/utils/merchant_status_helper.dart';

void main() {
  group('MerchantStatusHelper Tests', () {
    test('parseTimeToMinutes correctly parses 12h and 24h formats', () {
      expect(MerchantStatusHelper.parseTimeToMinutes('09:00 AM'), 540);
      expect(MerchantStatusHelper.parseTimeToMinutes('9:30 AM'), 570);
      expect(MerchantStatusHelper.parseTimeToMinutes('01:00 PM'), 780);
      expect(MerchantStatusHelper.parseTimeToMinutes('09:30 PM'), 1290);
      expect(MerchantStatusHelper.parseTimeToMinutes('21:30'), 1290);
      expect(MerchantStatusHelper.parseTimeToMinutes(''), null);
      expect(MerchantStatusHelper.parseTimeToMinutes(null), null);
    });

    test('getStatus returns offline when is_shop_online is 0 or false', () {
      final status1 = MerchantStatusHelper.getStatus({
        'is_shop_online': '0',
        'shop_opening_time': '09:00 AM',
        'shop_closing_time': '09:30 PM',
      });
      expect(status1.isOpen, false);
      expect(status1.statusBadgeText, 'CLOSED');

      final status2 = MerchantStatusHelper.getStatus({
        'is_shop_online': false,
      });
      expect(status2.isOpen, false);
      expect(status2.statusBadgeText, 'CLOSED');
    });

    test('getStatus returns CLOSED TODAY when today matches shop_closed_days', () {
      final today = DateFormat('EEEE').format(DateTime.now());
      final status = MerchantStatusHelper.getStatus({
        'is_shop_online': '1',
        'shop_closed_days': today,
      });
      expect(status.isOpen, false);
      expect(status.statusBadgeText, 'CLOSED TODAY');
    });

    test('getStatus handles null or empty data gracefully', () {
      final status = MerchantStatusHelper.getStatus(null);
      expect(status.isOpen, true);
      expect(status.statusBadgeText, 'OPEN NOW');
    });
  });
}
