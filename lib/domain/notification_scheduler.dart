import 'reminders.dart';

/// Shows reminders as system notifications; implemented in `lib/data`.
abstract interface class NotificationScheduler {
  /// Cancels all previously scheduled reminders and schedules [reminders].
  Future<void> replaceAll(List<Reminder> reminders);
}
