import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final AuthRepository repository;

  LoginBloc(this.loginUseCase, this.repository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckSavedToken>(_onCheckSavedToken);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onCheckSavedToken(CheckSavedToken event, Emitter<LoginState> emit) async {
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
}