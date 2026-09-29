import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Root widget of Abo Escape; sets up localization so every visible text
/// comes from the ARB files.
class AboEscapeApp extends StatelessWidget {
  const AboEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _PlaceholderHome(),
    );
  }
}

/// Temporary start screen until the real home screen exists (#19).
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(AppLocalizations.of(context).appTitle)),
    );
  }
}
