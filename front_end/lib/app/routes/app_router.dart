import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/features/auth/presentation/blocs/login_bloc.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_event.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:front_end/app/routes/routes.dart';
import 'package:front_end/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';
import 'package:front_end/features/main_navigation/presentation/pages/main_page.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  late final GoRouter router = GoRouter(
    initialLocation: Routes.login, //Default: Onboarding page
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => BlocProvider(
          create: (_) => sl<LoginBloc>(), 
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: Routes.main,
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => sl<DashboardBloc>()..add(LoadDashboardEvent()) 
            ),
            BlocProvider<RecordingBloc>(
              create: (_) => sl<RecordingBloc>(),
            ),
          ], 
          child: const MainPage()),
      ),
    ],
  );
}
