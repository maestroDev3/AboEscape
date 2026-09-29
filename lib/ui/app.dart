import 'package:flutter/material.dart';

import '../domain/clock.dart';
import '../domain/subscription_repository.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'theme.dart';

/// Root widget of Abo Escape; sets up theme and localization so every screen
/// gets its colors from the theme and its texts from the ARB files.
class AboEscapeApp extends StatelessWidget {
  const AboEscapeApp({
    required this.repository,
    this.clock = DateTime.now,
    super.key,
  });

  final SubscriptionRepository repository;
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(repository: repository, clock: clock),
    );
  }
}
