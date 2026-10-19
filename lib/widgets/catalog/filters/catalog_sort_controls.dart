import 'package:flutter/material.dart';

import '../../../enums/catalog/book_sort.dart';
import '../../../enums/shared/sort_direction.dart';

class CatalogSortControls extends StatelessWidget {
  const CatalogSortControls({
    super.key,
    required this.sort,
    required this.direction,
    required this.onSortChanged,
    required this.onDirectionChanged,
  });

  final BookSort sort;
  final SortDirection direction;
  final ValueChanged<BookSort> onSortChanged;
  final ValueChanged<SortDirection> onDirectionChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('SORT BY', style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 8),
      DropdownButtonFormField<BookSort>(
        key: ValueKey(sort),
        initialValue: sort,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.sort_rounded)),
        items: BookSort.values
            .map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text(value.label)),
            )
            .toList(),
        onChanged: (value) => onSortChanged(value ?? BookSort.recent),
      ),
      const SizedBox(height: 14),
      SegmentedButton<SortDirection>(
        segments: SortDirection.values
            .map(
              (value) => ButtonSegment(
                value: value,
                label: Text(value.label),
                icon: Icon(
                  value == SortDirection.asc
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                ),
              ),
            )
            .toList(),
        selected: {direction},
        onSelectionChanged: (value) => onDirectionChanged(value.first),
      ),
    ],
  );
}
