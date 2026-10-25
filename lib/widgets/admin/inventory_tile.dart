import 'package:flutter/material.dart';

import '../../utils/shared/formatters.dart';
import '../../models/catalog/book.dart';
import '../../services/admin/admin_service.dart';
import '../../app/app_scope.dart';
import '../../services/media/media_service.dart';
import '../shared/image_picker_button.dart';
import 'price_editor_dialog.dart';

class InventoryTile extends StatelessWidget {
  const InventoryTile({
    super.key,
    required this.book,
    required this.service,
    required this.refresh,
    required this.canEdit,
    this.selected,
    this.onSelected,
  });

  final Book book;
  final AdminService service;
  final VoidCallback refresh;
  final bool canEdit;
  final bool? selected;
  final ValueChanged<bool>? onSelected;

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
              if (onSelected != null)
                Checkbox(
                  value: selected ?? false,
                  onChanged: (value) => onSelected!(value ?? false),
                  semanticLabel: 'Select ${book.title}',
                ),
            ],
          ),
          if (AppScope.of(context).session.user?.permissions
                  .contains('book-media:write.one') ??
              false)
            ImagePickerButton(
              label: 'Add book images',
              multiple: true,
              onPicked: (files) async {
                await MediaService(AppScope.of(context).api)
                    .uploadBook(book.bookId, files);
                refresh();
              },
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
    final price = await showDialog<double>(
      context: context,
      builder: (context) => PriceEditorDialog(currentPrice: book.price),
    );
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
