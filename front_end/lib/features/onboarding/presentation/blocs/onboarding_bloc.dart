import 'package:flutter_bloc/flutter_bloc.dart';

sealed class OnboardingEvent {}
class OnboardingNextPress extends OnboardingEvent {}

sealed class OnboardingState {}
class OnboardingInitial extends OnboardingState {}
class OnboardingInProgress extends OnboardingState {}
class OnboardingCompleted extends OnboardingState {}
class OnboardingFailed extends OnboardingState {
  final String errorMessage;
  OnboardingFailed(this.errorMessage);
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<OnboardingNextPress>((event, emit) async {
      emit(OnboardingInProgress());
      try {
        // Simulate onboarding process
        await Future.delayed(Duration(seconds: 2));
        emit(OnboardingCompleted());
      } catch (e) {
        emit(OnboardingFailed(e.toString()));
      }
    });
  }
}