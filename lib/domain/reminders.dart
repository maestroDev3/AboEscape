import 'cancellation.dart';
import 'clock.dart';
import 'subscription.dart';

/// Hour of the day (local time) when reminders are shown (decision
/// 2026-09-30).
const reminderHour = 9;

/// A notification that reminds the user to cancel a subscription in time.
final class Reminder {
  const Reminder({
    required this.id,
    required this.at,
    required this.subscriptionName,
    required this.lastDayToCancel,
  });

  /// Notification id, the position in the planned list.
  final int id;

  /// Local date and time when the reminder is shown.
  final DateTime at;

  final String subscriptionName;
  final DateTime lastDayToCancel;

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.at == at &&
      other.subscriptionName == subscriptionName &&
      other.lastDayToCancel == lastDayToCancel;

  @override
  int get hashCode => Object.hash(id, at, subscriptionName, lastDayToCancel);

  @override
  String toString() => 'Reminder($id, $subscriptionName at $at)';
}

/// Plans one reminder per subscription with a lead time: at [reminderHour] on
/// the last day to cancel minus the lead time.
///
/// If that day has already passed, the reminder is shown today at
/// [reminderHour], or skipped when that moment has passed as well.
List<Reminder> planReminders(List<Subscription> subscriptions, DateTime now) {
  final today = dayOf(now);
  final reminders = <Reminder>[];
  for (final subscription in subscriptions) {
    final days = subscription.reminderDaysBefore;
    if (days == null) continue;

    final lastDayToCancel = cancellationDeadline(
      subscription,
      now,
    ).lastDayToCancel;
    var day = lastDayToCancel.subtract(Duration(days: days));
    if (day.isBefore(today)) day = today;
    final at = DateTime(day.year, day.month, day.day, reminderHour);
    if (!at.isAfter(now)) continue;

    reminders.add(
      Reminder(
        id: reminders.length,
        at: at,
        subscriptionName: subscription.name,
        lastDayToCancel: lastDayToCancel,
      ),
    );
  }
  return reminders;
}
