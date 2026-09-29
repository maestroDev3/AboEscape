import 'package:abo_escape/domain/billing.dart';
import 'package:abo_escape/domain/billing_interval.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/subscription_fixtures.dart';

DateTime _day(int year, int month, int day) => DateTime.utc(year, month, day);

void main() {
  group('addMonths', () {
    test('keeps the day when the target month is long enough', () {
      expect(addMonths(_day(2026, 1, 15), 1), _day(2026, 2, 15));
    });

    test('clamps to the last day of a shorter month', () {
      expect(addMonths(_day(2026, 1, 31), 1), _day(2026, 2, 28));
      expect(addMonths(_day(2026, 3, 31), 1), _day(2026, 4, 30));
    });

    test('clamps to February 29 in a leap year', () {
      expect(addMonths(_day(2028, 1, 31), 1), _day(2028, 2, 29));
    });

    test('crosses year boundaries', () {
      expect(addMonths(_day(2025, 11, 30), 3), _day(2026, 2, 28));
      expect(addMonths(_day(2026, 12, 15), 13), _day(2028, 1, 15));
    });
  });

  group('nextBillingDate', () {
    test('returns the start date when it lies in the future', () {
      final subscription = buildSubscription(startDate: _day(2026, 10, 15));

      expect(
        nextBillingDate(subscription, _day(2026, 9, 29)),
        _day(2026, 10, 15),
      );
    });

    test('returns today when today is a billing day', () {
      final subscription = buildSubscription(startDate: _day(2026, 1, 29));

      expect(
        nextBillingDate(subscription, _day(2026, 9, 29)),
        _day(2026, 9, 29),
      );
    });

    test('bills a monthly subscription from the 31st on February 28', () {
      final subscription = buildSubscription(startDate: _day(2026, 1, 31));

      expect(
        nextBillingDate(subscription, _day(2026, 2, 1)),
        _day(2026, 2, 28),
      );
    });

    test('returns to the 31st after a short month without drifting', () {
      final subscription = buildSubscription(startDate: _day(2026, 1, 31));

      expect(
        nextBillingDate(subscription, _day(2026, 3, 1)),
        _day(2026, 3, 31),
      );
    });

    test('bills a monthly subscription from the 31st on February 29 in a leap year', () {
      final subscription = buildSubscription(startDate: _day(2028, 1, 31));

      expect(
        nextBillingDate(subscription, _day(2028, 2, 1)),
        _day(2028, 2, 29),
      );
    });

    test(
      'bills a quarterly subscription from November 30 on Feb 28, then May 30',
      () {
        final subscription = buildSubscription(
          interval: const Quarterly(),
          startDate: _day(2025, 11, 30),
        );

        expect(
          nextBillingDate(subscription, _day(2025, 12, 1)),
          _day(2026, 2, 28),
        );
        expect(
          nextBillingDate(subscription, _day(2026, 3, 1)),
          _day(2026, 5, 30),
        );
      },
    );

    test('bills a yearly subscription from February 29 on Feb 28 and in leap years on Feb 29', () {
      final subscription = buildSubscription(
        interval: const Yearly(),
        startDate: _day(2024, 2, 29),
      );

      expect(
        nextBillingDate(subscription, _day(2024, 3, 1)),
        _day(2025, 2, 28),
      );
      expect(
        nextBillingDate(subscription, _day(2027, 3, 1)),
        _day(2028, 2, 29),
      );
    });

    test('bills every n weeks counted from the start date', () {
      final subscription = buildSubscription(
        interval: EveryNWeeks(2),
        startDate: _day(2026, 9, 1),
      );

      expect(
        nextBillingDate(subscription, _day(2026, 9, 20)),
        _day(2026, 9, 29),
      );
      expect(
        nextBillingDate(subscription, _day(2026, 9, 15)),
        _day(2026, 9, 15),
      );
    });

    test('ignores the time of day of today', () {
      final subscription = buildSubscription(startDate: _day(2026, 1, 29));

      expect(
        nextBillingDate(subscription, DateTime(2026, 9, 29, 23, 30)),
        _day(2026, 9, 29),
      );
    });

    test('finds dates many years after the start', () {
      final subscription = buildSubscription(startDate: _day(2000, 1, 31));

      expect(
        nextBillingDate(subscription, _day(2026, 2, 2)),
        _day(2026, 2, 28),
      );
    });
  });
}
