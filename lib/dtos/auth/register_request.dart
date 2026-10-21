import '../../utils/auth/mobile_number.dart';

class RegisterRequest {
  const RegisterRequest({
    required this.userName,
    required this.email,
    required this.password,
    this.mobileNumber = '',
  });

  final String userName;
  final String email;
  final String password;
  final String mobileNumber;

  Map<String, dynamic> toJson() => {
    'user_name': userName.trim(),
    'email': email.trim(),
    'password': password,
    'mobile_number': mobileNumber.trim().isEmpty
        ? null
        : normalizeMobileNumber(mobileNumber),
  };
}
