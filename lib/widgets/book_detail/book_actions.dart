import 'package:flutter/material.dart';

class BookActions extends StatelessWidget {
  const BookActions({
    super.key,
    required this.signedIn,
    required this.available,
    required this.hasLoan,
    required this.busy,
    required this.onBorrow,
    required this.onReturn,
    required this.onPurchase,
    required this.onRent,
    required this.onPrint,
    required this.onCodes,
    required this.onSignIn,
  });

  final bool signedIn;
  final bool available;
  final bool hasLoan;
  final bool busy;
  final VoidCallback onBorrow;
  final VoidCallback onReturn;
  final VoidCallback onPurchase;
  final VoidCallback onRent;
  final VoidCallback onPrint;
  final VoidCallback onCodes;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: busy || !available
                  ? null
                  : signedIn
                  ? onPurchase
                  : onSignIn,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Purchase'),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Book PDF'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 9),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: onCodes,
          icon: const Icon(Icons.qr_code_2_rounded),
          label: const Text('QR and barcode'),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : hasLoan
                  ? onReturn
                  : available
                  ? signedIn
                        ? onBorrow
                        : onSignIn
                  : null,
              icon: Icon(
                hasLoan
                    ? Icons.assignment_return_outlined
                    : Icons.auto_stories_outlined,
                size: 18,
              ),
              label: Text(hasLoan ? 'Return' : 'Borrow'),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy || !available || hasLoan
                  ? null
                  : signedIn
                  ? onRent
                  : onSignIn,
              icon: const Icon(Icons.schedule_outlined, size: 18),
              label: const Text('Rent'),
            ),
          ),
        ],
      ),
    ],
  );
}
