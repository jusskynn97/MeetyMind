import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/domain/repositories/auth_repository.dart';
import 'package:front_end/features/auth/domain/usecases/logout_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository repository;

  AuthBloc(this.loginUseCase, this.logoutUseCase, this.repository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckSavedToken>(_onCheckSavedToken);
    on<LogoutRequested>(_onLogoutRequested);
    on<TokenExpired>(_onTokenExpired);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onCheckSavedToken(CheckSavedToken event, Emitter<AuthState> emit) async {
    emit(LoginLoading());
    try {
      final token = await repository.getSavedToken();
      if (token != null) {
        emit(LoginTokenFound(token));
      } else {
        emit(LoginInitial());
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

   /// 🔥 LOGOUT CHỦ ĐỘNG
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await logoutUseCase(); // clear token
    emit(Unauthenticated());
  }

  /// 🔥 TOKEN HẾT HẠN (Interceptor gọi)
  Future<void> _onTokenExpired(
      TokenExpired event,
      Emitter<AuthState> emit,
      ) async {
    await repository.logout();
    emit(LogoutSuccess());
    emit(LoginInitial());
  }
}