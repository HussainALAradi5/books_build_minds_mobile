import 'package:flutter/material.dart';

import '../../enums/catalog/book_condition.dart';
import '../../models/catalog/book.dart';
import '../../screens/book_detail/book_detail_screen.dart';
import '../../utils/shared/formatters.dart';
import '../shared/status_badge.dart';

class InventoryGridCard extends StatelessWidget {
  const InventoryGridCard({
    super.key,
    required this.book,
    required this.selected,
    required this.onSelected,
  });
  final Book book;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BookDetailScreen(slug: book.slug),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Checkbox(
                  value: selected,
                  onChanged: (value) => onSelected(value ?? false),
                ),
              ],
            ),
            const Spacer(),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 7),
            if (book.condition != null)
              StatusBadge(
                label: book.condition!.label,
                color: book.condition!.color,
              ),
            const SizedBox(height: 7),
            Text(
              '${book.availableCopies}/${book.copiesTotal} copies · ${formatBhd(book.price)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
