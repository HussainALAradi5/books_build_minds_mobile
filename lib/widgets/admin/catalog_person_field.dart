import 'package:flutter/material.dart';

import '../../models/catalog/catalog_person.dart';
import '../../filters/catalog/catalog_search_filter.dart';
import '../../models/shared/page_result.dart';
import '../shared/responsive_form_dialog.dart';

class CatalogPersonField extends StatelessWidget {
  const CatalogPersonField({
    super.key,
    required this.controller,
    required this.load,
    required this.label,
    this.requiredSelection = true,
  });
  final TextEditingController controller;
  final Future<PageResult<CatalogPerson>> Function(CatalogSearchFilter) load;
  final String label;
  final bool requiredSelection;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    readOnly: true,
    validator: requiredSelection
        ? (value) => value == null || value.isEmpty ? 'Select $label' : null
        : null,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      suffixIcon: requiredSelection
          ? const Icon(Icons.search_rounded)
          : IconButton(
              tooltip: 'Clear $label',
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded),
            ),
    ),
    onTap: () async {
      final selected = await showDialog<CatalogPerson>(
        context: context,
        builder: (_) => _CatalogPersonSearchDialog(load: load, label: label),
      );
      if (selected != null) controller.text = selected.name;
    },
  );
}

class _CatalogPersonSearchDialog extends StatefulWidget {
  const _CatalogPersonSearchDialog({required this.load, required this.label});
  final Future<PageResult<CatalogPerson>> Function(CatalogSearchFilter) load;
  final String label;

  @override
  State<_CatalogPersonSearchDialog> createState() =>
      _CatalogPersonSearchDialogState();
}

class _CatalogPersonSearchDialogState
    extends State<_CatalogPersonSearchDialog> {
  final search = TextEditingController();
  List<CatalogPerson> items = [];
  int page = 1;
  int pages = 0;
  int requestVersion = 0;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    requestVersion++;
    search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final version = ++requestVersion;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.load(
        CatalogSearchFilter(page: page, query: search.text),
      );
      if (mounted && version == requestVersion) {
        setState(() {
          items = result.items;
          pages = result.pages;
        });
      }
    } catch (failure) {
      if (mounted && version == requestVersion) {
        setState(() => error = '$failure');
      }
    } finally {
      if (mounted && version == requestVersion) setState(() => loading = false);
    }
  }

  void _search(String value) {
    page = 1;
    final version = ++requestVersion;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && version == requestVersion) _load();
    });
  }

  @override
  Widget build(BuildContext context) => ResponsiveFormDialog(
    title: 'Choose ${widget.label.toLowerCase()}',
    content: SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: search,
            onChanged: _search,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Search ${widget.label.toLowerCase()}s',
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (!loading && error == null && items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No matching ${widget.label.toLowerCase()}s. Ask an admin to add one in Catalog.',
              ),
            ),
          for (final item in items)
            ListTile(
              title: Text(item.name),
              subtitle: item.country == null ? null : Text(item.country!),
              onTap: () => Navigator.pop(context, item),
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
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ],
  );
}
