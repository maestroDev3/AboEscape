import 'package:abo_escape/domain/billing_interval.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillingInterval', () {
    test('fixed intervals are equal to new instances of the same kind', () {
      expect(const Monthly(), const Monthly());
      expect(const Quarterly(), const Quarterly());
      expect(const Yearly(), const Yearly());
      expect(const Monthly().hashCode, const Monthly().hashCode);
    });

    test('different kinds are not equal', () {
      expect(const Monthly(), isNot(const Quarterly()));
      expect(const Quarterly(), isNot(const Yearly()));
    });

    test('every n weeks compares by the number of weeks', () {
      expect(EveryNWeeks(2), EveryNWeeks(2));
      expect(EveryNWeeks(2).hashCode, EveryNWeeks(2).hashCode);
      expect(EveryNWeeks(2), isNot(EveryNWeeks(3)));
    });

    test('every n weeks rejects fewer than one week', () {
      expect(() => EveryNWeeks(0), throwsArgumentError);
      expect(() => EveryNWeeks(-1), throwsArgumentError);
    });

    test('can be switched over exhaustively without a default branch', () {
      String describe(BillingInterval interval) => switch (interval) {
        Monthly() => 'monthly',
        Quarterly() => 'quarterly',
        Yearly() => 'yearly',
        EveryNWeeks(:final weeks) => 'every $weeks weeks',
      };

      expect(describe(const Monthly()), 'monthly');
      expect(describe(EveryNWeeks(3)), 'every 3 weeks');
    });
  });
}
