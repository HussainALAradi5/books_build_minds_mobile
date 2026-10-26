import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../widgets/shared/state_panel.dart';
import '../../services/catalog/book_service.dart';
import '../../controllers/catalog/catalog_controller.dart';
import '../../widgets/catalog/book_card.dart';
import '../../widgets/catalog/catalog_filter_sheet.dart';
import '../../widgets/catalog/top_categories_sheet.dart';
import '../book_detail/book_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  CatalogController? controller;
  BookService? books;
  final search = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller != null) return;
    books = BookService(AppScope.of(context).api);
    controller = CatalogController(books!);
    WidgetsBinding.instance.addPostFrameCallback((_) => controller?.load());
  }

  @override
  void dispose() {
    search.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller!,
    builder: (context, _) {
      final state = controller!;
      final page = state.result;
      return RefreshIndicator(
        onRefresh: state.load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE CURIOUS READER’S LIBRARY',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find a story to\nstay with you.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore, borrow, and make room for new ideas.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: search,
                      onChanged: state.search,
                      onSubmitted: state.submitSearch,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Title, author, publisher or ISBN',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: search,
                          builder: (context, value, _) => value.text.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    search.clear();
                                    state.submitSearch('');
                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            showDragHandle: false,
                            builder: (_) => CatalogFilterSheet(
                              current: state.filter,
                              books: books!,
                              onApply: state.apply,
                            ),
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('Filters'),
                        ),
                        const SizedBox(width: 8),
                        IconButton.outlined(
                          tooltip: 'Top 5 by category',
                          icon: const Icon(Icons.leaderboard_rounded),
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => TopCategoriesSheet(books: books!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: state.gridView ? 'List view' : 'Grid view',
                          onPressed: state.toggleView,
                          icon: Icon(
                            state.gridView
                                ? Icons.view_list_rounded
                                : Icons.grid_view_rounded,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${page?.total ?? 0} books',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (state.loading && page == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && page == null)
              SliverFillRemaining(
                child: StatePanel(
                  icon: Icons.wifi_off_rounded,
                  title: 'The shelves are out of reach',
                  message: state.error!,
                  actionLabel: 'Try again',
                  onAction: state.load,
                ),
              )
            else if (page?.items.isEmpty ?? true)
              SliverFillRemaining(
                child: StatePanel(
                  icon: Icons.menu_book_rounded,
                  title: 'No books match yet',
                  message: 'Try another search or clear your filters.',
                  actionLabel: 'Clear filters',
                  onAction: () {
                    search.clear();
                    state.reset();
                  },
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 18),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 840
                        ? 4
                        : width >= 560
                        ? 3
                        : 2;
                    return SliverGrid.builder(
                      itemCount: page!.items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: state.gridView ? columns : 1,
                        mainAxisExtent: state.gridView ? 330 : 142,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) => BookCard(
                        book: page.items[index],
                        api: AppScope.of(context).api,
                        compact: !state.gridView,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                BookDetailScreen(slug: page.items[index].slug),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        onPressed: page!.hasPrevious
                            ? () => state.changePage(page.page - 1)
                            : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: 'Previous page',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text('Page ${page.page} of ${page.pages}'),
                      ),
                      IconButton.outlined(
                        onPressed: page.hasNext
                            ? () => state.changePage(page.page + 1)
                            : null,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        tooltip: 'Next page',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
