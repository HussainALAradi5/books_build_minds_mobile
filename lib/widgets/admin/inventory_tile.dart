import 'package:flutter/material.dart';

import '../../utils/shared/formatters.dart';
import '../../models/catalog/book.dart';
import '../../services/admin/admin_service.dart';

class InventoryTile extends StatelessWidget {
  const InventoryTile({
    super.key,
    required this.book,
    required this.service,
    required this.refresh,
    required this.canEdit,
  });

  final Book book;
  final AdminService service;
  final VoidCallback refresh;
  final bool canEdit;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${book.author} · ${book.availableCopies}/${book.copiesTotal} copies',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                formatBhd(book.price),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (canEdit)
                OutlinedButton.icon(
                  onPressed: () => _editPrice(context),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit price'),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _editPrice(BuildContext context) async {
    final input = TextEditingController(text: book.price.toStringAsFixed(3));
    final price = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit book price'),
        content: SizedBox(
          width: 290,
          child: TextField(
            controller: input,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'New price in BHD',
              prefixIcon: Icon(Icons.payments_outlined),
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
              final value = double.tryParse(input.text.trim());
              if (value == null || value <= 0) return;
              Navigator.pop(context, value);
            },
            child: const Text('Save price'),
          ),
        ],
      ),
    );
    input.dispose();
    if (price == null) return;
    try {
      await service.updatePrice(book.slug, price);
      refresh();
    } catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$failure')));
      }
    }
  }
}
