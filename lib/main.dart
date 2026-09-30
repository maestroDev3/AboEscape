import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local_notification_scheduler.dart';
import 'data/shared_preferences_settings_repository.dart';
import 'data/shared_preferences_subscription_repository.dart';
import 'domain/reminder_sync.dart';
import 'l10n/app_localizations.dart';
import 'ui/app.dart';
import 'ui/labels.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reminder texts are formatted outside the widget tree.
  await initializeDateFormatting();
  final preferences = await SharedPreferences.getInstance();
  final subscriptions = SharedPreferencesSubscriptionRepository(preferences);

  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final localizations = lookupAppLocalizations(
    AppLocalizations.delegate.isSupported(deviceLocale)
        ? deviceLocale
        : const Locale('en'),
  );
  final scheduler = LocalNotificationScheduler(
    title: localizations.reminderTitle,
    channelName: localizations.reminderChannelName,
    message: (reminder) =>
        reminderMessage(localizations, reminder, deviceLocale.toString()),
  );
  await scheduler.initialize();
  ReminderSync(subscriptions: subscriptions, scheduler: scheduler).start();

  runApp(
    AboEscapeApp(
      repository: subscriptions,
      settings: SharedPreferencesSettingsRepository(preferences),
    ),
  );
}
