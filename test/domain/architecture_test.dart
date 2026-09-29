import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lib/domain', () {
    test('exists and contains Dart files', () {
      final directory = Directory('lib/domain');

      expect(directory.existsSync(), isTrue);
      expect(_dartFilesIn(directory), isNotEmpty);
    });

    test('does not import any Flutter package', () {
      final offenders = [
        for (final file in _dartFilesIn(Directory('lib/domain')))
          if (file.readAsStringSync().contains('package:flutter')) file.path,
      ];

      expect(offenders, isEmpty);
    });
  });
}

List<File> _dartFilesIn(Directory directory) {
  if (!directory.existsSync()) return const [];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}
