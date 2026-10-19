import 'package:flutter/material.dart';

import '../../core/models/page_result.dart';
import 'state_panel.dart';

class PagedRecords<T> extends StatefulWidget {
  const PagedRecords({
    super.key,
    required this.load,
    required this.itemBuilder,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final Future<PageResult<T>> Function(int page) load;
  final Widget Function(BuildContext context, T item, VoidCallback refresh)
  itemBuilder;
  final String emptyTitle;
  final String emptyMessage;

  @override
  State<PagedRecords<T>> createState() => _PagedRecordsState<T>();
}

class _PagedRecordsState<T> extends State<PagedRecords<T>> {
  int page = 1;
  late Future<PageResult<T>> future = widget.load(page);

  void reload([int? nextPage]) => setState(() {
    page = nextPage ?? page;
    future = widget.load(page);
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<PageResult<T>>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (snapshot.hasError) {
        return StatePanel(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load this page',
          message: '${snapshot.error}',
          actionLabel: 'Try again',
          onAction: reload,
        );
      }
      final result = snapshot.data!;
      if (result.items.isEmpty) {
        return StatePanel(
          icon: Icons.collections_bookmark_outlined,
          title: widget.emptyTitle,
          message: widget.emptyMessage,
          actionLabel: 'Refresh',
          onAction: reload,
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          reload();
          await future;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            ...result.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: widget.itemBuilder(context, item, reload),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  onPressed: result.hasPrevious ? () => reload(page - 1) : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${result.page} / ${result.pages}'),
                ),
                IconButton.outlined(
                  onPressed: result.hasNext ? () => reload(page + 1) : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
