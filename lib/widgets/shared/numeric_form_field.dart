import 'package:flutter/material.dart';

import '../../utils/forms/non_negative_number_formatter.dart';

class NumericFormField extends StatelessWidget {
  const NumericFormField({
    super.key,
    required this.controller,
    required this.label,
    this.integer = false,
    this.requiredValue = true,
    this.minimum = 0,
    this.maximum,
    this.prefixText,
    this.prefixIcon,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final bool integer;
  final bool requiredValue;
  final double minimum;
  final double? maximum;
  final String? prefixText;
  final Widget? prefixIcon;
  final String? errorText;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: !integer),
    inputFormatters: [
      NonNegativeNumberFormatter(decimalPlaces: integer ? 0 : 3),
    ],
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
    ),
    validator: (raw) {
      if (raw == null || raw.trim().isEmpty) {
        return requiredValue ? '$label is required' : null;
      }
      final value = double.tryParse(raw);
      if (value == null ||
          !value.isFinite ||
          value < minimum ||
          (maximum != null && value > maximum!)) {
        return errorText ??
            'Enter a value from $minimum${maximum == null ? '' : ' to $maximum'}';
      }
      return null;
    },
  );
}
