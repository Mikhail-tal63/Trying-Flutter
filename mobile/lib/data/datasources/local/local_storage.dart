// 📁 data/datasources/local/auth_local_data_source.dart

import 'package:ToDo/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAccessToken(String token);
  String? getAccessToken();
  
  Future<void> saveRefreshToken(String token);
  String? getRefreshToken();
  
  Future<void> saveUser(UserModel user);
  UserModel? getUser();
  
  bool isLoggedIn();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  
  AuthLocalDataSourceImpl({required this.prefs});
  
  @override
  Future<void> saveAccessToken(String token) async {
    await prefs.setString('access_token', token);
  }
  
  @override
  String? getAccessToken() {
    return prefs.getString('access_token');
  }
  
  @override
  Future<void> saveRefreshToken(String token) async {
    await prefs.setString('refresh_token', token);
  }
  
  @override
  String? getRefreshToken() {
    return prefs.getString('refresh_token');
  }
  
  @override
  Future<void> saveUser(UserModel user) async {
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    if (user.avatar != null) {
      await prefs.setString('user_avatar', user.avatar!);
    }
  }
  
  @override
  UserModel? getUser() {
    final id = prefs.getString('user_id');
    if (id == null) return null;
    
    return UserModel(
      id: id,
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      avatar: prefs.getString('user_avatar'),
    );
  }
  
  @override
  bool isLoggedIn() {
    final token = getAccessToken();
    final user = getUser();
    return token != null && token.isNotEmpty && user != null;
  }
  
  @override
  Future<void> clearAuthData() async {
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_avatar');
  }
}