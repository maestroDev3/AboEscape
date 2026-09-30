import 'dart:async';

import 'clock.dart';
import 'notification_scheduler.dart';
import 'reminders.dart';
import 'subscription.dart';
import 'subscription_repository.dart';

/// Keeps the scheduled reminders in line with the stored subscriptions.
class ReminderSync {
  ReminderSync({
    required this.subscriptions,
    required this.scheduler,
    this.clock = DateTime.now,
  });

  final SubscriptionRepository subscriptions;
  final NotificationScheduler scheduler;
  final Clock clock;

  /// Re-plans all reminders now and after every change of the subscriptions.
  StreamSubscription<List<Subscription>> start() =>
      subscriptions.watchAll().listen(
        (list) => scheduler.replaceAll(planReminders(list, clock())),
      );
}
