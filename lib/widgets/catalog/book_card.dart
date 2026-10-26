import 'package:flutter/material.dart';

import '../../shared/network/api_client.dart';
import '../../utils/shared/formatters.dart';
import '../shared/book_cover.dart';
import '../shared/status_badge.dart';
import '../../models/catalog/book.dart';
import '../../enums/catalog/book_condition.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.api,
    required this.onTap,
    this.compact = false,
  });

  final Book book;
  final ApiClient api;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: compact ? _compact(context) : _grid(context),
      ),
    ),
  );

  Widget _grid(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BookCover(book: book, api: api, height: 168),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (book.condition != null)
              StatusBadge(
                label: book.condition!.label,
                color: book.condition!.color,
              ),
            if (constraints.maxWidth >= 150) ...[
              const Spacer(),
              Icon(Icons.star_rounded, color: Colors.orange.shade700, size: 15),
              Text(
                book.averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 9),
      Text(
        book.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 3),
      Text(
        book.categories.isEmpty
            ? book.author
            : '${book.author} · ${book.categories.first.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const Spacer(),
      Text(
        formatBhd(book.price),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 8),
    ],
  );

  Widget _compact(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 90,
        child: BookCover(book: book, api: api, height: 120),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            if (book.condition != null)
              StatusBadge(
                label: book.condition!.label,
                color: book.condition!.color,
              ),
            const SizedBox(height: 8),
            Text(
              formatBhd(book.price),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      const Icon(Icons.chevron_right_rounded),
    ],
  );
}
