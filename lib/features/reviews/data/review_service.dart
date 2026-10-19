import '../../../core/models/page_result.dart';
import '../../../core/network/api_client.dart';
import '../domain/review.dart';

class ReviewService {
  const ReviewService(this._api);

  final ApiClient _api;

  Future<PageResult<Review>> list(
    String slug, {
    int page = 1,
    bool includeDeleted = false,
  }) async => PageResult.fromJson(
    await _api.get(
      '/book/${Uri.encodeComponent(slug)}/review',
      query: {
        'page': '$page',
        'per_page': '5',
        'include_deleted': '$includeDeleted',
      },
      authenticated: includeDeleted,
    ),
    Review.fromJson,
  );

  Future<Review?> mine(String slug) async {
    final data = await _api.get(
      '/book/${Uri.encodeComponent(slug)}/review/mine',
      authenticated: true,
    );
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
    final body = {
      'rating': rating,
      'comment': comment,
      'description': description,
    };
    final path = '/book/${Uri.encodeComponent(slug)}/review';
    if (reviewId == null) {
      await _api.post(path, body: body);
    } else {
      await _api.put('$path/$reviewId', body: body);
    }
  }

  Future<void> delete(String slug, int id) async =>
      _api.delete('/book/${Uri.encodeComponent(slug)}/review/$id');
}
