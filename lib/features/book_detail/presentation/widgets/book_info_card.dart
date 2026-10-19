import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../catalog/domain/book_condition.dart';
import '../../domain/book_detail.dart';

class BookInfoCard extends StatelessWidget {
  const BookInfoCard({super.key, required this.detail});

  final BookDetail detail;

  @override
  Widget build(BuildContext context) {
    final book = detail.book;
    final color = Theme.of(context).colorScheme;
    final available = book.copiesTotal == 0
        ? 0.0
        : (book.availableCopies / book.copiesTotal).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'ABOUT THIS BOOK',
                    style: TextStyle(
                      letterSpacing: 1,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusBadge(label: formatBhd(book.price), color: color.primary),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              book.description.isEmpty
                  ? 'A new reading experience awaits. More details are coming soon.'
                  : book.description,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(height: 1.55),
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 20,
              runSpacing: 14,
              children: [
                _fact('Publisher', book.publisher),
                _fact('Published', formatDate(book.publishedAt)),
                _fact('ISBN', book.isbn),
              ],
            ),
            const SizedBox(height: 17),
            if (book.condition != null)
              StatusBadge(
                label: book.condition!.label,
                color: book.condition!.color,
                icon: Icons.verified_outlined,
              ),
            const SizedBox(height: 17),
            Row(
              children: [
                const Text('Copies available'),
                const Spacer(),
                Text(
                  '${book.availableCopies} of ${book.copiesTotal}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: available,
                minHeight: 7,
                backgroundColor: color.errorContainer,
                color: available == 0 ? color.error : color.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fact(String label, String value) => SizedBox(
    width: 120,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? '—' : value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
