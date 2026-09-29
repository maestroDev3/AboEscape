/// How often a subscription is billed; sealed so every calculation handles
/// all variants.
sealed class BillingInterval {
  const BillingInterval();
}

/// Billed every month on the start day (or the last day of shorter months).
final class Monthly extends BillingInterval {
  const Monthly();

  @override
  bool operator ==(Object other) => other is Monthly;

  @override
  int get hashCode => (Monthly).hashCode;
}

/// Billed every three months.
final class Quarterly extends BillingInterval {
  const Quarterly();

  @override
  bool operator ==(Object other) => other is Quarterly;

  @override
  int get hashCode => (Quarterly).hashCode;
}

/// Billed once a year.
final class Yearly extends BillingInterval {
  const Yearly();

  @override
  bool operator ==(Object other) => other is Yearly;

  @override
  int get hashCode => (Yearly).hashCode;
}

/// Billed every [weeks] weeks, e.g. every 4 weeks.
final class EveryNWeeks extends BillingInterval {
  EveryNWeeks(this.weeks) {
    if (weeks < 1) {
      throw ArgumentError.value(weeks, 'weeks', 'must be at least 1');
    }
  }

  final int weeks;

  @override
  bool operator ==(Object other) =>
      other is EveryNWeeks && other.weeks == weeks;

  @override
  int get hashCode => Object.hash(EveryNWeeks, weeks);
}
