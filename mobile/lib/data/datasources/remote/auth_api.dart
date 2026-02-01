

import 'dart:convert';

import 'package:ToDo/core/constants/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:ToDo/data/models/auth_response.dart';

class AuthApi {
  final http.Client client;

  AuthApi({required this.client});

Future<AuthResponse> login(String email, String password) async {
final response = await client.post(
Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}'),
headers: {
'Content-Type': 'application/json',
},
body: jsonEncode({
'email': email,
'password': password,
},)



);
if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return AuthResponse.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? '${response.statusCode}');
      } catch (_) {
        throw Exception('${response.statusCode}');
      }
    }
}


 Future<AuthResponse> register(String name, String email, String password) async {
    final response = await client.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.register}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return AuthResponse.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Signing up failed');
      }
    } else {

       try {
         final data = jsonDecode(response.body);
         throw Exception(data['message'] ?? '${response.statusCode}');
       } catch (_) {
         throw Exception('${response.statusCode}');
       }
    }
  }


  
    Future<void> logout(String refreshToken) async {
    await client.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.logout}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
  }
}


