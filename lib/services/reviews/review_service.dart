import '../../models/shared/page_result.dart';
import '../../interfaces/network/api_transport.dart';
import '../../apis/reviews/review_api.dart';
import '../../dtos/reviews/review_request.dart';
import '../../models/reviews/review.dart';
import '../../filters/reviews/review_filter.dart';

class ReviewService {
  ReviewService(ApiTransport client) : _api = ReviewApi(client);

  final ReviewApi _api;

  Future<PageResult<Review>> list(
    String slug, {
    int page = 1,
    bool includeDeleted = false,
  }) async => PageResult.fromJson(
    await _api.list(
      slug,
      ReviewFilter(page: page, includeDeleted: includeDeleted),
    ),
    Review.fromJson,
  );

  Future<Review?> mine(String slug) async {
    final data = await _api.mine(slug);
    return data['review'] is Map<String, dynamic>
        ? Review.fromJson(data['review'] as Map<String, dynamic>)
        : null;
  }

  Future<void> save(
    String slug, {
    int? reviewId,
    required int rating,
    required String comment,
    String description = '',
  }) async {
    final body = ReviewRequest(
      rating: rating,
      comment: comment,
      description: description,
    ).toJson();
    await _api.save(slug, reviewId, body);
  }

  Future<void> delete(String slug, int id) => _api.delete(slug, id);
}
