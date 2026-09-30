import 'package:abo_escape/data/subscription_codec.dart';
import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/period.dart';
import 'package:abo_escape/domain/subscription_category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/stored_fixtures.dart';
import '../support/subscription_fixtures.dart';

void main() {
  group('subscription codec', () {
    final intervals = <BillingInterval>[
      const Monthly(),
      const Quarterly(),
      const Yearly(),
      EveryNWeeks(2),
    ];

    for (final interval in intervals) {
      test('round-trips a subscription billed $interval', () {
        final subscription = buildSubscription(interval: interval);

        expect(
          subscriptionFromJson(subscriptionToJson(subscription)),
          subscription,
        );
      });
    }

    test('round-trips a subscription with minimum term and notice period', () {
      final subscription = buildSubscription(
        minimumTerm: Period(24, PeriodUnit.months),
        noticePeriod: Period(2, PeriodUnit.weeks),
      );

      expect(
        subscriptionFromJson(subscriptionToJson(subscription)),
        subscription,
      );
    });

    test('round-trips a list through its string encoding', () {
      final subscriptions = [
        buildSubscription(id: 'a'),
        buildSubscription(id: 'b', category: SubscriptionCategory.cloud),
      ];

      expect(
        decodeSubscriptions(encodeSubscriptions(subscriptions)),
        subscriptions,
      );
    });

    test('decodes the stored v1 format', () {
      expect(decodeSubscriptions(storedV1), [
        buildSubscription(
          id: 'a',
          name: 'Netflix',
          noticePeriod: Period(1, PeriodUnit.months),
          reminderDaysBefore: 7,
        ),
        buildSubscription(
          id: 'b',
          name: 'Gym',
          cents: 2990,
          interval: EveryNWeeks(4),
          startDate: DateTime.utc(2025, 11, 1),
          minimumTerm: Period(12, PeriodUnit.months),
          noticePeriod: Period(14, PeriodUnit.days),
          category: SubscriptionCategory.fitness,
          reminderDaysBefore: 7,
        ),
      ]);
    });

    test('round-trips a reminder lead time and no reminder', () {
      for (final days in [3, null]) {
        final subscription = buildSubscription(reminderDaysBefore: days);

        expect(
          subscriptionFromJson(subscriptionToJson(subscription)),
          subscription,
        );
      }
    });

    test('defaults to 7 days for data stored before reminders existed', () {
      final json = subscriptionToJson(buildSubscription())
        ..remove('reminderDaysBefore');

      expect(subscriptionFromJson(json).reminderDaysBefore, 7);
    });

    test('falls back to "other" for an unknown category', () {
      final json = subscriptionToJson(buildSubscription())
        ..['category'] = 'somethingNew';

      expect(subscriptionFromJson(json).category, SubscriptionCategory.other);
    });

    test('rejects malformed data with a FormatException', () {
      expect(
        () => subscriptionFromJson({'id': 'a'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
