// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ToDo/main.dart';
import 'package:ToDo/data/datasources/local/local_storage.dart';
import 'package:ToDo/data/datasources/remote/auth_api.dart';
import 'package:ToDo/data/repositories/auth_repository.dart';
import 'package:ToDo/data/models/auth_response.dart';
import 'package:ToDo/data/models/user_model.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final authRepository = AuthRepository(
      authApi: _FakeAuthApi(),
      localStorage: _FakeAuthLocalDataSource(),
    );

    await tester.pumpWidget(MyApp(authRepository: authRepository));

    await tester.pumpAndSettle();


    expect(find.text('Login'), findsWidgets);
  });
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi() : super(client: http.Client());

  @override
  Future<AuthResponse> login(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> register(String name, String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout(String refreshToken) {
    throw UnimplementedError();
  }
}

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  @override
  String? getAccessToken() => null;

  @override
  String? getRefreshToken() => null;

  @override
  UserModel? getUser() => null;

  @override
  bool isLoggedIn() => false;

  @override
  Future<void> clearAuthData() async {}

  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<void> saveRefreshToken(String token) async {}

  @override
  Future<void> saveUser(UserModel user) async {}
}
