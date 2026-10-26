import 'package:flutter/material.dart';

import '../../filters/catalog/catalog_search_filter.dart';
import '../../models/catalog/category.dart';
import '../../models/shared/page_result.dart';
import '../shared/responsive_form_dialog.dart';

class CategoryPickerField extends StatelessWidget {
  const CategoryPickerField({
    super.key,
    required this.load,
    required this.selected,
    required this.onChanged,
    this.maxSelections = 5,
  });
  final Future<PageResult<Category>> Function(CatalogSearchFilter) load;
  final List<Category> selected;
  final ValueChanged<List<Category>> onChanged;
  final int maxSelections;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final result = await showDialog<List<Category>>(
        context: context,
        builder: (_) => _CategorySearchDialog(
          load: load,
          initial: selected,
          maxSelections: maxSelections,
        ),
      );
      if (result != null) onChanged(result);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: maxSelections == 1 ? 'Category' : 'Categories · choose 1–5',
        suffixIcon: const Icon(Icons.search_rounded),
      ),
      child: selected.isEmpty
          ? const Text('Select categories')
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selected
                  .map(
                    (category) => Chip(
                      label: Text(category.name),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
    ),
  );
}

class _CategorySearchDialog extends StatefulWidget {
  const _CategorySearchDialog({
    required this.load,
    required this.initial,
    required this.maxSelections,
  });
  final Future<PageResult<Category>> Function(CatalogSearchFilter) load;
  final List<Category> initial;
  final int maxSelections;

  @override
  State<_CategorySearchDialog> createState() => _CategorySearchDialogState();
}

class _CategorySearchDialogState extends State<_CategorySearchDialog> {
  final search = TextEditingController();
  late final List<Category> selected = [...widget.initial];
  List<Category> items = [];
  int page = 1;
  int pages = 0;
  int version = 0;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    version++;
    search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final current = ++version;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.load(
        CatalogSearchFilter(page: page, query: search.text),
      );
      if (mounted && current == version) {
        setState(() {
          items = result.items;
          pages = result.pages;
        });
      }
    } catch (failure) {
      if (mounted && current == version) setState(() => error = '$failure');
    } finally {
      if (mounted && current == version) setState(() => loading = false);
    }
  }

  void _search(String value) {
    page = 1;
    final current = ++version;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && current == version) _load();
    });
  }

  void _toggle(Category category) {
    final index = selected.indexWhere((item) => item.id == category.id);
    if (index < 0 &&
        selected.length >= widget.maxSelections &&
        widget.maxSelections != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Choose up to ${widget.maxSelections} categories.'),
        ),
      );
      return;
    }
    setState(() {
      if (index >= 0) {
        selected.removeAt(index);
      } else if (widget.maxSelections == 1) {
        selected
          ..clear()
          ..add(category);
      } else {
        selected.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) => ResponsiveFormDialog(
    title: 'Choose categories',
    content: SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: search,
            autofocus: true,
            onChanged: _search,
            decoration: const InputDecoration(
              labelText: 'Search categories',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (!loading && error == null && items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No matching categories. Ask an admin to add one in Catalog.',
              ),
            ),
          for (final category in items)
            CheckboxListTile(
              value: selected.any((item) => item.id == category.id),
              title: Text(category.name),
              onChanged: (_) => _toggle(category),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          if (pages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: page <= 1 || loading
                      ? null
                      : () {
                          page--;
                          _load();
                        },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Page $page of $pages'),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: page >= pages || loading
                      ? null
                      : () {
                          page++;
                          _load();
                        },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          Text('${selected.length} of ${widget.maxSelections} selected'),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: selected.isEmpty
            ? null
            : () => Navigator.pop(context, selected),
        child: const Text('Use categories'),
      ),
    ],
  );
}
