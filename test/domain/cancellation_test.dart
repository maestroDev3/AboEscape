import 'package:abo_escape/domain/billing.dart';
import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/cancellation.dart';
import 'package:abo_escape/domain/period.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/subscription_fixtures.dart';

DateTime _day(int year, int month, int day) => DateTime.utc(year, month, day);

final _today = _day(2026, 9, 30);

void main() {
  group('cancellationDeadline', () {
    test('without terms, cancels to the end of the current period', () {
      final subscription = buildSubscription(startDate: _day(2026, 1, 1));

      expect(
        cancellationDeadline(subscription, _today),
        CancellationDeadline(
          lastDayToCancel: _day(2026, 9, 30),
          contractEnd: _day(2026, 9, 30),
        ),
      );
    });

    test('respects the minimum term and a notice period in months', () {
      final subscription = buildSubscription(
        startDate: _day(2025, 1, 1),
        minimumTerm: Period(24, PeriodUnit.months),
        noticePeriod: Period(3, PeriodUnit.months),
      );

      expect(
        cancellationDeadline(subscription, _today),
        CancellationDeadline(
          lastDayToCancel: _day(2026, 9, 30),
          contractEnd: _day(2026, 12, 31),
        ),
      );
      expect(
        cancellationDeadline(subscription, _day(2026, 10, 1)),
        CancellationDeadline(
          lastDayToCancel: _day(2026, 10, 31),
          contractEnd: _day(2027, 1, 31),
        ),
      );
    });

    test('ends a yearly subscription on the day before its billing date', () {
      final subscription = buildSubscription(
        interval: const Yearly(),
        startDate: _day(2024, 3, 15),
        noticePeriod: Period(1, PeriodUnit.months),
      );

      expect(
        cancellationDeadline(subscription, _today),
        CancellationDeadline(
          lastDayToCancel: _day(2027, 2, 14),
          contractEnd: _day(2027, 3, 14),
        ),
      );
    });

    test('moves to the next period when the notice period is too short', () {
      final subscription = buildSubscription(
        startDate: _day(2026, 1, 1),
        noticePeriod: Period(14, PeriodUnit.days),
      );

      expect(
        cancellationDeadline(subscription, _today),
        CancellationDeadline(
          lastDayToCancel: _day(2026, 10, 17),
          contractEnd: _day(2026, 10, 31),
        ),
      );
    });

    test('clamps month ends for subscriptions from the 31st', () {
      final subscription = buildSubscription(
        startDate: _day(2026, 1, 31),
        noticePeriod: Period(1, PeriodUnit.months),
      );

      expect(
        cancellationDeadline(subscription, _day(2026, 2, 1)),
        CancellationDeadline(
          lastDayToCancel: _day(2026, 2, 27),
          contractEnd: _day(2026, 3, 30),
        ),
      );
    });

    test('handles every n weeks with a notice period in days', () {
      final subscription = buildSubscription(
        interval: EveryNWeeks(4),
        startDate: _day(2026, 9, 1),
        noticePeriod: Period(7, PeriodUnit.days),
      );

      expect(
        cancellationDeadline(subscription, _day(2026, 9, 20)),
        CancellationDeadline(
          lastDayToCancel: _day(2026, 9, 21),
          contractEnd: _day(2026, 9, 28),
        ),
      );
    });

    test('uses the first period end after a short minimum term', () {
      final subscription = buildSubscription(
        interval: const Yearly(),
        startDate: _day(2026, 3, 15),
        minimumTerm: Period(1, PeriodUnit.months),
      );

      expect(
        cancellationDeadline(subscription, _day(2026, 3, 20)).contractEnd,
        _day(2027, 3, 14),
      );
    });

    test('ends after the first period when the start lies in the future', () {
      final subscription = buildSubscription(startDate: _day(2026, 10, 15));

      expect(
        cancellationDeadline(subscription, _today),
        CancellationDeadline(
          lastDayToCancel: _day(2026, 11, 14),
          contractEnd: _day(2026, 11, 14),
        ),
      );
    });

    test('ignores the time of day of today', () {
      final subscription = buildSubscription(startDate: _day(2026, 1, 1));

      expect(
        cancellationDeadline(
          subscription,
          DateTime(2026, 9, 30, 23, 30),
        ).lastDayToCancel,
        _day(2026, 9, 30),
      );
    });
  });

  group('billingDateAt', () {
    test('returns the start date for index 0 and clamps month ends', () {
      final subscription = buildSubscription(startDate: _day(2026, 1, 31));

      expect(billingDateAt(subscription, 0), _day(2026, 1, 31));
      expect(billingDateAt(subscription, 1), _day(2026, 2, 28));
      expect(billingDateAt(subscription, 2), _day(2026, 3, 31));
    });

    test('adds whole weeks for every n weeks', () {
      final subscription = buildSubscription(
        interval: EveryNWeeks(2),
        startDate: _day(2026, 9, 1),
      );

      expect(billingDateAt(subscription, 3), _day(2026, 10, 13));
    });
  });
}
