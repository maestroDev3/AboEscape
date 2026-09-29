import 'package:abo_escape/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

void main() {
  group('pumpApp', () {
    testWidgets('provides localizations to the pumped widget', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) =>
              Text(AppLocalizations.of(context).emptySubscriptions),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('No subscriptions yet'), findsOneWidget);
    });

    testWidgets('renders on a phone-sized screen', (tester) async {
      await tester.pumpApp(const SizedBox.shrink());

      expect(tester.view.physicalSize / tester.view.devicePixelRatio, phoneSize);
    });
  });
}
