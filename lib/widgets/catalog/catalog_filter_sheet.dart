import 'package:flutter/material.dart';

import '../../services/catalog/book_service.dart';
import '../../enums/catalog/book_condition.dart';
import '../../enums/catalog/book_sort.dart';
import '../../enums/shared/sort_direction.dart';
import '../../filters/catalog/book_filter.dart';
import 'filters/catalog_sort_controls.dart';
import 'filters/price_range_fields.dart';
import '../shared/modal_heading.dart';
import '../admin/category_picker_field.dart';
import '../admin/catalog_person_field.dart';
import '../../models/catalog/category.dart';

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
  late final publisher = TextEditingController(text: widget.current.publisher);
  late List<Category> categories = widget.current.category.isEmpty
      ? []
      : [
          Category(
            id: 0,
            name: widget.current.category,
            slug: widget.current.category,
          ),
        ];
  late BookCondition? condition = widget.current.condition;
  late BookSort sort = widget.current.sort;
  late SortDirection sortDirection = widget.current.sortDirection;

  @override
  void dispose() {
    minPrice.dispose();
    maxPrice.dispose();
    publisher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height:
            (MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom) *
            .76,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 12, 4),
              child: ModalHeading(title: 'Filters'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    CatalogPersonField(
                      controller: publisher,
                      label: 'Publisher',
                      requiredSelection: false,
                      load: (filter) =>
                          widget.books.catalogProfiles('publishers', filter),
                    ),
                    const SizedBox(height: 21),
                    CategoryPickerField(
                      load: widget.books.categories,
                      selected: categories,
                      maxSelections: 1,
                      onChanged: (value) => setState(() => categories = value),
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
                            labelStyle: TextStyle(
                              color: value.color,
                              fontWeight: FontWeight.w700,
                            ),
                            avatar: CircleAvatar(
                              radius: 5,
                              backgroundColor: value.color,
                            ),
                            selectedColor: value.color.withValues(alpha: .17),
                            side: BorderSide(
                              color: value.color.withValues(
                                alpha: condition == value ? .8 : .35,
                              ),
                            ),
                            selected: condition == value,
                            onSelected: (_) =>
                                setState(() => condition = value),
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
                              publisher.clear();
                              categories = [];
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
                                      (min == null ||
                                          !min.isFinite ||
                                          min <= 0)) ||
                                  (maxPrice.text.trim().isNotEmpty &&
                                      (max == null ||
                                          !max.isFinite ||
                                          max <= 0)) ||
                                  (min != null && max != null && min > max)) {
                                setState(
                                  () => priceError = 'Enter positive prices with minimum no higher than maximum.',
                                );
                                return;
                              }
                              widget.onApply(
                                widget.current.copyWith(
                                  publisher: publisher.text,
                                  category: categories.isEmpty
                                      ? ''
                                      : categories.first.slug,
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
          ],
        ),
      ),
    ),
  );
}
