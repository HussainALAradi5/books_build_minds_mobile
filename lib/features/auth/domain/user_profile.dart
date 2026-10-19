class UserProfile {
  const UserProfile({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    required this.permissions,
    required this.purchasedBookIds,
    this.profilePictureUrl,
  });

  final int userId;
  final String userName;
  final String email;
  final String role;
  final Set<String> permissions;
  final Set<int> purchasedBookIds;
  final String? profilePictureUrl;

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['user_id'] as int,
    userName: json['user_name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'client',
    permissions: (json['permissions'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toSet(),
    purchasedBookIds: (json['purchased_books'] as List<dynamic>? ?? [])
        .whereType<int>()
        .toSet(),
    profilePictureUrl: json['profile_picture_url'] as String?,
  );
}
