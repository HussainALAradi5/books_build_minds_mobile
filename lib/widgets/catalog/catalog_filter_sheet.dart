import 'package:flutter/material.dart';

import '../../services/catalog/book_service.dart';
import '../../enums/catalog/book_condition.dart';
import '../../enums/catalog/book_sort.dart';
import '../../enums/shared/sort_direction.dart';
import '../../filters/catalog/book_filter.dart';
import 'filters/catalog_sort_controls.dart';
import 'filters/price_range_fields.dart';

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
  late final minPrice = TextEditingController(
    text: widget.current.minPrice?.toStringAsFixed(3) ?? '',
  );
  late final maxPrice = TextEditingController(
    text: widget.current.maxPrice?.toStringAsFixed(3) ?? '',
  );
  String? priceError;
  late String publisher = widget.current.publisher;
  late BookCondition? condition = widget.current.condition;
  late BookSort sort = widget.current.sort;
  late SortDirection sortDirection = widget.current.sortDirection;
  late final Future<List<String>> publishers = widget.books.publishers();

  @override
  void dispose() {
    minPrice.dispose();
    maxPrice.dispose();
    super.dispose();
  }

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
                  key: ValueKey(publisher),
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
            PriceRangeFields(
              minPrice: minPrice,
              maxPrice: maxPrice,
              error: priceError,
            ),
            const SizedBox(height: 21),
            CatalogSortControls(
              sort: sort,
              direction: sortDirection,
              onSortChanged: (value) => setState(() => sort = value),
              onDirectionChanged: (value) =>
                  setState(() => sortDirection = value),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      publisher = '';
                      condition = null;
                      sort = BookSort.recent;
                      sortDirection = SortDirection.desc;
                      minPrice.clear();
                      maxPrice.clear();
                      priceError = null;
                    });
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final min = minPrice.text.trim().isEmpty
                          ? null
                          : double.tryParse(minPrice.text.trim());
                      final max = maxPrice.text.trim().isEmpty
                          ? null
                          : double.tryParse(maxPrice.text.trim());
                      if ((minPrice.text.trim().isNotEmpty &&
                              (min == null || !min.isFinite || min <= 0)) ||
                          (maxPrice.text.trim().isNotEmpty &&
                              (max == null || !max.isFinite || max <= 0)) ||
                          (min != null && max != null && min > max)) {
                        setState(
                          () => priceError = 'Enter positive prices with minimum no higher than maximum.',
                        );
                        return;
                      }
                      widget.onApply(
                        widget.current.copyWith(
                          publisher: publisher,
                          condition: condition,
                          clearCondition: condition == null,
                          sort: sort,
                          sortDirection: sortDirection,
                          minPrice: min,
                          maxPrice: max,
                          clearMinPrice: min == null,
                          clearMaxPrice: max == null,
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
