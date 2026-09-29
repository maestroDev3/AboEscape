import 'package:intl/intl.dart';

import '../domain/money.dart';

/// Currency used when the locale does not name one.
const fallbackCurrency = 'EUR';

/// Formats [money] for display in [locale], e.g. `9,99 €` or `$9.99`.
///
/// The division to a `double` happens only here, for display; amounts are
/// never stored or summed as `double`.
String formatMoney(Money money, String locale) => NumberFormat.simpleCurrency(
  locale: _normalize(locale),
  name: money.currency,
).format(money.cents / 100);

/// Formats a day as a medium date in [locale], e.g. `Jan 15, 2026`.
String formatDate(DateTime day, String locale) =>
    DateFormat.yMMMd(_normalize(locale)).format(day);

/// ISO 4217 code of the currency used in [locale], e.g. `EUR` for `de_DE`.
String currencyForLocale(String locale) {
  final verified = Intl.verifiedLocale(
    _normalize(locale),
    NumberFormat.localeExists,
    onFailure: (_) => null,
  );
  if (verified == null) return fallbackCurrency;
  return NumberFormat.simpleCurrency(locale: verified).currencyName ??
      fallbackCurrency;
}

String _normalize(String locale) => locale.replaceAll('-', '_');

/// Writes [cents] as editable text for a price field, using the decimal
/// separator of [locale], e.g. `12,99` for `de_DE`.
String formatAmountForInput(int cents, String locale) {
  final separator = NumberFormat.decimalPattern(
    _normalize(locale),
  ).symbols.DECIMAL_SEP;
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '${cents ~/ 100}$separator$fraction';
}
