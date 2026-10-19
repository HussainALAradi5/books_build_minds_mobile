class RegisterRequest {
  const RegisterRequest({
    required this.userName,
    required this.email,
    required this.password,
  });

  final String userName;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
    'user_name': userName.trim(),
    'email': email.trim(),
    'password': password,
  };
}
