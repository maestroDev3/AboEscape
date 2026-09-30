import 'dart:math';

import 'billing.dart';
import 'clock.dart';
import 'period.dart';
import 'subscription.dart';

/// When a subscription must be cancelled at the latest and when it then ends.
final class CancellationDeadline {
  const CancellationDeadline({
    required this.lastDayToCancel,
    required this.contractEnd,
  });

  /// Last day the cancellation must reach the provider.
  final DateTime lastDayToCancel;

  /// Last day of the contract if cancelled in time.
  final DateTime contractEnd;

  @override
  bool operator ==(Object other) =>
      other is CancellationDeadline &&
      other.lastDayToCancel == lastDayToCancel &&
      other.contractEnd == contractEnd;

  @override
  int get hashCode => Object.hash(lastDayToCancel, contractEnd);

  @override
  String toString() =>
      'CancellationDeadline(cancel by $lastDayToCancel, ends $contractEnd)';
}

/// The next cancellation deadline of [subscription] that is still reachable
/// on the day of [today].
///
/// Decision 2026-09-30: after the minimum term the contract can end on the
/// day before any billing date; the last day to cancel is that billing date
/// minus the notice period minus one day.
CancellationDeadline cancellationDeadline(
  Subscription subscription,
  DateTime today,
) {
  final day = dayOf(today);
  final earliestEnd = switch (subscription.minimumTerm) {
    final term? => _add(subscription.startDate, term),
    null => subscription.startDate,
  };
  // A period end on or before today can never be cancelled in time.
  final tomorrow = day.add(const Duration(days: 1));
  var index = max(
    1,
    max(
      firstBillingIndexOnOrAfter(subscription, earliestEnd),
      firstBillingIndexOnOrAfter(subscription, tomorrow),
    ),
  );

  while (true) {
    final boundary = billingDateAt(subscription, index);
    final lastDayToCancel = _subtract(
      boundary,
      subscription.noticePeriod,
    ).subtract(const Duration(days: 1));
    if (!lastDayToCancel.isBefore(day)) {
      return CancellationDeadline(
        lastDayToCancel: lastDayToCancel,
        contractEnd: boundary.subtract(const Duration(days: 1)),
      );
    }
    index++;
  }
}

DateTime _add(DateTime day, Period period) => switch (period.unit) {
  PeriodUnit.months => addMonths(day, period.amount),
  PeriodUnit.weeks => day.add(Duration(days: period.amount * 7)),
  PeriodUnit.days => day.add(Duration(days: period.amount)),
};

DateTime _subtract(DateTime day, Period? period) => switch (period) {
  null => day,
  Period(unit: PeriodUnit.months, :final amount) => addMonths(day, -amount),
  Period(unit: PeriodUnit.weeks, :final amount) => day.subtract(
    Duration(days: amount * 7),
  ),
  Period(unit: PeriodUnit.days, :final amount) => day.subtract(
    Duration(days: amount),
  ),
};
