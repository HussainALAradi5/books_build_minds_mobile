import 'package:flutter/material.dart';

import '../../models/checkout/library_transaction.dart';
import '../../services/checkout/transaction_service.dart';
import '../../utils/shared/formatters.dart';
import '../shared/status_badge.dart';
import '../../enums/checkout/transaction_status.dart';

class TransactionDetailsDialog extends StatelessWidget {
  const TransactionDetailsDialog({
    super.key,
    required this.id,
    required this.service,
  });

  final String id;
  final TransactionService service;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Transaction details'),
    content: SizedBox(
      width: 360,
      child: FutureBuilder<LibraryTransaction>(
        future: service.detail(id),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('${snapshot.error}');
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = snapshot.data!;
          final status = TransactionStatusView.parse(item.status);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.bookTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (status != null)
                StatusBadge(label: status.label, color: status.color),
              const SizedBox(height: 12),
              Text('Type: ${item.kind == 'rental' ? 'Rental' : 'Purchase'}'),
              Text(
                'Amount: ${formatBhd(item.amountMinor / item.currencyScale)}',
              ),
              SelectableText('Reference: ${item.id}'),
              if (item.failureReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(item.failureReason!),
                ),
            ],
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}
