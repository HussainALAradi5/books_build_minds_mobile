import 'package:flutter/material.dart';

import '../../utils/shared/formatters.dart';
import '../shared/status_badge.dart';
import '../../services/checkout/transaction_service.dart';
import '../../models/checkout/library_transaction.dart';
import '../../enums/checkout/transaction_status.dart';
import '../../services/receipts/receipt_service.dart';
import 'transaction_details_dialog.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    required this.service,
    required this.refresh,
    required this.receipts,
  });

  final LibraryTransaction item;
  final TransactionService service;
  final VoidCallback refresh;
  final ReceiptService receipts;

  @override
  Widget build(BuildContext context) {
    final status = TransactionStatusView.parse(item.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.bookTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (status != null)
                  StatusBadge(label: status.label, color: status.color),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '${item.kind == 'rental' ? 'Rental' : 'Purchase'} · '
              '${formatBhd(item.amountMinor / item.currencyScale)}',
            ),
            if (item.failureReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(item.failureReason!),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      TransactionDetailsDialog(id: item.id, service: service),
                ),
                icon: const Icon(Icons.info_outline),
                label: const Text('Details'),
              ),
            ),
            if (item.status == 'pending')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    try {
                      await service.sync(item.id);
                      refresh();
                    } catch (failure) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$failure')));
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh status'),
                ),
              ),
            if (item.status == 'completed')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    try {
                      final saved = await receipts.saveTransaction(item.id);
                      if (context.mounted && saved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt saved.')),
                        );
                      }
                    } catch (failure) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$failure')));
                      }
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Save receipt'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
