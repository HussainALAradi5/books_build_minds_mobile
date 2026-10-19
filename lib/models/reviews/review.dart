class Review {
  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.description,
    required this.writtenTime,
    this.profilePictureUrl,
    this.isDeleted = false,
  });

  final int id;
  final int userId;
  final String userName;
  final double rating;
  final String comment;
  final String description;
  final String writtenTime;
  final String? profilePictureUrl;
  final bool isDeleted;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['review_id'] as int? ?? 0,
    userId: json['user_id'] as int? ?? 0,
    userName: json['user_name'] as String? ?? 'Reader',
    rating: (json['rating'] as num? ?? 0).toDouble(),
    comment: json['comment'] as String? ?? '',
    description: json['description'] as String? ?? '',
    writtenTime: json['written_time'] as String? ?? '',
    profilePictureUrl: json['profile_picture_url'] as String?,
    isDeleted: json['is_deleted'] as bool? ?? false,
  );
}
