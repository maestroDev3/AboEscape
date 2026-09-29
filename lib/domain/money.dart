/// An amount of money in integer cents, so sums never suffer from floating
/// point rounding.
final class Money {
  Money({required this.cents, required this.currency}) {
    if (cents < 0) {
      throw ArgumentError.value(cents, 'cents', 'must not be negative');
    }
    if (!_currencyCode.hasMatch(currency)) {
      throw ArgumentError.value(currency, 'currency', 'must be an ISO 4217 code');
    }
  }

  static final _currencyCode = RegExp(r'^[A-Z]{3}$');

  /// Amount in the smallest unit of the currency (cents).
  final int cents;

  /// ISO 4217 currency code, e.g. `EUR`.
  final String currency;

  @override
  bool operator ==(Object other) =>
      other is Money && other.cents == cents && other.currency == currency;

  @override
  int get hashCode => Object.hash(cents, currency);

  @override
  String toString() => 'Money($cents $currency)';
}
