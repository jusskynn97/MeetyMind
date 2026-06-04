import 'package:front_end/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {}

class LoginInitial extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final UserEntity user;
  LoginSuccess(this.user);
}

class LoginFailure extends AuthState {
  final String message;
  LoginFailure(this.message);
}

class LoginTokenFound extends AuthState {
  final String token;
  LoginTokenFound(this.token);
}

class LogoutSuccess extends AuthState {}