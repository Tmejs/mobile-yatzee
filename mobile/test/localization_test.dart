import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_yatzee/src/localization/app_strings.dart';

void main() {
  test('Polish home title resolves from a stable key', () {
    expect(AppStrings.polish(AppStringKey.homeTitle), 'Generał');
  });
}
