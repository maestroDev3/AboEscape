import 'package:abo_escape/l10n/app_localizations.dart';
import 'package:abo_escape/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phone-sized logical screen (Pixel 7 class) used by all widget tests.
const phoneSize = Size(412, 915);

/// Pumps widgets inside the app's theme and localization, so widget tests
/// render the same way as the real app.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    view.physicalSize = phoneSize * 3;
    view.devicePixelRatio = 3;
    addTearDown(view.reset);

    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: widget,
      ),
    );
  }
}
