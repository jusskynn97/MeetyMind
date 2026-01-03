abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted(this.email, this.password);
}

class CheckSavedToken extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class TokenExpired extends AuthEvent {}