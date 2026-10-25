import 'package:flutter/services.dart';

class NonNegativeNumberFormatter extends TextInputFormatter {
  NonNegativeNumberFormatter({this.decimalPlaces = 0})
    : assert(decimalPlaces >= 0);

  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final pattern = decimalPlaces == 0
        ? RegExp(r'^\d*$')
        : RegExp('^\\d*(?:\\.\\d{0,$decimalPlaces})?\$');
    return pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
