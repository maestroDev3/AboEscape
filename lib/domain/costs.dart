import 'billing_interval.dart';
import 'money.dart';
import 'subscription.dart';
import 'subscription_category.dart';

/// What subscriptions in one currency cost per month and per year.
final class CostSummary {
  const CostSummary({required this.monthly, required this.yearly});

  final Money monthly;
  final Money yearly;

  @override
  bool operator ==(Object other) =>
      other is CostSummary &&
      other.monthly == monthly &&
      other.yearly == yearly;

  @override
  int get hashCode => Object.hash(monthly, yearly);

  @override
  String toString() => 'CostSummary($monthly / month, $yearly / year)';
}

/// Sums the costs of [subscriptions], one [CostSummary] per currency ordered
/// by currency code.
///
/// Every price is first turned into an exact yearly amount (a fraction of
/// cents); the yearly and monthly totals are rounded once, half up.
List<CostSummary> costSummaries(List<Subscription> subscriptions) {
  final yearlyByCurrency = <String, _Fraction>{};
  for (final subscription in subscriptions) {
    final currency = subscription.price.currency;
    yearlyByCurrency[currency] =
        (yearlyByCurrency[currency] ?? _Fraction.zero) +
        _yearlyCents(subscription);
  }

  final currencies = yearlyByCurrency.keys.toList()..sort();
  return [
    for (final currency in currencies)
      if (yearlyByCurrency[currency] case final yearly?)
        _summarize(yearly, currency),
  ];
}

/// What the subscriptions of one category cost, in one currency.
final class CategoryCost {
  const CategoryCost({required this.category, required this.costs});

  final SubscriptionCategory category;
  final CostSummary costs;

  @override
  bool operator ==(Object other) =>
      other is CategoryCost &&
      other.category == category &&
      other.costs == costs;

  @override
  int get hashCode => Object.hash(category, costs);

  @override
  String toString() => 'CategoryCost(${category.name}, $costs)';
}

/// Costs per category and currency, ordered by currency code, then by yearly
/// cost (highest first), ties in category order.
List<CategoryCost> categoryCosts(List<Subscription> subscriptions) {
  final yearlyByGroup = <(String, SubscriptionCategory), _Fraction>{};
  for (final subscription in subscriptions) {
    final group = (subscription.price.currency, subscription.category);
    yearlyByGroup[group] =
        (yearlyByGroup[group] ?? _Fraction.zero) + _yearlyCents(subscription);
  }

  final groups = [
    for (final MapEntry(key: (currency, category), value: yearly)
        in yearlyByGroup.entries)
      (
        currency: currency,
        cost: CategoryCost(
          category: category,
          costs: _summarize(yearly, currency),
        ),
      ),
  ];
  groups.sort((a, b) {
    final byCurrency = a.currency.compareTo(b.currency);
    if (byCurrency != 0) return byCurrency;
    final byCost = b.cost.costs.yearly.cents.compareTo(
      a.cost.costs.yearly.cents,
    );
    if (byCost != 0) return byCost;
    return a.cost.category.index.compareTo(b.cost.category.index);
  });
  return [for (final group in groups) group.cost];
}

/// Rounds an exact yearly amount into monthly and yearly totals.
CostSummary _summarize(_Fraction yearly, String currency) => CostSummary(
  monthly: Money(cents: yearly.divideBy(12).roundHalfUp(), currency: currency),
  yearly: Money(cents: yearly.roundHalfUp(), currency: currency),
);

/// Average weeks per year in the Gregorian calendar (365.2425 / 7), as
/// numerator and denominator.
const _weeksPerYearNumerator = 521775;
const _weeksPerYearDenominator = 10000;

_Fraction _yearlyCents(Subscription subscription) {
  final cents = subscription.price.cents;
  return switch (subscription.interval) {
    Monthly() => _Fraction(cents * 12, 1),
    Quarterly() => _Fraction(cents * 4, 1),
    Yearly() => _Fraction(cents, 1),
    EveryNWeeks(:final weeks) => _Fraction(
      cents * _weeksPerYearNumerator,
      _weeksPerYearDenominator * weeks,
    ),
  };
}

/// Exact non-negative fraction, so sums of cents never lose precision.
final class _Fraction {
  factory _Fraction(int numerator, int denominator) =>
      _Fraction._reduced(BigInt.from(numerator), BigInt.from(denominator));

  /// Keeps numbers small by dividing both parts by their greatest common
  /// divisor (the denominator is never zero, so neither is the divisor).
  factory _Fraction._reduced(BigInt numerator, BigInt denominator) {
    final divisor = numerator.gcd(denominator);
    return _Fraction._raw(numerator ~/ divisor, denominator ~/ divisor);
  }

  const _Fraction._raw(this._numerator, this._denominator);

  static final zero = _Fraction(0, 1);

  final BigInt _numerator;
  final BigInt _denominator;

  _Fraction operator +(_Fraction other) => _Fraction._reduced(
    _numerator * other._denominator + other._numerator * _denominator,
    _denominator * other._denominator,
  );

  _Fraction divideBy(int divisor) =>
      _Fraction._reduced(_numerator, _denominator * BigInt.from(divisor));

  /// Rounds to the nearest whole number; exact halves round up.
  int roundHalfUp() =>
      ((_numerator * BigInt.two + _denominator) ~/ (_denominator * BigInt.two))
          .toInt();
}
