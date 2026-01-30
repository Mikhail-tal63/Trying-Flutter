import 'package:shared_preferences/shared_preferences.dart';



class StorageHelper {
  static SharedPreferences? _prefs;

static Future<void> init() async {
  _prefs = await SharedPreferences.getInstance();

}

static Future<void> saveToken(String token) async {
  await _prefs?.setString('access_token', token);
}

static String? getToken() {
  return _prefs?.getString('access_token');
}

static Future<void> saveUserData(Map<String, dynamic> user) async{
  await _prefs?.setString('user_id', user['id'] ?? '');
  await _prefs?.setString('user_email', user['email'] ?? '');
  await _prefs?.setString('user_name', user['name'] ?? '');
}


  static Future<Map<String, dynamic>?> getUserData() async {
    final id = _prefs?.getString('user_id');
    if (id == null) return null;
    
    return {
      'id': id,
      'email': _prefs?.getString('user_email') ?? '',
      'name': _prefs?.getString('user_name') ?? '',
    };
  }

static Future<void> clearAll() async {
  await _prefs?.clear();
}

static bool isLoggedIn() {
  return getToken() != null;
}


static Future<void> logout() async {
  await clearAll();
}
}
