import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/core/helper/go_router_refresh_steam.dart';
import 'package:front_end/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:front_end/features/auth/presentation/blocs/auth_state.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_event.dart';
import 'package:front_end/features/meeting_detail/presentation/pages/meeting_detail_page.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:front_end/app/routes/routes.dart';
import 'package:front_end/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:front_end/features/auth/presentation/pages/login_page.dart';
import 'package:front_end/features/main_navigation/presentation/pages/main_page.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  late final GoRouterRefreshStream _authRefreshListenable;
  
  factory AppRouter() => _instance;
  AppRouter._internal() {
    _authRefreshListenable = GoRouterRefreshStream(sl<AuthBloc>().stream);
  }

  late final GoRouter router = GoRouter(
    initialLocation: Routes.login,
    refreshListenable: _authRefreshListenable, // ✅ Bật lại để listen AuthBloc
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      
      // Nếu chưa authenticated, redirect về login
      if (authState is Unauthenticated || 
          authState is LoginInitial || 
          authState is LogoutSuccess) {
        return Routes.login;
      }

      // Nếu đã authenticated và đang ở login page, redirect về main
      if ((authState is LoginTokenFound || authState is LoginSuccess) &&
          state.uri.path == Routes.login) {
        return Routes.main;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginPage(),
      ),
      // GoRoute(
      //   path: Routes.meetingDetails,
      //   builder: (_, __) => const MeetingDetailPage(),
      // ),
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