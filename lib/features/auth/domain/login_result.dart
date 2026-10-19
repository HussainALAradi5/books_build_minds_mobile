class LoginResult {
  const LoginResult(this.token, this.userId);

  final String token;
  final int userId;

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      LoginResult(json['token'] as String, json['user_id'] as int);
}
