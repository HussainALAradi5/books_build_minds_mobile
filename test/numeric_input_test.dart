import 'package:flutter_test/flutter_test.dart';
import 'package:books_build_minds_mobile/utils/forms/non_negative_number_formatter.dart';

void main() {
  test('shared numeric input rejects negatives and excess precision', () {
    final decimal = NonNegativeNumberFormatter(decimalPlaces: 3);
    const old = TextEditingValue(text: '12.345');
    expect(
      decimal
          .formatEditUpdate(old, const TextEditingValue(text: '-12.345'))
          .text,
      old.text,
    );
    expect(
      decimal
          .formatEditUpdate(old, const TextEditingValue(text: '12.3456'))
          .text,
      old.text,
    );
    expect(
      decimal.formatEditUpdate(old, const TextEditingValue(text: '12.34')).text,
      '12.34',
    );

    final integer = NonNegativeNumberFormatter();
    expect(
      integer
          .formatEditUpdate(
            const TextEditingValue(text: '1'),
            const TextEditingValue(text: '1.5'),
          )
          .text,
      '1',
    );
  });
}
