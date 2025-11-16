import 'package:dio/dio.dart';
import 'package:front_end/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:front_end/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:front_end/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:front_end/features/dashboard/domain/usecases/get_me_usecase.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:get_it/get_it.dart';

class DashboardInjection {
  static void register(GetIt sl) {
    sl.registerLazySingleton<DashboardRemoteDataSource>(
      () => UserRemoteDataSourceImpl(sl<Dio>()),
    );

    sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl<DashboardRemoteDataSource>()),
    );

    sl.registerLazySingleton<GetMeUseCase>(
      () => GetMeUseCase(sl<DashboardRepository>()),
    );

    sl.registerFactory<DashboardBloc>(
      () => DashboardBloc(sl<GetMeUseCase>()),
    );
  }
}