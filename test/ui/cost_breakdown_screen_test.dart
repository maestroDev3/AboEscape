import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/domain/subscription_category.dart';
import 'package:abo_escape/ui/cost_breakdown_screen.dart';
import 'package:abo_escape/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_settings_repository.dart';
import '../support/fake_subscription_repository.dart';
import '../support/pump_app.dart';
import '../support/subscription_fixtures.dart';

final _subscriptions = [
  buildSubscription(id: 'netflix', name: 'Netflix', cents: 1299),
  buildSubscription(id: 'disney', name: 'Disney+', cents: 599),
  buildSubscription(
    id: 'gym',
    name: 'Gym',
    cents: 12000,
    interval: const Yearly(),
    category: SubscriptionCategory.fitness,
  ),
];

void main() {
  group('CostBreakdownScreen', () {
    testWidgets('opens from the cost card on the home screen', (tester) async {
      await tester.pumpApp(
        HomeScreen(
          repository: FakeSubscriptionRepository(_subscriptions),
          settings: FakeSettingsRepository(),
          clock: () => DateTime(2026, 9, 30),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Per month'));
      await tester.pumpAndSettle();

      expect(find.text('Costs by category'), findsOneWidget);
    });

    testWidgets('lists categories with monthly and yearly costs by cost', (
      tester,
    ) async {
      await tester.pumpApp(
        CostBreakdownScreen(
          repository: FakeSubscriptionRepository(_subscriptions),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Streaming'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('€18.98'), findsOneWidget);
      expect(find.text('€10.00'), findsOneWidget);
      expect(find.text('€227.76'), findsOneWidget);
      expect(find.text('€120.00'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Streaming')).dy,
        lessThan(tester.getTopLeft(find.text('Fitness')).dy),
      );
    });

    testWidgets('shows each share of the monthly total as a bar', (
      tester,
    ) async {
      await tester.pumpApp(
        CostBreakdownScreen(
          repository: FakeSubscriptionRepository(_subscriptions),
        ),
      );
      await tester.pumpAndSettle();

      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .map((bar) => bar.value)
          .toList();
      expect(bars, hasLength(2));
      expect(bars.first, closeTo(1898 / 2898, 0.001));
      expect(bars.last, closeTo(1000 / 2898, 0.001));
    });

    testWidgets('updates when subscriptions change', (tester) async {
      final repository = FakeSubscriptionRepository(_subscriptions);
      await tester.pumpApp(CostBreakdownScreen(repository: repository));
      await tester.pumpAndSettle();

      await repository.save(
        buildSubscription(
          id: 'spotify',
          name: 'Spotify',
          cents: 1099,
          category: SubscriptionCategory.music,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Music'), findsOneWidget);
      expect(find.text('€10.99'), findsOneWidget);
    });
  });
}
