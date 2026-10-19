import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../book_detail/presentation/book_detail_screen.dart';
import '../../../loans/data/loan_service.dart';
import '../../../loans/domain/loan.dart';
import '../../../loans/domain/loan_status.dart';

class LoanTile extends StatelessWidget {
  const LoanTile({
    super.key,
    required this.loan,
    required this.service,
    required this.refresh,
  });

  final Loan loan;
  final LoanService service;
  final VoidCallback refresh;

  @override
  Widget build(BuildContext context) {
    final status = LoanStatusView.parse(loan.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loan.bookTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (status != null)
                  StatusBadge(label: status.label, color: status.color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${loan.kind == 'rent' ? 'Rental' : 'Borrow'} · Due ${formatDate(loan.dueAt)}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BookDetailScreen(slug: loan.bookSlug),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 17),
                  label: const Text('View book'),
                ),
                const Spacer(),
                if (loan.status != 'returned')
                  OutlinedButton.icon(
                    onPressed: () => _return(context),
                    icon: const Icon(
                      Icons.assignment_return_outlined,
                      size: 17,
                    ),
                    label: const Text('Return'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _return(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return book?'),
        content: Text('Mark ${loan.bookTitle} as returned?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Return'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await service.returnBook(loan.bookSlug);
      refresh();
    } catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$failure')));
      }
    }
  }
}
