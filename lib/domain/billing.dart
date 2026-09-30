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

/// The billing day with [index] of [subscription]; index 0 is the start date.
///
/// Month-based intervals are always counted from the start date, so a
/// subscription from the 31st returns to the 31st after a short month instead
/// of drifting.
DateTime billingDateAt(Subscription subscription, int index) {
  final start = subscription.startDate;
  return switch (subscription.interval) {
    Monthly() => addMonths(start, index),
    Quarterly() => addMonths(start, index * 3),
    Yearly() => addMonths(start, index * 12),
    // UTC midnights, so whole days never shift across daylight saving time.
    EveryNWeeks(:final weeks) => start.add(Duration(days: index * weeks * 7)),
  };
}

/// Index of the first billing day of [subscription] on or after [day].
int firstBillingIndexOnOrAfter(Subscription subscription, DateTime day) {
  final start = subscription.startDate;
  if (!start.isBefore(day)) return 0;

  final monthsBetween =
      (day.year - start.year) * 12 + (day.month - start.month);
  final estimate = switch (subscription.interval) {
    Monthly() => monthsBetween,
    Quarterly() => monthsBetween ~/ 3,
    Yearly() => monthsBetween ~/ 12,
    EveryNWeeks(:final weeks) => day.difference(start).inDays ~/ (weeks * 7),
  };
  var index = max(0, estimate - 1);
  while (billingDateAt(subscription, index).isBefore(day)) {
    index++;
  }
  return index;
}

/// First billing day of [subscription] on or after the day of [today].
///
/// The start date is the first billing day.
DateTime nextBillingDate(Subscription subscription, DateTime today) =>
    billingDateAt(
      subscription,
      firstBillingIndexOnOrAfter(subscription, dayOf(today)),
    );

/// Returns [subscriptions] ordered by their next billing date after [today],
/// ties broken by name (case-insensitive); the input stays unchanged.
List<Subscription> sortByNextBillingDate(
  List<Subscription> subscriptions,
  DateTime today,
) {
  final withDates = [
    for (final subscription in subscriptions)
      (subscription: subscription, next: nextBillingDate(subscription, today)),
  ];
  withDates.sort((a, b) {
    final byDate = a.next.compareTo(b.next);
    if (byDate != 0) return byDate;
    return a.subscription.name.toLowerCase().compareTo(
      b.subscription.name.toLowerCase(),
    );
  });
  return [for (final entry in withDates) entry.subscription];
}
