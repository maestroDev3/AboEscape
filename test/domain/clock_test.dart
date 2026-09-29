import 'package:abo_escape/domain/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dayOf', () {
    test('returns UTC midnight of a local moment late in the day', () {
      expect(dayOf(DateTime(2026, 3, 29, 23, 59)), DateTime.utc(2026, 3, 29));
    });

    test('returns a UTC value with all time components set to zero', () {
      final day = dayOf(DateTime(2026, 7, 14, 13, 45, 12, 345, 678));

      expect(day.isUtc, isTrue);
      expect(day.hour, 0);
      expect(day.minute, 0);
      expect(day.second, 0);
      expect(day.millisecond, 0);
      expect(day.microsecond, 0);
    });

    test('keeps the calendar day of a UTC moment', () {
      expect(dayOf(DateTime.utc(2026, 10, 25, 1)), DateTime.utc(2026, 10, 25));
    });

    test('maps two moments of the same day across a DST switch to one day', () {
      final beforeSwitch = dayOf(DateTime(2026, 3, 29, 1));
      final afterSwitch = dayOf(DateTime(2026, 3, 29, 23));

      expect(beforeSwitch, afterSwitch);
      expect(beforeSwitch, DateTime.utc(2026, 3, 29));
    });
  });

  group('Clock', () {
    test('can be satisfied by a fixed lambda', () {
      DateTime readTime(Clock clock) => clock();

      expect(readTime(() => DateTime(2026, 1, 1)), DateTime(2026, 1, 1));
    });
  });
}
