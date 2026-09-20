import 'package:flutter_test/flutter_test.dart';
import 'package:paysecure/utils/app_constants.dart';

void main() {
  test('App branding and initial configuration smoke test', () {
    expect(AppConstants.appName, equals('Udharcard'));
    expect(AppConstants.baseUrl.contains('udharcard.shop'), isTrue);
  });
}
