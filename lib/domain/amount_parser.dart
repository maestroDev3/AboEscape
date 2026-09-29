/// Characters users type between digit groups, including the no-break spaces
/// that some keyboards and locales insert.
final _spaces = RegExp('[\\s  ]');
final _allowed = RegExp(r'^[0-9.,]+$');
final _separator = RegExp('[.,]');

/// Largest number of whole units accepted, to keep prices plausible.
const _maxIntegerDigits = 9;

/// Parses a price typed by the user into cents without ever using `double`.
///
/// Accepts both `.` and `,` as decimal separator (the last separator followed
/// by one or two digits) and the other one as thousands separator. Returns
/// null for anything ambiguous or invalid, e.g. negative values or more than
/// two decimals.
int? parseAmountToCents(String input) {
  final compact = input.replaceAll(_spaces, '');
  if (compact.isEmpty || !_allowed.hasMatch(compact)) return null;

  final lastSeparator = compact.lastIndexOf(_separator);
  if (lastSeparator == -1) return _toCents(compact, '');

  final decimalSeparator = compact[lastSeparator];
  final fraction = compact.substring(lastSeparator + 1);
  final whole = compact.substring(0, lastSeparator);
  if (fraction.isEmpty || fraction.length > 2) return null;
  if (whole.contains(decimalSeparator)) return null;

  final groupSeparator = decimalSeparator == '.' ? ',' : '.';
  final integerDigits = _withoutGrouping(whole, groupSeparator);
  if (integerDigits == null) return null;
  return _toCents(integerDigits, fraction);
}

/// Removes thousands separators if they split [whole] into groups of three.
String? _withoutGrouping(String whole, String groupSeparator) {
  if (!whole.contains(groupSeparator)) return whole;
  final groups = whole.split(groupSeparator);
  final first = groups.first;
  if (first.isEmpty || first.length > 3) return null;
  if (groups.skip(1).any((group) => group.length != 3)) return null;
  return groups.join();
}

int? _toCents(String integerDigits, String fraction) {
  final digits = integerDigits.isEmpty ? '0' : integerDigits;
  if (digits.length > _maxIntegerDigits) return null;
  return int.parse(digits) * 100 + int.parse(fraction.padRight(2, '0'));
}
