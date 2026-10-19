import 'package:flutter/material.dart';

import '../data/loan_service.dart';
import '../domain/loan_quote.dart';

class BorrowFlowSheet extends StatefulWidget {
  const BorrowFlowSheet({super.key, required this.slug, required this.loans});

  final String slug;
  final LoanService loans;

  @override
  State<BorrowFlowSheet> createState() => _BorrowFlowSheetState();
}

class _BorrowFlowSheetState extends State<BorrowFlowSheet> {
  late Future<LoanQuote> quote = widget.loans.quote(widget.slug);
  int step = 0;
  bool accepted = false;
  bool busy = false;
  String? error;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: FutureBuilder<LoanQuote>(
        future: quote,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 18),
                const Icon(Icons.error_outline_rounded, size: 35),
                const SizedBox(height: 8),
                Text('${snapshot.error}'),
                TextButton(
                  onPressed: () =>
                      setState(() => quote = widget.loans.quote(widget.slug)),
                  child: const Text('Try again'),
                ),
              ],
            );
          }
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final value = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Borrow this book',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Step ${step + 1} of 3 · ${['Terms', 'Review', 'Confirm'][step]}',
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: (step + 1) / 3),
              const SizedBox(height: 22),
              if (step == 0) ...[
                ...value.terms.map(
                  (term) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 9),
                        Expanded(child: Text(term)),
                      ],
                    ),
                  ),
                ),
                CheckboxListTile(
                  value: accepted,
                  title: const Text('I accept the library terms'),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) =>
                      setState(() => accepted = value ?? false),
                ),
              ] else if (step == 1) ...[
                _fact(
                  Icons.calendar_month_outlined,
                  'Borrow period',
                  '${value.borrowDays} days',
                ),
                _fact(
                  Icons.collections_bookmark_outlined,
                  'Copies available',
                  '${value.availableCopies}',
                ),
                _fact(Icons.payments_outlined, 'Cost', 'Free'),
              ] else ...[
                const Icon(Icons.auto_stories_rounded, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Ready to add this book to your library? Stock is checked again when you confirm.',
                ),
              ],
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (step > 0)
                    TextButton(
                      onPressed: busy ? null : () => setState(() => step--),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed:
                        busy ||
                            (step == 0 && !accepted) ||
                            value.availableCopies == 0
                        ? null
                        : () => _advance(value),
                    icon: busy
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            step == 2
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                    label: Text(step == 2 ? 'Confirm borrow' : 'Continue'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _fact(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      children: [
        Icon(icon, size: 21),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Future<void> _advance(LoanQuote value) async {
    if (step < 2) {
      setState(() => step++);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.loans.borrow(widget.slug, value);
      if (mounted) Navigator.pop(context, true);
    } catch (failure) {
      if (mounted) {
        setState(() {
          error = '$failure';
          quote = widget.loans.quote(widget.slug);
          step = 0;
          accepted = false;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
