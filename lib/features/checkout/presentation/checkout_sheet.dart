import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/request_key.dart';
import '../../loans/data/loan_service.dart';
import '../../loans/domain/loan_quote.dart';
import '../data/transaction_service.dart';
import '../domain/library_transaction.dart';

class CheckoutSheet extends StatefulWidget {
  const CheckoutSheet({
    super.key,
    required this.slug,
    required this.kind,
    required this.loans,
    required this.transactions,
  });

  final String slug;
  final String kind;
  final LoanService loans;
  final TransactionService transactions;

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  late Future<LoanQuote> quote = widget.loans.quote(widget.slug);
  final requestKey = newRequestKey();
  LibraryTransaction? transaction;
  bool accepted = false;
  bool busy = false;
  String? error;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      child: FutureBuilder<LoanQuote>(
        future: quote,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('${snapshot.error}');
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 170,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final value = snapshot.data!;
          final minor = widget.kind == 'purchase'
              ? value.purchaseAmountMinor
              : value.rentalAmountMinor;
          final amount = (minor / value.currencyScale).toStringAsFixed(3);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.kind == 'purchase' ? 'Make it yours' : 'Rent this book',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Test checkout · No card details are entered in this app.',
              ),
              const SizedBox(height: 22),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(
                    '$amount BHD',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    widget.kind == 'rental'
                        ? '${value.rentalDays}-day rental'
                        : 'Purchase price',
                  ),
                ),
              ),
              if (transaction == null) ...[
                const SizedBox(height: 12),
                ...value.terms.map(
                  (term) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $term'),
                  ),
                ),
                CheckboxListTile(
                  value: accepted,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I accept the current terms'),
                  onChanged: (v) => setState(() => accepted = v ?? false),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Text('Server status: ${transaction!.status}'),
                if (transaction!.failureReason != null)
                  Text(transaction!.failureReason!),
              ],
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: busy || (transaction == null && !accepted)
                      ? null
                      : () => transaction == null ? _checkout(value) : _sync(),
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          transaction == null
                              ? Icons.open_in_new_rounded
                              : Icons.refresh_rounded,
                        ),
                  label: Text(
                    transaction == null
                        ? 'Open secure test checkout'
                        : 'Refresh server status',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  Future<void> _checkout(LoanQuote value) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.transactions.checkout(
        widget.slug,
        widget.kind,
        value,
        requestKey,
      );
      if (!mounted) return;
      setState(() => transaction = result);
      final address = Uri.tryParse(result.checkoutUrl ?? '');
      if (address != null && address.scheme == 'https') {
        await launchUrl(address, mode: LaunchMode.externalApplication);
      }
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _sync() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.transactions.sync(transaction!.id);
      if (mounted) setState(() => transaction = result);
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
