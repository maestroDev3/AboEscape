import 'package:abo_escape/domain/amount_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAmountToCents', () {
    const valid = {
      '9.99': 999,
      '9,99': 999,
      '10': 1000,
      '0': 0,
      '0,5': 50,
      '1,234.50': 123450,
      '1.234,50': 123450,
      '  12,99 ': 1299,
      '1 234,50': 123450,
    };

    valid.forEach((input, cents) {
      test('parses "$input" as $cents cents', () {
        expect(parseAmountToCents(input), cents);
      });
    });

    const invalid = [
      '',
      '   ',
      'abc',
      '-5',
      '9.999',
      '1.234.5',
      '9,99,9',
      '12a',
      '1,2,3',
    ];

    for (final input in invalid) {
      test('rejects "$input"', () {
        expect(parseAmountToCents(input), isNull);
      });
    }

    test('rejects amounts too large to be a subscription price', () {
      expect(parseAmountToCents('1000000000000'), isNull);
    });
  });
}
