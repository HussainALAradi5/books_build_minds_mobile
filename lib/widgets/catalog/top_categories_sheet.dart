import 'package:flutter/material.dart';

import '../../models/catalog/top_category_group.dart';
import '../../models/shared/page_result.dart';
import '../../services/catalog/book_service.dart';
import '../../screens/book_detail/book_detail_screen.dart';
import '../shared/modal_heading.dart';

class TopCategoriesSheet extends StatefulWidget {
  const TopCategoriesSheet({super.key, required this.books});
  final BookService books;

  @override
  State<TopCategoriesSheet> createState() => _TopCategoriesSheetState();
}

class _TopCategoriesSheetState extends State<TopCategoriesSheet> {
  String sort = 'most_rated';
  int page = 1;
  PageResult<TopCategoryGroup>? result;
  bool loading = false;
  String? error;
  int version = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = ++version;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final next = await widget.books.topCategories(page, sort);
      if (mounted && current == version) setState(() => result = next);
    } catch (failure) {
      if (mounted && current == version) setState(() => error = '$failure');
    } finally {
      if (mounted && current == version) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .8,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 12, 4),
            child: ModalHeading(title: 'Top 5 by category'),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'most_rated', label: Text('Most rated')),
                ButtonSegment(
                  value: 'best_selling',
                  label: Text('Best selling'),
                ),
              ],
              selected: {sort},
              onSelectionChanged: (value) {
                sort = value.first;
                page = 1;
                _load();
              },
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              children: [
                for (final group in result?.items ?? <TopCategoryGroup>[])
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.category.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (group.books.isEmpty) const Text('No books yet.'),
                          for (final (index, book) in group.books.indexed)
                            ListTile(
                              dense: true,
                              title: Text('${index + 1}. ${book.title}'),
                              subtitle: Text(book.author),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      BookDetailScreen(slug: book.slug),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if ((result?.pages ?? 0) > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
