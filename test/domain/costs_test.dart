import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/costs.dart';
import 'package:abo_escape/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/subscription_fixtures.dart';

Money _eur(int cents) => Money(cents: cents, currency: 'EUR');

/// Returns the single summary for [subscriptions] as (monthly, yearly) cents.
(int, int) _totals(List<BillingInterval> intervals, int cents) {
  final summaries = costSummaries([
    for (final (index, interval) in intervals.indexed)
      buildSubscription(id: '$index', cents: cents, interval: interval),
  ]);
  final summary = summaries.single;
  return (summary.monthly.cents, summary.yearly.cents);
}

void main() {
  group('costSummaries', () {
    test('keeps a monthly price per month and multiplies it by 12', () {
      expect(_totals([const Monthly()], 1299), (1299, 15588));
    });

    test('splits a quarterly price over three months', () {
      expect(_totals([const Quarterly()], 3000), (1000, 12000));
    });

    test('splits a yearly price over twelve months', () {
      expect(_totals([const Yearly()], 10000), (833, 10000));
    });

    test('uses 52.1775 weeks per year for every 4 weeks', () {
      expect(_totals([EveryNWeeks(4)], 1000), (1087, 13044));
    });

    test('uses 52.1775 weeks per year for every week', () {
      expect(_totals([EveryNWeeks(1)], 100), (435, 5218));
    });

    test('rounds once on the total, not per subscription', () {
      expect(_totals([const Yearly(), const Yearly(), const Yearly()], 100), (
        25,
        300,
      ));
    });

    test('rounds half up', () {
      expect(_totals([const Yearly()], 6), (1, 6));
    });

    test('sums different intervals', () {
      final summary = costSummaries([
        buildSubscription(id: 'a', cents: 1299),
        buildSubscription(id: 'b', cents: 10000, interval: const Yearly()),
      ]).single;

      expect(summary.monthly, _eur(2132));
      expect(summary.yearly, _eur(25588));
    });

    test('returns nothing without subscriptions', () {
      expect(costSummaries([]), isEmpty);
    });

    test('returns one summary per currency, ordered by currency code', () {
      final summaries = costSummaries([
        buildSubscription(id: 'a', cents: 500, currency: 'USD'),
        buildSubscription(id: 'b', cents: 700, currency: 'EUR'),
      ]);

      expect(summaries.map((s) => s.monthly), [
        _eur(700),
        Money(cents: 500, currency: 'USD'),
      ]);
      expect(summaries.map((s) => s.yearly.currency), ['EUR', 'USD']);
    });
  });
}
