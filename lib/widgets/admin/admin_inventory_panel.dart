import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../interfaces/network/upload_file.dart';
import '../../models/catalog/book.dart';
import '../../models/shared/page_result.dart';
import '../../filters/catalog/book_filter.dart';
import '../../services/catalog/book_service.dart';
import '../catalog/catalog_filter_sheet.dart';
import '../../app/app_scope.dart';
import '../../services/admin/admin_service.dart';
import '../../utils/shared/save_downloaded_file.dart';
import '../shared/confirm_action.dart';
import '../shared/state_panel.dart';
import 'inventory_tile.dart';
import 'inventory_grid_card.dart';
import 'inventory_pager.dart';

class AdminInventoryPanel extends StatefulWidget {
  const AdminInventoryPanel({
    super.key,
    required this.service,
    required this.permissions,
  });
  final AdminService service;
  final Set<String> permissions;

  @override
  State<AdminInventoryPanel> createState() => _AdminInventoryPanelState();
}

class _AdminInventoryPanelState extends State<AdminInventoryPanel> {
  late Future<PageResult<Book>> records;
  final selected = <int>{};
  int page = 1;
  BookFilter filter = const BookFilter();
  final search = TextEditingController();
  bool busy = false;
  bool grid = false;

  @override
  void initState() {
    super.initState();
    records = widget.service.inventory(filter);
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
    records = widget.service.inventory(filter.copyWith(page: page));
    selected.clear();
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: search,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  page = 1;
                  filter = filter.copyWith(query: value);
                  _reload();
                },
                decoration: InputDecoration(
                  hintText: 'Search inventory',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {
                      search.clear();
                      page = 1;
                      filter = filter.copyWith(query: '');
                      _reload();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Filter inventory',
              icon: const Icon(Icons.tune),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => CatalogFilterSheet(
                  current: filter,
                  books: BookService(AppScope.of(context).api),
                  onApply: (next) {
                    page = 1;
                    filter = next.copyWith(page: 1);
                    _reload();
                  },
                ),
              ),
            ),
            IconButton(
              tooltip: grid ? 'List view' : 'Grid view',
              icon: Icon(grid ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => grid = !grid),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.permissions.contains('book:write.bulk'))
              OutlinedButton.icon(
                onPressed: busy ? null : _import,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Import CSV/XLSX'),
              ),
            OutlinedButton.icon(
              onPressed: busy ? null : () => _export('xlsx'),
              icon: const Icon(Icons.table_view_outlined),
              label: const Text('Export Excel'),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : () => _export('csv'),
              icon: const Icon(Icons.table_rows_outlined),
              label: const Text('Export CSV'),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : () => _export('pdf'),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Export PDF'),
            ),
            if (selected.isNotEmpty &&
                widget.permissions.contains('book:edit.bulk')) ...[
              OutlinedButton(
                onPressed: busy ? null : () => _bulk('archive'),
                child: const Text('Archive selected'),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => _bulk('unarchive'),
                child: const Text('Restore selected'),
              ),
              TextButton(
                onPressed: busy ? null : () => _bulk('delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete selected'),
              ),
            ],
          ],
        ),
      ),
      if (busy) const LinearProgressIndicator(),
      Expanded(
        child: FutureBuilder<PageResult<Book>>(
          future: records,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return StatePanel(
                icon: Icons.error_outline,
                title: 'Inventory unavailable',
                message: '${snapshot.error}',
                actionLabel: 'Retry',
                onAction: _reload,
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final result = snapshot.data!;
            if (result.items.isEmpty) {
              return const StatePanel(
                icon: Icons.inventory_2_outlined,
                title: 'No books found',
                message: 'Add a book in the Catalog tab.',
              );
            }
            if (grid) {
              return LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth >= 650 ? 2 : 1,
                          mainAxisExtent: 210,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: result.items.length,
                        itemBuilder: (context, index) {
                          final book = result.items[index];
                          return InventoryGridCard(
                            book: book,
                            selected: selected.contains(book.bookId),
                            onSelected: (value) => setState(
                              () => value
                                  ? selected.add(book.bookId)
                                  : selected.remove(book.bookId),
                            ),
                          );
                        },
                      ),
                    ),
                    InventoryPager(
                      page: result.page,
                      pages: result.pages,
                      hasPrevious: result.hasPrevious,
                      hasNext: result.hasNext,
                      previous: () {
                        page--;
                        _reload();
                      },
                      next: () {
                        page++;
                        _reload();
                      },
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: result.items.length + 1,
              itemBuilder: (context, index) {
                if (index == result.items.length) {
                  return InventoryPager(
                    page: result.page,
                    pages: result.pages,
                    hasPrevious: result.hasPrevious,
                    hasNext: result.hasNext,
                    previous: () {
                      page--;
                      _reload();
                    },
                    next: () {
                      page++;
                      _reload();
                    },
                  );
                }
                final book = result.items[index];
                return Column(
                  children: [
                    if (widget.permissions.contains('book:edit.bulk'))
                      CheckboxListTile(
                        value: selected.contains(book.bookId),
                        title: Text('Select ${book.title}'),
                        onChanged: (value) => setState(
                          () => value == true
                              ? selected.add(book.bookId)
                              : selected.remove(book.bookId),
                        ),
                      ),
                    InventoryTile(
                      book: book,
                      service: widget.service,
                      refresh: _reload,
                      canEdit: widget.permissions.contains('book:edit.any'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ],
  );

  Future<void> _perform(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
      if (mounted) _reload();
    } catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$failure')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _import() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );
    if (file == null) return;
    final length = await file.length();
    if (length == null || length > 2 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import file must be 2 MB or smaller.')),
        );
      }
      return;
    }
    final bytes = await file.readAsBytes();
    final mime = file.extension == 'csv'
        ? 'text/csv'
        : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    await _perform(() async {
      await widget.service.importBooks(
        UploadFile(name: file.name, mimeType: mime, bytes: bytes),
      );
    });
  }

  Future<void> _export(String format) async => _perform(() async {
    await saveDownloadedFile(
      await widget.service.exportBooks(format, selected.toList()),
    );
  });

  Future<void> _bulk(String action) async {
    final verb = switch (action) {
      'archive' => 'archived',
      'unarchive' => 'restored',
      _ => 'deleted',
    };
    if (!await confirmAction(
      context,
      title: 'Update selected books?',
      message: '${selected.length} selected books will be $verb.',
      confirmLabel: action == 'delete' ? 'Delete' : 'Confirm',
      destructive: action == 'delete',
    )) {
      return;
    }
    await _perform(() => widget.service.bulkBooks(selected.toList(), action));
  }
}
