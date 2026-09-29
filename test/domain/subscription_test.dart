import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/money.dart';
import 'package:abo_escape/domain/period.dart';
import 'package:abo_escape/domain/subscription.dart';
import 'package:abo_escape/domain/subscription_category.dart';
import 'package:flutter_test/flutter_test.dart';

Subscription _netflix({
  String name = 'Netflix',
  DateTime? startDate,
  Period? minimumTerm,
  Period? noticePeriod,
}) => Subscription(
  id: 'sub-1',
  name: name,
  price: Money(cents: 1299, currency: 'EUR'),
  interval: const Monthly(),
  startDate: startDate ?? DateTime.utc(2026, 1, 15),
  minimumTerm: minimumTerm,
  noticePeriod: noticePeriod,
  category: SubscriptionCategory.streaming,
);

void main() {
  group('Subscription', () {
    test('keeps all given values', () {
      final subscription = _netflix(
        minimumTerm: Period(12, PeriodUnit.months),
        noticePeriod: Period(1, PeriodUnit.months),
      );

      expect(subscription.id, 'sub-1');
      expect(subscription.name, 'Netflix');
      expect(subscription.price, Money(cents: 1299, currency: 'EUR'));
      expect(subscription.interval, const Monthly());
      expect(subscription.startDate, DateTime.utc(2026, 1, 15));
      expect(subscription.minimumTerm, Period(12, PeriodUnit.months));
      expect(subscription.noticePeriod, Period(1, PeriodUnit.months));
      expect(subscription.category, SubscriptionCategory.streaming);
    });

    test('rejects an empty or whitespace-only name', () {
      expect(() => _netflix(name: ''), throwsArgumentError);
      expect(() => _netflix(name: '   '), throwsArgumentError);
    });

    test('trims the name', () {
      expect(_netflix(name: '  Spotify ').name, 'Spotify');
    });

    test('normalizes the start date to its day', () {
      final subscription = _netflix(startDate: DateTime(2026, 3, 29, 18, 30));

      expect(subscription.startDate, DateTime.utc(2026, 3, 29));
    });

    test('is equal to a subscription with the same values', () {
      expect(_netflix(), _netflix());
      expect(_netflix().hashCode, _netflix().hashCode);
      expect(_netflix(), isNot(_netflix(name: 'Disney+')));
    });
  });

  group('Subscription.copyWith', () {
    test('changes only the given fields', () {
      final original = _netflix(noticePeriod: Period(1, PeriodUnit.months));

      final changed = original.copyWith(
        name: 'Netflix Premium',
        price: Money(cents: 1799, currency: 'EUR'),
      );

      expect(changed.name, 'Netflix Premium');
      expect(changed.price, Money(cents: 1799, currency: 'EUR'));
      expect(changed.id, original.id);
      expect(changed.interval, original.interval);
      expect(changed.startDate, original.startDate);
      expect(changed.noticePeriod, original.noticePeriod);
      expect(changed.category, original.category);
    });

    test('keeps optional periods when they are not given', () {
      final original = _netflix(
        minimumTerm: Period(24, PeriodUnit.months),
        noticePeriod: Period(3, PeriodUnit.months),
      );

      final changed = original.copyWith(name: 'Other');

      expect(changed.minimumTerm, Period(24, PeriodUnit.months));
      expect(changed.noticePeriod, Period(3, PeriodUnit.months));
    });

    test('clears optional periods when null is given', () {
      final original = _netflix(
        minimumTerm: Period(24, PeriodUnit.months),
        noticePeriod: Period(3, PeriodUnit.months),
      );

      final changed = original.copyWith(minimumTerm: null, noticePeriod: null);

      expect(changed.minimumTerm, isNull);
      expect(changed.noticePeriod, isNull);
    });

    test('changes interval, start date and category', () {
      final changed = _netflix().copyWith(
        interval: EveryNWeeks(4),
        startDate: DateTime(2026, 5, 1, 12),
        category: SubscriptionCategory.other,
      );

      expect(changed.interval, EveryNWeeks(4));
      expect(changed.startDate, DateTime.utc(2026, 5, 1));
      expect(changed.category, SubscriptionCategory.other);
    });
  });

  group('SubscriptionCategory', () {
    test('offers a fallback category', () {
      expect(SubscriptionCategory.values, contains(SubscriptionCategory.other));
    });
  });
}
