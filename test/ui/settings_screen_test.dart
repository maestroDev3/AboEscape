import 'package:abo_escape/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_settings_repository.dart';
import '../support/fake_subscription_repository.dart';
import '../support/pump_app.dart';
import '../support/subscription_fixtures.dart';

Future<void> _openSettings(
  WidgetTester tester, {
  FakeSettingsRepository? settings,
  FakeSubscriptionRepository? subscriptions,
}) async {
  await tester.pumpApp(
    HomeScreen(
      repository: subscriptions ?? FakeSubscriptionRepository(),
      settings: settings ?? FakeSettingsRepository(),
      clock: () => DateTime(2026, 9, 30),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Settings'));
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen', () {
    testWidgets('opens from the settings button on the home screen', (
      tester,
    ) async {
      await _openSettings(tester);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
    });

    testWidgets('shows the locale currency when none is chosen', (
      tester,
    ) async {
      await _openSettings(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('currencyTile')),
          matching: find.text('USD'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('switches the app currency and all subscriptions', (
      tester,
    ) async {
      final settings = FakeSettingsRepository();
      final subscriptions = FakeSubscriptionRepository([
        buildSubscription(id: 'netflix', name: 'Netflix', cents: 1299),
      ]);
      await _openSettings(
        tester,
        settings: settings,
        subscriptions: subscriptions,
      );

      await tester.tap(find.byKey(const Key('currencyTile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GBP'));
      await tester.pumpAndSettle();

      expect(settings.currency, 'GBP');
      expect(
        find.descendant(
          of: find.byKey(const Key('currencyTile')),
          matching: find.text('GBP'),
        ),
        findsOneWidget,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('£12.99'), findsWidgets);
    });
  });
}
