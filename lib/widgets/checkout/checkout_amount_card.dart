import 'package:flutter/material.dart';

import '../../utils/shared/formatters.dart';

class CheckoutAmountCard extends StatelessWidget {
  const CheckoutAmountCard({
    super.key,
    required this.amountMinor,
    required this.currencyScale,
    required this.kind,
    required this.rentalDays,
  });

  final int amountMinor;
  final int currencyScale;
  final String kind;
  final int rentalDays;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.payments_outlined),
      title: Text(
        formatMinorBhd(amountMinor, currencyScale),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        kind == 'rental' ? '$rentalDays-day rental' : 'Purchase price',
      ),
    ),
  );
}
