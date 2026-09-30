import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/reminders.dart';
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

  group('reminderMessage', () {
    testWidgets('names the subscription and the last day to cancel', (
      tester,
    ) async {
      final localizations = await _localizations(tester);

      final message = reminderMessage(
        localizations,
        Reminder(
          id: 0,
          at: DateTime(2026, 10, 10, 9),
          subscriptionName: 'Netflix',
          lastDayToCancel: DateTime.utc(2026, 10, 17),
        ),
        'en',
      );

      expect(message, 'Cancel Netflix by Oct 17, 2026');
      expect(localizations.reminderTitle, 'Cancellation deadline');
      expect(localizations.reminderChannelName, 'Cancellation reminders');
    });
  });
}
