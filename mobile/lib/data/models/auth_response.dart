
import 'package:ToDo/data/models/user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

factory AuthResponse.fromJson(Map<String, dynamic> json) {
  try {
    return AuthResponse(
      accessToken: json['tokens']['accessToken'] as String,
      refreshToken: json['tokens']['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  } catch (e) {
    throw FormatException('Invalid auth response: $e');
  }
}
}