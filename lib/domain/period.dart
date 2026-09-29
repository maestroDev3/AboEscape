/// Unit of a [Period].
enum PeriodUnit { days, weeks, months }

/// A span of time such as a minimum term ("24 months") or a notice period
/// ("14 days").
final class Period {
  Period(this.amount, this.unit) {
    if (amount < 1) {
      throw ArgumentError.value(amount, 'amount', 'must be at least 1');
    }
  }

  final int amount;
  final PeriodUnit unit;

  @override
  bool operator ==(Object other) =>
      other is Period && other.amount == amount && other.unit == unit;

  @override
  int get hashCode => Object.hash(amount, unit);

  @override
  String toString() => 'Period($amount ${unit.name})';
}
