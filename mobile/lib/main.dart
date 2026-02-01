import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:ToDo/data/datasources/local/local_storage.dart';
import 'package:ToDo/data/datasources/remote/auth_api.dart';
import 'package:ToDo/data/repositories/auth_repository.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_bloc.dart';
import 'package:ToDo/presentation/auth/login_page.dart';
import 'package:ToDo/presentation/home/home_page.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_event.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final authLocalDataSource = AuthLocalDataSourceImpl(prefs: prefs);
  final httpClient = http.Client();
  final authApi = AuthApi(client: httpClient);
  final authRepository = AuthRepository(
    authApi: authApi,
    localStorage: authLocalDataSource,
  );

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(authRepository: authRepository)..add(CheckAuthEvent()),
        child: MaterialApp(
          title: 'ToDo App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const HomePage();
              }
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            
              return const LoginPage();
            },
          ),
        ),
      ),
    );
  }
}