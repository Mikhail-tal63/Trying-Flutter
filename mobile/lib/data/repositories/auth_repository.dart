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
      // 1. استدعاء API لتسجيل الدخول
      final AuthResponse response = await authApi.login(email, password);
      
      // 2. حفظ البيانات محلياً
      await _saveAuthData(response);
      
      // 3. إرجاع بيانات المستخدم
      return response.user;
    } catch (e) {
      // 4. في حالة الخطأ، تنظيف البيانات المحلية (اختياري)
      await localStorage.clearAuthData();
      rethrow; // إعادة رمي الخطأ للطبقة الأعلى
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      // 1. استدعاء API للتسجيل
      final AuthResponse response = await authApi.register(name, email, password);
      
      // 2. حفظ البيانات محلياً
      await _saveAuthData(response);
      
      // 3. إرجاع بيانات المستخدم
      return response.user;
    } catch (e) {
      await localStorage.clearAuthData();
      rethrow;
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      // 1. إرسال طلب تسجيل خروج للسيرفر (إذا كان هناك refreshToken)
      if (refreshToken != null) {
        await authApi.logout(refreshToken);
      }
    } catch (e) {
      // تجاهل أخطاء السيرفر، نظف البيانات المحلية على أي حال
      print('Logout API error: $e');
    } finally {
      // 2. تنظيف البيانات المحلية دائماً
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

  // 🔄 دوال إضافية مهمة

  Future<bool> refreshToken() async {
    try {
      final refreshToken = localStorage.getRefreshToken();
      if (refreshToken == null) return false;

      // هنا تحتاج لإضافة دالة refreshToken في AuthApi
      // final newToken = await authApi.refreshToken(refreshToken);
      // await localStorage.saveAccessToken(newToken);
      
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
    
    // حفظ المستخدم المحدث
    await localStorage.saveUser(updatedUser);
    
    // هنا يمكنك إضافة استدعاء API لتحديث بيانات المستخدم في السيرفر
    // await authApi.updateProfile(updatedUser);
  }

  // 🔒 دالة خاصة لحفظ بيانات التوثيق
  Future<void> _saveAuthData(AuthResponse response) async {
    await Future.wait([
      localStorage.saveAccessToken(response.accessToken),
      localStorage.saveRefreshToken(response.refreshToken),
      localStorage.saveUser(response.user),
    ]);
  }
}