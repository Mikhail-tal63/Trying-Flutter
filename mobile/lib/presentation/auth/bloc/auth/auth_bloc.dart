// 📁 presentation/auth/bloc/auth/auth_bloc.dart

import 'dart:developer';
import 'package:bloc/bloc.dart';

import 'package:ToDo/data/repositories/auth_repository.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_event.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<RefreshTokenEvent>(_onRefreshToken);
  }


  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {

      final user = await authRepository.login(event.email, event.password);
      

      emit(AuthAuthenticated(user: user));
      
      log('✅ Login successful for user: ${user.email}');
      
    } catch (e, stackTrace) {

      log('❌ Login error: $e', error: e, stackTrace: stackTrace);
      
      final errorMessage = _getUserFriendlyErrorMessage(e);
      emit(AuthError(message: errorMessage));
    }
  }


  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await authRepository.register(
        event.name,
        event.email,
        event.password,
      );
      
      emit(AuthAuthenticated(user: user));
      
      log('✅ Registration successful for user: ${user.email}');
      
    } catch (e, stackTrace) {
      log('❌ Register error: $e', error: e, stackTrace: stackTrace);
      
      final errorMessage = _getUserFriendlyErrorMessage(e);
      emit(AuthError(message: errorMessage));
    }
  }


  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
 
    try {
      final refreshToken = await authRepository.getRefreshToken();
      await authRepository.logout(refreshToken: refreshToken);
      
      emit(AuthUnauthenticated());
      
      log('✅ Logout successful');
      
    } catch (e, stackTrace) {
      log('❌ Logout error: $e', error: e, stackTrace: stackTrace);
      

      await authRepository.logout(refreshToken: null);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
 
    try {
      if (authRepository.isLoggedIn()) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
          log('✅ User is authenticated: ${user.email}');
        } else {
          emit(AuthUnauthenticated());
          log('⚠️ No user data found');
        }
      } else {
        emit(AuthUnauthenticated());
        log('⚠️ User is not authenticated');
      }
    } catch (e, stackTrace) {
      log('❌ Check auth error: $e', error: e, stackTrace: stackTrace);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      log('🔄 Attempting token refresh...');
      
      final success = await authRepository.refreshToken();
      
      if (success) {
        log('✅ Token refreshed successfully');
        

        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        }
      } else {
        log('❌ Token refresh failed');
        emit(AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      log('❌ Refresh token error: $e', error: e, stackTrace: stackTrace);
      emit(AuthUnauthenticated());
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Unable to connect. Please check your internet connection.';
    } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorString.contains('404')) {
      return 'Server not found. Please try again later.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('email')) {
      return 'Invalid email format.';
    } else if (errorString.contains('password')) {
      return 'Password must be at least 6 characters.';
    } else {
      return 'An error occurred: $errorString';
    }
  }
  

  @override
  Future<void> close() {
    log('🔒 AuthBloc closed');
    return super.close();
  }
}