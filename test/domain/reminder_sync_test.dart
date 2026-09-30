import 'package:abo_escape/domain/reminder_sync.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_notification_scheduler.dart';
import '../support/fake_subscription_repository.dart';
import '../support/subscription_fixtures.dart';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('ReminderSync', () {
    test('schedules on start and after every change', () async {
      final repository = FakeSubscriptionRepository([
        buildSubscription(id: 'a', name: 'Netflix', reminderDaysBefore: 7),
      ]);
      final scheduler = FakeNotificationScheduler();
      final sync = ReminderSync(
        subscriptions: repository,
        scheduler: scheduler,
        clock: () => DateTime(2026, 9, 29, 8),
      );

      final running = sync.start();
      await _settle();
      await repository.save(
        buildSubscription(id: 'b', name: 'Spotify', reminderDaysBefore: 7),
      );
      await _settle();
      await repository.delete('a');
      await _settle();
      await running.cancel();

      expect(scheduler.calls.map((c) => c.map((r) => r.subscriptionName)), [
        ['Netflix'],
        ['Netflix', 'Spotify'],
        ['Spotify'],
      ]);
    });
  });
}
