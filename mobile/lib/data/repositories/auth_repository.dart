// 📁 data/repositories/auth_repository.dart


import 'package:ToDo/data/datasources/local/local_storage.dart';
import 'package:ToDo/data/datasources/remote/auth_api.dart';
import 'package:ToDo/data/models/auth_response.dart';
import 'package:ToDo/data/models/user_model.dart';

class AuthRepository {
  final AuthApi authApi;
  final AuthLocalDataSource localStorage;

  AuthRepository({
    required this.authApi,
    required this.localStorage,
  });

  Future<UserModel> login(String email, String password) async {
    try {

      final AuthResponse response = await authApi.login(email, password);
      

      await _saveAuthData(response);
      

      return response.user;
    } catch (e) {

      await localStorage.clearAuthData();
      rethrow; 
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {

      final AuthResponse response = await authApi.register(name, email, password);
      

      await _saveAuthData(response);
      

      return response.user;
    } catch (e) {
      await localStorage.clearAuthData();
      rethrow;
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {

      if (refreshToken != null) {
        await authApi.logout(refreshToken);
      }
    } catch (e) {

      print('Logout API error: $e');
    } finally {

      await localStorage.clearAuthData();
    }
  }

  Future<void> saveUserData(UserModel user) async {
    await localStorage.saveUser(user);
  }

  Future<void> saveToken(String token) async {
    await localStorage.saveAccessToken(token);
  }

  Future<UserModel?> getCurrentUser() async {
    return localStorage.getUser();
  }

  Future<String?> getToken() async {
    return localStorage.getAccessToken();
  }

  Future<String?> getRefreshToken() async {
    return localStorage.getRefreshToken();
  }

  bool isLoggedIn() {
    return localStorage.isLoggedIn();
  }


  Future<bool> refreshToken() async {
    try {
      final refreshToken = localStorage.getRefreshToken();
      if (refreshToken == null) return false;

      return true;
    } catch (e) {
      await localStorage.clearAuthData();
      return false;
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('No user logged in');
    }
    

    await localStorage.saveUser(updatedUser);
    

  }


  Future<void> _saveAuthData(AuthResponse response) async {
    await Future.wait([
      localStorage.saveAccessToken(response.accessToken),
      localStorage.saveRefreshToken(response.refreshToken),
      localStorage.saveUser(response.user),
    ]);
  }
}