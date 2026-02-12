import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:ToDo/core/utils/storage_helper.dart';
import 'package:ToDo/data/datasources/local/local_storage.dart';
import 'package:ToDo/data/datasources/local/task_local_datasource.dart';
import 'package:ToDo/data/datasources/remote/auth_api.dart';
import 'package:ToDo/data/datasources/remote/task_api.dart';
import 'package:ToDo/data/models/task_model.dart';
import 'package:ToDo/data/repositories/auth_repository.dart';
import 'package:ToDo/data/repositories/task_repository.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_bloc.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_event.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_state.dart';
import 'package:ToDo/presentation/auth/login_page.dart';
import 'package:ToDo/presentation/home/Bloc/task_bloc.dart';
import 'package:ToDo/presentation/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskStatusAdapter());

  await StorageHelper.init();

  final prefs = await SharedPreferences.getInstance();
  final authLocalDataSource = AuthLocalDataSourceImpl(prefs: prefs);
  final httpClient = http.Client();
  final authApi = AuthApi(client: httpClient);
  final authRepository = AuthRepository(
    authApi: authApi,
    localStorage: authLocalDataSource,
  );

  final taskLocalDataSource = TaskLocalDataSource();
  await taskLocalDataSource.init();
  final taskApi = TaskApi(client: httpClient);
  final taskRepository = TaskRepository(
    taskApi: taskApi,
    localDataSource: taskLocalDataSource,
  );

  runApp(MyApp(
    authRepository: authRepository,
    taskRepository: taskRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TaskRepository taskRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.taskRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<TaskRepository>.value(value: taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)
              ..add(CheckAuthEvent()),
          ),
          BlocProvider<TaskBloc>(
            create: (context) => TaskBloc(taskRepository: taskRepository),
          ),
        ],
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