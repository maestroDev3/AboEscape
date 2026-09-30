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

    test('requests the notification and boot permissions', () {
      final manifest = readManifest();

      expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
      expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    });

    test('declares the receivers for scheduled notifications', () {
      final manifest = readManifest();

      expect(
        manifest,
        contains(
          'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
        ),
      );
      expect(
        manifest,
        contains(
          'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
        ),
      );
    });
  });

  group('app/build.gradle.kts', () {
    test('enables core library desugaring for the notification plugin', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();

      expect(gradle, contains('isCoreLibraryDesugaringEnabled = true'));
      expect(gradle, contains('coreLibraryDesugaring('));
    });
  });
}
