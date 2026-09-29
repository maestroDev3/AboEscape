import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app_en.arb', () {
    test('contains the app title and the empty state text', () {
      final arb = _readTemplateArb();

      expect(arb['appTitle'], 'Abo Escape');
      expect(arb['emptySubscriptions'], 'No subscriptions yet');
    });

    test('has a description for every message', () {
      final arb = _readTemplateArb();

      final missing = arb.keys
          .where((key) => !key.startsWith('@'))
          .where((key) => !_hasDescription(arb['@$key']))
          .toList();

      expect(missing, isEmpty);
    });
  });
}

Map<String, dynamic> _readTemplateArb() =>
    jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;

bool _hasDescription(Object? metadata) => switch (metadata) {
  {'description': final String description} => description.trim().isNotEmpty,
  _ => false,
};
