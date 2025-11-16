// app/di/modules/auth_module.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:front_end/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:front_end/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:front_end/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:front_end/features/auth/domain/repositories/auth_repository.dart';
import 'package:front_end/features/auth/domain/usecases/login_usecase.dart';
import 'package:front_end/features/auth/presentation/blocs/login_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInjection {
  static Future<void> register(GetIt sl) async {
    // Đảm bảo SharedPreferences đã sẵn sàng
    await sl.allReady();

    // Data Sources
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<Dio>()),
    );

    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl<SharedPreferences>()),
    );

    // Repository
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        sl<AuthRemoteDataSource>(),
        sl<AuthLocalDataSource>(),
      ),
    );

    // Use Case
    sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));

    // Bloc (factory → tạo mới mỗi lần)
    sl.registerFactory(() => LoginBloc(
          sl<LoginUseCase>(),
          sl<AuthRepository>(),
        ));
  }
}