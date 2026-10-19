import 'package:flutter/material.dart';

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
            child: TextField(
              controller: minPrice,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Minimum',
                prefixText: 'BHD ',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: maxPrice,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Maximum',
                prefixText: 'BHD ',
              ),
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
