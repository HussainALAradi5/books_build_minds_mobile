import 'package:flutter/material.dart';

import '../shared/numeric_form_field.dart';

class PriceEditorDialog extends StatefulWidget {
  const PriceEditorDialog({super.key, required this.currentPrice});

  final double currentPrice;

  @override
  State<PriceEditorDialog> createState() => _PriceEditorDialogState();
}

class _PriceEditorDialogState extends State<PriceEditorDialog> {
  final formKey = GlobalKey<FormState>();
  late final input = TextEditingController(
    text: widget.currentPrice.toStringAsFixed(3),
  );

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit book price'),
    content: SizedBox(
      width: 290,
      child: Form(
        key: formKey,
        child: NumericFormField(
          controller: input,
          label: 'New price in BHD',
          minimum: .001,
          errorText: 'Enter a positive price',
          prefixIcon: const Icon(Icons.payments_outlined),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (formKey.currentState?.validate() != true) return;
          Navigator.pop(context, double.parse(input.text.trim()));
        },
        child: const Text('Save price'),
      ),
    ],
  );
}
