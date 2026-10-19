import 'package:flutter/foundation.dart';

import '../../models/auth/user_profile.dart';
import '../../services/loans/loan_service.dart';
import '../../models/loans/loan.dart';
import '../../services/reviews/review_service.dart';
import '../../models/reviews/review.dart';
import '../../models/shared/page_result.dart';
import '../../services/book_detail/book_detail_service.dart';
import '../../models/book_detail/book_detail.dart';

class BookDetailController extends ChangeNotifier {
  BookDetailController(
    this.slug,
    this._books,
    this._loans,
    this._reviews,
    this.user,
  );

  final String slug;
  final BookDetailService _books;
  final LoanService _loans;
  final ReviewService _reviews;
  final UserProfile? user;

  BookDetail? detail;
  Loan? currentLoan;
  PageResult<Review>? reviews;
  Review? myReview;
  String? error;
  bool loading = false;
  bool includeDeleted = false;
  bool busy = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      detail = await _books.get(slug);
      await loadReviews();
      if (user != null) {
        currentLoan = await _loans.current(slug);
        myReview = await _reviews.mine(slug);
      }
    } catch (failure) {
      error = '$failure';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviews({int page = 1}) async {
    reviews = await _reviews.list(
      slug,
      page: page,
      includeDeleted: includeDeleted,
    );
    notifyListeners();
  }

  Future<void> toggleDeleted(bool value) async {
    includeDeleted = value;
    notifyListeners();
    await loadReviews();
  }

  Future<void> refreshAfterAction() async {
    detail = await _books.get(slug);
    currentLoan = user == null ? null : await _loans.current(slug);
    notifyListeners();
  }

  Future<void> returnBook() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await _loans.returnBook(slug);
      await refreshAfterAction();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> saveReview({
    required int rating,
    required String comment,
    required String description,
  }) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await _reviews.save(
        slug,
        reviewId: myReview?.id,
        rating: rating,
        comment: comment,
        description: description,
      );
      await loadReviews();
      myReview = await _reviews.mine(slug);
      detail = await _books.get(slug);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview(Review review) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await _reviews.delete(slug, review.id);
      await loadReviews();
      if (review.userId == user?.userId) myReview = null;
      detail = await _books.get(slug);
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
