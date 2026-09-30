import 'package:abo_escape/domain/period.dart';
import 'package:abo_escape/domain/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/subscription_fixtures.dart';

final _gym = buildSubscription(
  id: 'gym',
  name: 'Gym',
  startDate: DateTime.utc(2026, 1, 1),
  noticePeriod: Period(14, PeriodUnit.days),
  reminderDaysBefore: 7,
);

void main() {
  group('planReminders', () {
    test('reminds at 9:00 the given days before the last day to cancel', () {
      final reminders = planReminders([_gym], DateTime(2026, 9, 29, 10));

      expect(reminders, [
        Reminder(
          id: 0,
          at: DateTime(2026, 10, 10, 9),
          subscriptionName: 'Gym',
          lastDayToCancel: DateTime.utc(2026, 10, 17),
        ),
      ]);
    });

    test('plans no reminder without a lead time', () {
      final withoutReminder = _gym.copyWith(reminderDaysBefore: null);

      expect(planReminders([withoutReminder], DateTime(2026, 9, 29, 10)), isEmpty);
    });

    test('reminds today at 9:00 when the reminder day has passed', () {
      final late = _gym.copyWith(reminderDaysBefore: 30);

      expect(
        planReminders([late], DateTime(2026, 9, 29, 8)).single.at,
        DateTime(2026, 9, 29, 9),
      );
    });

    test('skips the reminder when 9:00 today has passed as well', () {
      final late = _gym.copyWith(reminderDaysBefore: 30);

      expect(planReminders([late], DateTime(2026, 9, 29, 10)), isEmpty);
    });

    test('numbers the reminders by position', () {
      final other = buildSubscription(
        id: 'news',
        name: 'News',
        startDate: DateTime.utc(2026, 1, 15),
        reminderDaysBefore: 3,
      );

      final reminders = planReminders([
        _gym,
        _gym.copyWith(reminderDaysBefore: null),
        other,
      ], DateTime(2026, 9, 29, 10));

      expect(reminders.map((r) => r.id), [0, 1]);
      expect(reminders.map((r) => r.subscriptionName), ['Gym', 'News']);
    });
  });
}
