import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/subscription_category.dart';
import 'package:abo_escape/l10n/app_localizations.dart';
import 'package:abo_escape/ui/labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

/// Pumps an empty screen and returns its localizations.
Future<AppLocalizations> _localizations(WidgetTester tester) async {
  late AppLocalizations localizations;
  await tester.pumpApp(
    Builder(
      builder: (context) {
        localizations = AppLocalizations.of(context);
        return const SizedBox.shrink();
      },
    ),
  );
  return localizations;
}

void main() {
  group('intervalLabel', () {
    testWidgets('names the fixed intervals', (tester) async {
      final localizations = await _localizations(tester);

      expect(intervalLabel(localizations, const Monthly()), 'Monthly');
      expect(intervalLabel(localizations, const Quarterly()), 'Quarterly');
      expect(intervalLabel(localizations, const Yearly()), 'Yearly');
    });

    testWidgets('uses singular for one week', (tester) async {
      final localizations = await _localizations(tester);

      expect(intervalLabel(localizations, EveryNWeeks(1)), 'Every week');
    });

    testWidgets('uses plural for several weeks', (tester) async {
      final localizations = await _localizations(tester);

      expect(intervalLabel(localizations, EveryNWeeks(2)), 'Every 2 weeks');
    });
  });

  group('categoryLabel', () {
    testWidgets('gives every category a distinct, non-empty label', (
      tester,
    ) async {
      final localizations = await _localizations(tester);

      final labels = [
        for (final category in SubscriptionCategory.values)
          categoryLabel(localizations, category),
      ];

      expect(labels.every((label) => label.trim().isNotEmpty), isTrue);
      expect(labels.toSet(), hasLength(SubscriptionCategory.values.length));
      expect(
        categoryLabel(localizations, SubscriptionCategory.streaming),
        'Streaming',
      );
    });
  });
}
