import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_scheduler.dart';
import '../domain/reminders.dart';

/// Shows reminders as Android notifications via flutter_local_notifications.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler({
    required this.title,
    required this.channelName,
    required this.message,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'cancellation_reminders';

  /// Localized notification title, channel name and message builder.
  final String title;
  final String channelName;
  final String Function(Reminder reminder) message;

  final FlutterLocalNotificationsPlugin _plugin;
  var _permissionRequested = false;

  /// Loads the time zone data, sets the device time zone and initializes the
  /// plugin; call once before [replaceAll].
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(_location(timezone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {
    await _plugin.cancelAll();
    if (reminders.isEmpty) return;
    await _requestPermissionOnce();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(_channelId, channelName),
    );
    for (final reminder in reminders) {
      final at = reminder.at;
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: title,
        body: message(reminder),
        scheduledDate: tz.TZDateTime(
          tz.local,
          at.year,
          at.month,
          at.day,
          at.hour,
          at.minute,
        ),
        notificationDetails: details,
        // Inexact: no exact-alarm permission needed (decision 2026-09-30).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Android 13+ needs the user's consent before notifications are shown.
  Future<void> _requestPermissionOnce() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Falls back to UTC for time zone ids the database does not know.
  tz.Location _location(String identifier) {
    try {
      return tz.getLocation(identifier);
    } on tz.LocationNotFoundException {
      return tz.UTC;
    }
  }
}
