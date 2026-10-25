import 'package:flutter/material.dart';

import '../../shared/numeric_form_field.dart';

class PriceRangeFields extends StatelessWidget {
  const PriceRangeFields({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    this.error,
  });

  final TextEditingController minPrice;
  final TextEditingController maxPrice;
  final String? error;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('PRICE RANGE · BHD', style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: NumericFormField(
              controller: minPrice,
              label: 'Minimum',
              requiredValue: false,
              minimum: .001,
              prefixText: 'BHD ',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NumericFormField(
              controller: maxPrice,
              label: 'Maximum',
              requiredValue: false,
              minimum: .001,
              prefixText: 'BHD ',
            ),
          ),
        ],
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
    ],
  );
}
