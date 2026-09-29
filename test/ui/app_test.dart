import 'package:abo_escape/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

void main() {
  group('AboEscapeApp', () {
    testWidgets('shows the app title and the empty state on start', (
      tester,
    ) async {
      tester.view.physicalSize = phoneSize * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const AboEscapeApp());

      expect(find.text('Abo Escape'), findsWidgets);
      expect(find.text('No subscriptions yet'), findsOneWidget);
    });

    testWidgets('follows the system brightness with light and dark themes', (
      tester,
    ) async {
      await tester.pumpWidget(const AboEscapeApp());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.brightness, Brightness.light);
      expect(app.darkTheme?.brightness, Brightness.dark);
      expect(app.themeMode, ThemeMode.system);
    });
  });
}
