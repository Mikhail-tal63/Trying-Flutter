import 'dart:io';

class ApiEndpoints {
  static String get baseUrl {
    // Physical device: use your computer's LAN IP
    // Emulator: would use 10.0.2.2
    return 'http://192.168.0.9:5000/api';
  }

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';
}