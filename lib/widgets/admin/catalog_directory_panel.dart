import 'package:flutter/material.dart';

import '../../models/shared/page_result.dart';

class CatalogDirectoryPanel<T> extends StatefulWidget {
  const CatalogDirectoryPanel({
    super.key,
    required this.title,
    required this.load,
    required this.nameOf,
    required this.detailOf,
  });
  final String title;
  final Future<PageResult<T>> Function(int page, String query) load;
  final String Function(T item) nameOf;
  final String Function(T item) detailOf;

  @override
  State<CatalogDirectoryPanel<T>> createState() =>
      _CatalogDirectoryPanelState<T>();
}

class _CatalogDirectoryPanelState<T> extends State<CatalogDirectoryPanel<T>> {
  final search = TextEditingController();
  PageResult<T>? result;
  int page = 1;
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
      final next = await widget.load(page, search.text);
      if (mounted && current == version) setState(() => result = next);
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

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: search,
            onChanged: _search,
            decoration: InputDecoration(
              labelText: 'Search ${widget.title.toLowerCase()}',
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (!loading && result?.items.isEmpty == true)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No matches.'),
            ),
          for (final item in result?.items ?? <T>[])
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(widget.nameOf(item)),
              subtitle: widget.detailOf(item).isEmpty
                  ? null
                  : Text(
                      widget.detailOf(item),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          if ((result?.pages ?? 0) > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: result!.hasPrevious && !loading
                      ? () {
                          page--;
                          _load();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Page $page of ${result!.pages}'),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: result!.hasNext && !loading
                      ? () {
                          page++;
                          _load();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
