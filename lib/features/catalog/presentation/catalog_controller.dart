import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/page_result.dart';
import '../data/book_service.dart';
import '../domain/book.dart';
import '../domain/book_filter.dart';

class CatalogController extends ChangeNotifier {
  CatalogController(this._books);

  final BookService _books;
  BookFilter filter = const BookFilter();
  PageResult<Book>? result;
  String? error;
  bool loading = false;
  bool gridView = true;
  Timer? _searchTimer;
  int _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final page = await _books.list(filter);
      if (requestId != _requestId) return;
      result = page;
    } catch (failure) {
      if (requestId != _requestId) return;
      error = '$failure';
    } finally {
      if (requestId == _requestId) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void search(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 350), () {
      filter = filter.copyWith(query: query, page: 1);
      load();
    });
  }

  void apply(BookFilter value) {
    filter = value.copyWith(page: 1);
    load();
  }

  void reset() {
    _searchTimer?.cancel();
    filter = const BookFilter();
    load();
  }

  void changePage(int page) {
    filter = filter.copyWith(page: page);
    load();
  }

  void toggleView() {
    gridView = !gridView;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
