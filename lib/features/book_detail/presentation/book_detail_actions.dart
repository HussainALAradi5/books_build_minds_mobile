import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../checkout/data/transaction_service.dart';
import '../../checkout/presentation/checkout_sheet.dart';
import '../../loans/data/loan_service.dart';
import '../../loans/presentation/borrow_flow_sheet.dart';
import '../domain/creator_profile.dart';
import 'book_detail_controller.dart';
import 'widgets/creator_info_dialog.dart';

class BookDetailActions {
  const BookDetailActions({
    required this.context,
    required this.slug,
    required this.api,
    required this.controller,
    required this.loans,
    required this.transactions,
    required this.onSignedIn,
  });

  final BuildContext context;
  final String slug;
  final ApiClient api;
  final BookDetailController controller;
  final LoanService loans;
  final TransactionService transactions;
  final VoidCallback onSignedIn;

  Future<void> signIn() async {
    final signed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
    if (signed == true && context.mounted) onSignedIn();
  }

  Future<void> borrow() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BorrowFlowSheet(slug: slug, loans: loans),
    );
    if (changed == true) {
      await controller.refreshAfterAction();
      message('Book borrowed. Enjoy reading!');
    }
  }

  Future<void> returnBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Return this book?'),
        content: const Text('Your active loan will be marked as returned.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Keep reading'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialog).colorScheme.error,
            ),
            child: const Text('Return book'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.returnBook();
      message('Book returned. Thank you!');
    } catch (failure) {
      message('$failure');
    }
  }

  Future<void> checkout(String kind) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CheckoutSheet(
        slug: slug,
        kind: kind,
        loans: loans,
        transactions: transactions,
      ),
    );
    await controller.refreshAfterAction();
  }

  Future<void> printBook() async {
    final address = api.uri('/book/${Uri.encodeComponent(slug)}/print');
    if (!await launchUrl(address, mode: LaunchMode.externalApplication)) {
      message('Could not open the book PDF.');
    }
  }

  void creator(String title, CreatorProfile profile) => showDialog<void>(
    context: context,
    builder: (_) => CreatorInfoDialog(title: title, creator: profile),
  );

  void message(String text) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }
}
