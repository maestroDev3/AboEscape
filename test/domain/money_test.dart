import 'package:abo_escape/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('keeps cents and currency', () {
      final money = Money(cents: 1299, currency: 'EUR');

      expect(money.cents, 1299);
      expect(money.currency, 'EUR');
    });

    test('allows zero for free subscriptions', () {
      expect(Money(cents: 0, currency: 'EUR').cents, 0);
    });

    test('rejects negative cents', () {
      expect(() => Money(cents: -1, currency: 'EUR'), throwsArgumentError);
    });

    test('rejects currency codes that are not three uppercase letters', () {
      for (final code in ['', 'EU', 'EURO', 'eur', 'E1R']) {
        expect(
          () => Money(cents: 100, currency: code),
          throwsArgumentError,
          reason: code,
        );
      }
    });

    test('is equal to another value with the same cents and currency', () {
      final a = Money(cents: 999, currency: 'USD');
      final b = Money(cents: 999, currency: 'USD');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differs when cents or currency differ', () {
      final base = Money(cents: 999, currency: 'USD');

      expect(base, isNot(Money(cents: 1000, currency: 'USD')));
      expect(base, isNot(Money(cents: 999, currency: 'EUR')));
    });
  });
}
