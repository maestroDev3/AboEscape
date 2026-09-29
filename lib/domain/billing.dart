import 'dart:math';

import 'billing_interval.dart';
import 'clock.dart';
import 'subscription.dart';

/// Adds [months] calendar months to [day], clamping to the last day of
/// shorter months (Jan 31 + 1 month = Feb 28/29).
DateTime addMonths(DateTime day, int months) {
  final monthIndex = day.year * 12 + (day.month - 1) + months;
  final year = monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDayOfMonth = DateTime.utc(year, month + 1, 0).day;
  return DateTime.utc(year, month, min(day.day, lastDayOfMonth));
}

/// First billing day of [subscription] on or after the day of [today].
///
/// The start date is the first billing day. Month-based intervals are always
/// counted from the start date, so a subscription from the 31st returns to
/// the 31st after a short month instead of drifting.
DateTime nextBillingDate(Subscription subscription, DateTime today) {
  final day = dayOf(today);
  final start = subscription.startDate;
  if (!start.isBefore(day)) return start;

  return switch (subscription.interval) {
    Monthly() => _nextMonthBased(start, day, 1),
    Quarterly() => _nextMonthBased(start, day, 3),
    Yearly() => _nextMonthBased(start, day, 12),
    EveryNWeeks(:final weeks) => _nextWeekBased(start, day, weeks * 7),
  };
}

DateTime _nextMonthBased(DateTime start, DateTime day, int step) {
  final monthsBetween =
      (day.year - start.year) * 12 + (day.month - start.month);
  var periods = max(0, monthsBetween ~/ step - 1);
  var candidate = addMonths(start, periods * step);
  while (candidate.isBefore(day)) {
    periods++;
    candidate = addMonths(start, periods * step);
  }
  return candidate;
}

DateTime _nextWeekBased(DateTime start, DateTime day, int periodDays) {
  // Both values are UTC midnights, so the difference is whole days.
  final elapsedDays = day.difference(start).inDays;
  final periods = (elapsedDays + periodDays - 1) ~/ periodDays;
  return start.add(Duration(days: periods * periodDays));
}
