import 'package:flutter/material.dart';

class InventoryPager extends StatelessWidget {
  const InventoryPager({
    super.key,
    required this.page,
    required this.pages,
    required this.hasPrevious,
    required this.hasNext,
    required this.previous,
    required this.next,
  });
  final int page;
  final int pages;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback previous;
  final VoidCallback next;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: hasPrevious ? previous : null,
        icon: const Icon(Icons.chevron_left),
      ),
      Text('$page / $pages'),
      IconButton(
        onPressed: hasNext ? next : null,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}
