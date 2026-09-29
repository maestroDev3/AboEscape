import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('main AndroidManifest.xml', () {
    String readManifest() =>
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    test('labels the app "Abo Escape"', () {
      expect(readManifest(), contains('android:label="Abo Escape"'));
    });

    test('does not request the INTERNET permission', () {
      expect(readManifest(), isNot(contains('android.permission.INTERNET')));
    });
  });
}
