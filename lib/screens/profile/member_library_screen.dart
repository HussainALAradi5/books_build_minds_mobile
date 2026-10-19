import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../utils/shared/formatters.dart';
import '../../widgets/shared/paged_records.dart';
import '../../widgets/shared/state_panel.dart';
import '../auth/auth_screen.dart';
import '../book_detail/book_detail_screen.dart';
import '../../services/checkout/transaction_service.dart';
import '../../models/checkout/library_transaction.dart';
import '../../services/loans/loan_service.dart';
import '../../models/loans/loan.dart';
import '../../services/profile/profile_service.dart';
import '../../widgets/profile/loan_tile.dart';
import '../../widgets/profile/transaction_tile.dart';

class MemberLibraryScreen extends StatelessWidget {
  const MemberLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final user = scope.session.user;
    if (user == null) {
      return StatePanel(
        icon: Icons.collections_bookmark_outlined,
        title: 'Your own reading space',
        message: 'Sign in to see loans, purchased books, transactions, and activity.',
        actionLabel: 'Sign in',
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
        ),
      );
    }
    final loanService = LoanService(scope.api);
    final profileService = ProfileService(scope.api);
    final transactionService = TransactionService(scope.api);
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR READING SPACE',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Your library',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Text('Every story, kept close.'),
              ],
            ),
          ),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Loans'),
              Tab(icon: Icon(Icons.bookmark_outline_rounded), text: 'Owned'),
              Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: 'Transactions',
              ),
              Tab(icon: Icon(Icons.history_rounded), text: 'Activity'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                PagedRecords<Loan>(
                  load: (page) => loanService.list(user.userId, page: page),
                  itemBuilder: (context, loan, refresh) => LoanTile(
                    loan: loan,
                    service: loanService,
                    refresh: refresh,
                  ),
                  emptyTitle: 'No loans yet',
                  emptyMessage: 'Borrow a book and it will appear here.',
                ),
                PagedRecords(
                  load: (page) => profileService.owned(user.userId, page),
                  itemBuilder: (context, book, refresh) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.auto_stories_rounded),
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => BookDetailScreen(slug: book.slug),
                        ),
                      ),
                    ),
                  ),
                  emptyTitle: 'No books owned yet',
                  emptyMessage: 'Books you purchase will appear here.',
                ),
                PagedRecords<LibraryTransaction>(
                  load: (page) => transactionService.list(page: page),
                  itemBuilder: (context, item, refresh) => TransactionTile(
                    item: item,
                    service: transactionService,
                    refresh: refresh,
                  ),
                  emptyTitle: 'No transactions yet',
                  emptyMessage:
                      'Sandbox purchases and rentals will appear here.',
                ),
                PagedRecords(
                  load: (page) => profileService.activities(user.userId, page),
                  itemBuilder: (context, item, refresh) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.timeline_rounded),
                      title: Text(item.bookTitle),
                      subtitle: Text(
                        '${item.action} · ${formatDate(item.occurredAt)}',
                      ),
                    ),
                  ),
                  emptyTitle: 'No activity yet',
                  emptyMessage: 'Your library journey will appear here.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
