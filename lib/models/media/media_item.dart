class MediaItem {
  const MediaItem({required this.id, required this.url, required this.type});

  final int id;
  final String url;
  final String type;

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
    id: json['media_id'] as int,
    url: json['url'] as String,
    type: json['media_type'] as String? ?? '',
  );
}
