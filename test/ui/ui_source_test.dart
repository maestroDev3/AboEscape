import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Colors belong to `theme.dart` only; widgets read them from the theme.
final _hardCodedColor = RegExp(r'Color\(0x|Colors\.|Color\.from');

/// Visible strings must come from `AppLocalizations`, never from literals.
final _hardCodedString = RegExp(
  r'''(Text\(\s*|(tooltip|label|labelText|hintText|title|semanticLabel):\s*)['"]''',
);

void main() {
  group('lib/ui', () {
    final widgetFiles = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('theme.dart'))
        .toList();

    test('widgets contain no hard-coded color values', () {
      final offenders = [
        for (final file in widgetFiles)
          if (_hardCodedColor.hasMatch(file.readAsStringSync())) file.path,
      ];

      expect(offenders, isEmpty);
    });

    test('widgets contain no hard-coded visible strings', () {
      final offenders = [
        for (final file in widgetFiles)
          if (_hardCodedString.hasMatch(file.readAsStringSync())) file.path,
      ];

      expect(offenders, isEmpty);
    });

    test('contains a home screen', () {
      expect(File('lib/ui/home_screen.dart').existsSync(), isTrue);
    });
  });
}
