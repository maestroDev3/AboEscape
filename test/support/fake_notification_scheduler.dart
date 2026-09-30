import 'package:abo_escape/domain/notification_scheduler.dart';
import 'package:abo_escape/domain/reminders.dart';

/// Records every [replaceAll] call instead of showing notifications.
class FakeNotificationScheduler implements NotificationScheduler {
  final calls = <List<Reminder>>[];

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {
    calls.add(reminders);
  }
}
