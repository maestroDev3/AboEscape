import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/costs.dart';
import 'package:abo_escape/domain/money.dart';
import 'package:abo_escape/domain/subscription_category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/subscription_fixtures.dart';

Money _eur(int cents) => Money(cents: cents, currency: 'EUR');

void main() {
  group('categoryCosts', () {
    test('sums each category and orders by cost', () {
      final costs = categoryCosts([
        buildSubscription(
          id: 'gym',
          cents: 12000,
          interval: const Yearly(),
          category: SubscriptionCategory.fitness,
        ),
        buildSubscription(id: 'netflix', cents: 1299),
        buildSubscription(id: 'disney', cents: 599),
      ]);

      expect(costs, [
        CategoryCost(
          category: SubscriptionCategory.streaming,
          costs: CostSummary(monthly: _eur(1898), yearly: _eur(22776)),
        ),
        CategoryCost(
          category: SubscriptionCategory.fitness,
          costs: CostSummary(monthly: _eur(1000), yearly: _eur(12000)),
        ),
      ]);
    });

    test('returns nothing without subscriptions', () {
      expect(categoryCosts([]), isEmpty);
    });

    test('orders equal costs in category order', () {
      final costs = categoryCosts([
        buildSubscription(id: 'n', category: SubscriptionCategory.news),
        buildSubscription(id: 'm', category: SubscriptionCategory.music),
      ]);

      expect(costs.map((c) => c.category), [
        SubscriptionCategory.music,
        SubscriptionCategory.news,
      ]);
    });

    test('lists categories per currency, ordered by currency code', () {
      final costs = categoryCosts([
        buildSubscription(id: 'a', currency: 'USD', cents: 9999),
        buildSubscription(id: 'b', currency: 'EUR', cents: 100),
      ]);

      expect(costs.map((c) => c.costs.monthly.currency), ['EUR', 'USD']);
    });
  });
}
