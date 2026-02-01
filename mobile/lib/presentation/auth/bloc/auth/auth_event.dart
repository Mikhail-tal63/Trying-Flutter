

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class RefreshTokenEvent extends AuthEvent {} 

class UpdateUserEvent extends AuthEvent {  
  final String? name;
  final String? avatarUrl;

  const UpdateUserEvent({this.name, this.avatarUrl});

  @override
  List<Object> get props => [
        if (name != null) name!,
        if (avatarUrl != null) avatarUrl!,
      ];
}