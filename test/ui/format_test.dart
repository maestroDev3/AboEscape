import 'package:abo_escape/domain/money.dart';
import 'package:abo_escape/ui/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney', () {
    test('uses German number format and the euro sign for de_DE', () {
      final text = formatMoney(Money(cents: 999, currency: 'EUR'), 'de_DE');

      expect(text, contains('9,99'));
      expect(text, contains('€'));
    });

    test('formats US dollars for en_US', () {
      expect(
        formatMoney(Money(cents: 999, currency: 'USD'), 'en_US'),
        r'$9.99',
      );
    });

    test('formats whole amounts with two decimals', () {
      expect(
        formatMoney(Money(cents: 1000, currency: 'USD'), 'en_US'),
        r'$10.00',
      );
    });
  });

  group('formatAmountForInput', () {
    test('uses the decimal comma for de_DE', () {
      expect(formatAmountForInput(1299, 'de_DE'), '12,99');
    });

    test('uses the decimal point for en and pads cents', () {
      expect(formatAmountForInput(2990, 'en'), '29.90');
      expect(formatAmountForInput(5, 'en'), '0.05');
    });
  });

  group('formatDate', () {
    test('formats a medium date for en_US', () {
      expect(formatDate(DateTime.utc(2026, 1, 15), 'en_US'), 'Jan 15, 2026');
    });
  });

  group('currencyForLocale', () {
    test('returns EUR for Germany', () {
      expect(currencyForLocale('de_DE'), 'EUR');
    });

    test('returns USD for the United States', () {
      expect(currencyForLocale('en_US'), 'USD');
    });

    test('accepts locales written with a hyphen', () {
      expect(currencyForLocale('de-AT'), 'EUR');
    });

    test('falls back to EUR for an unknown locale', () {
      expect(currencyForLocale('xx_XX'), 'EUR');
    });
  });
}
