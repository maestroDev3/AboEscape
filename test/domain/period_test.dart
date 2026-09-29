import 'package:abo_escape/domain/period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Period', () {
    test('keeps amount and unit', () {
      final period = Period(3, PeriodUnit.months);

      expect(period.amount, 3);
      expect(period.unit, PeriodUnit.months);
    });

    test('rejects an amount below one', () {
      expect(() => Period(0, PeriodUnit.days), throwsArgumentError);
      expect(() => Period(-2, PeriodUnit.weeks), throwsArgumentError);
    });

    test('is equal to another period with the same amount and unit', () {
      expect(Period(14, PeriodUnit.days), Period(14, PeriodUnit.days));
      expect(
        Period(14, PeriodUnit.days).hashCode,
        Period(14, PeriodUnit.days).hashCode,
      );
      expect(Period(2, PeriodUnit.weeks), isNot(Period(2, PeriodUnit.months)));
    });
  });
}
