import 'package:abo_escape/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_settings_repository.dart';
import '../support/fake_subscription_repository.dart';
import '../support/pump_app.dart';

const _disclaimer =
    'Abo Escape calculates billing dates and cancellation deadlines from the '
    'data you enter. All dates are without guarantee – your contract is '
    'always authoritative.';

Future<void> _pumpHome(
  WidgetTester tester,
  FakeSettingsRepository settings,
) async {
  await tester.pumpApp(
    HomeScreen(
      repository: FakeSubscriptionRepository(),
      settings: settings,
      clock: () => DateTime(2026, 9, 30),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Disclaimer', () {
    testWidgets('is shown on first start until confirmed', (tester) async {
      final settings = FakeSettingsRepository(disclaimerAccepted: false);
      await _pumpHome(tester, settings);

      expect(find.text('Please note'), findsOneWidget);
      expect(find.text(_disclaimer), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Please note'), findsNothing);
      expect(settings.disclaimerAccepted, isTrue);
    });

    testWidgets('is not shown again once accepted', (tester) async {
      await _pumpHome(tester, FakeSettingsRepository());

      expect(find.text('Please note'), findsNothing);
    });

    testWidgets('is available under About in the settings', (tester) async {
      await _pumpHome(tester, FakeSettingsRepository());
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.text('Abo Escape'), findsWidgets);
      expect(find.text(_disclaimer), findsOneWidget);
    });
  });
}
