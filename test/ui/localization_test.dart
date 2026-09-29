import 'package:abo_escape/l10n/app_localizations.dart';
import 'package:abo_escape/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    testWidgets('resolves the app title in English', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Text(AppLocalizations.of(context).appTitle),
          ),
        ),
      );

      expect(find.text('Abo Escape'), findsOneWidget);
    });
  });

  group('AboEscapeApp', () {
    testWidgets('supports the English locale', (tester) async {
      await tester.pumpWidget(const AboEscapeApp());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.supportedLocales, contains(const Locale('en')));
    });

    testWidgets('registers the app localization delegate', (tester) async {
      await tester.pumpWidget(const AboEscapeApp());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.localizationsDelegates, contains(AppLocalizations.delegate));
    });

    testWidgets('generates its title from the localizations', (tester) async {
      await tester.pumpWidget(const AboEscapeApp());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final context = tester.element(find.byType(Scaffold).first);
      expect(app.onGenerateTitle?.call(context), 'Abo Escape');
    });
  });
}
