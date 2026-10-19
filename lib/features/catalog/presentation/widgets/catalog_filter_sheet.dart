import 'package:flutter/material.dart';

import '../../data/book_service.dart';
import '../../domain/book_condition.dart';
import '../../domain/book_filter.dart';

class CatalogFilterSheet extends StatefulWidget {
  const CatalogFilterSheet({
    super.key,
    required this.current,
    required this.books,
    required this.onApply,
  });

  final BookFilter current;
  final BookService books;
  final ValueChanged<BookFilter> onApply;

  @override
  State<CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<CatalogFilterSheet> {
  late String publisher = widget.current.publisher;
  late BookCondition? condition = widget.current.condition;
  late String sort = widget.current.sort;
  late final Future<List<String>> publishers = widget.books.publishers();

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Find your next read',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            const Text('Refine the collection without leaving the page.'),
            const SizedBox(height: 22),
            Text('PUBLISHER', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            FutureBuilder<List<String>>(
              future: publishers,
              builder: (context, snapshot) {
                final names = snapshot.data ?? const <String>[];
                return DropdownButtonFormField<String>(
                  initialValue: names.contains(publisher) ? publisher : '',
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.apartment_rounded),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All publishers'),
                    ),
                    ...names.map(
                      (name) => DropdownMenuItem(
                        value: name,
                        child: Text(name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: snapshot.hasData
                      ? (value) => setState(() => publisher = value ?? '')
                      : null,
                );
              },
            ),
            const SizedBox(height: 21),
            Text(
              'BOOK CONDITION',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: condition == null,
                  onSelected: (_) => setState(() => condition = null),
                ),
                ...BookCondition.values.map(
                  (value) => ChoiceChip(
                    label: Text(value.label),
                    avatar: CircleAvatar(
                      radius: 5,
                      backgroundColor: value.color,
                    ),
                    selected: condition == value,
                    onSelected: (_) => setState(() => condition = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Text('SORT BY', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: sort,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.sort_rounded),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'recent',
                  child: Text('Recently added'),
                ),
                DropdownMenuItem(value: 'title', child: Text('Title')),
                DropdownMenuItem(value: 'rating', child: Text('Reader rating')),
                DropdownMenuItem(
                  value: 'price_asc',
                  child: Text('Price: low to high'),
                ),
                DropdownMenuItem(
                  value: 'price_desc',
                  child: Text('Price: high to low'),
                ),
              ],
              onChanged: (value) => setState(() => sort = value ?? 'recent'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      publisher = '';
                      condition = null;
                      sort = 'recent';
                    });
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onApply(
                        widget.current.copyWith(
                          publisher: publisher,
                          condition: condition,
                          clearCondition: condition == null,
                          sort: sort,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Show books'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
