import 'package:abo_escape/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_settings_repository.dart';
import '../support/fake_subscription_repository.dart';
import '../support/pump_app.dart';

void main() {
  group('AboEscapeApp', () {
    testWidgets('shows the app title and the empty state on start', (
      tester,
    ) async {
      tester.usePhoneSize();

      await tester.pumpWidget(
        AboEscapeApp(
          repository: FakeSubscriptionRepository(),
          settings: FakeSettingsRepository(),
        ),
      );
      await tester.pump();

      expect(find.text('Abo Escape'), findsWidgets);
      expect(find.text('No subscriptions yet'), findsOneWidget);
    });

    testWidgets('follows the system brightness with light and dark themes', (
      tester,
    ) async {
      await tester.pumpWidget(
        AboEscapeApp(
          repository: FakeSubscriptionRepository(),
          settings: FakeSettingsRepository(),
        ),
      );
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.brightness, Brightness.light);
      expect(app.darkTheme?.brightness, Brightness.dark);
      expect(app.themeMode, ThemeMode.system);
    });
  });
}
