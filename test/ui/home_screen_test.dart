import 'package:abo_escape/domain/billing_interval.dart';
import 'package:abo_escape/ui/home_screen.dart';
import 'package:abo_escape/ui/subscription_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_subscription_repository.dart';
import '../support/pump_app.dart';
import '../support/subscription_fixtures.dart';

final _now = DateTime(2026, 9, 29, 10);

Future<void> _pumpHome(
  WidgetTester tester,
  FakeSubscriptionRepository repository,
) async {
  await tester.pumpApp(HomeScreen(repository: repository, clock: () => _now));
  await tester.pumpAndSettle();
}

void main() {
  final spotify = buildSubscription(
    id: 'spotify',
    name: 'Spotify',
    cents: 1099,
    interval: EveryNWeeks(2),
  );
  final netflix = buildSubscription(id: 'netflix', name: 'Netflix');

  group('HomeScreen list', () {
    testWidgets('shows the empty state without subscriptions', (tester) async {
      await _pumpHome(tester, FakeSubscriptionRepository());

      expect(find.text('No subscriptions yet'), findsOneWidget);
    });

    testWidgets('shows name, price and interval ordered by name', (
      tester,
    ) async {
      await _pumpHome(tester, FakeSubscriptionRepository([spotify, netflix]));

      expect(find.text('No subscriptions yet'), findsNothing);
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Spotify'), findsOneWidget);
      expect(find.text('€12.99'), findsOneWidget);
      expect(find.text('€10.99'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Every 2 weeks'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Netflix')).dy,
        lessThan(tester.getTopLeft(find.text('Spotify')).dy),
      );
    });
  });

  group('HomeScreen actions', () {
    testWidgets('adds a subscription through the form', (tester) async {
      final repository = FakeSubscriptionRepository();
      await _pumpHome(tester, repository);

      await tester.tap(find.text('Add subscription'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('nameField')), 'Netflix');
      await tester.enterText(find.byKey(const Key('priceField')), '12.99');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionFormScreen), findsNothing);
      expect(find.text('Netflix'), findsOneWidget);
      expect(repository.subscriptions, hasLength(1));
    });

    testWidgets('edits a subscription after tapping it', (tester) async {
      final repository = FakeSubscriptionRepository([netflix]);
      await _pumpHome(tester, repository);

      await tester.tap(find.text('Netflix'));
      await tester.pumpAndSettle();
      expect(find.text('Edit subscription'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('nameField')),
        'Netflix Premium',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Netflix Premium'), findsOneWidget);
      expect(find.text('Netflix'), findsNothing);
      expect(repository.subscriptions.single.id, 'netflix');
    });

    testWidgets('offers a delete button with a tooltip when editing', (
      tester,
    ) async {
      await _pumpHome(tester, FakeSubscriptionRepository([netflix]));

      await tester.tap(find.text('Netflix'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Delete'), findsOneWidget);
    });

    testWidgets('deletes a subscription after confirming', (tester) async {
      final repository = FakeSubscriptionRepository([netflix, spotify]);
      await _pumpHome(tester, repository);

      await tester.tap(find.text('Netflix'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete subscription?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionFormScreen), findsNothing);
      expect(find.text('Netflix'), findsNothing);
      expect(find.text('Spotify'), findsOneWidget);
      expect(repository.subscriptions, [spotify]);
    });

    testWidgets('keeps the subscription when deleting is cancelled', (
      tester,
    ) async {
      final repository = FakeSubscriptionRepository([netflix]);
      await _pumpHome(tester, repository);

      await tester.tap(find.text('Netflix'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionFormScreen), findsOneWidget);
      expect(repository.subscriptions, [netflix]);
    });

    testWidgets('does not offer delete for a new subscription', (
      tester,
    ) async {
      await _pumpHome(tester, FakeSubscriptionRepository());

      await tester.tap(find.text('Add subscription'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Delete'), findsNothing);
    });
  });
}
