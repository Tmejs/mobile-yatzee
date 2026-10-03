import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('installed app labels use the Polish game title', () {
    final androidManifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(androidManifest, contains('android:label="@string/app_name"'));

    final androidStrings = File('android/app/src/main/res/values/strings.xml')
        .readAsStringSync();
    expect(
      androidStrings,
      contains('<string name="app_name">Generał</string>'),
    );

    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();
    expect(
      iosInfo,
      contains('<key>CFBundleDisplayName</key>\n\t<string>Generał</string>'),
    );
  });
}
