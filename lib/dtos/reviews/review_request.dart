class ReviewRequest {
  const ReviewRequest({
    required this.rating,
    required this.comment,
    this.description = '',
  });

  final int rating;
  final String comment;
  final String description;

  Map<String, dynamic> toJson() => {
    'rating': rating,
    'comment': comment.trim(),
    'description': description.trim(),
  };
}
