import 'package:dio/dio.dart';
import 'package:front_end/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:front_end/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:front_end/features/auth/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      await localDataSource.saveToken(result.token);
      return result.user; // chuyển sang entity tại đây
    } on DioException {
      // rethrow giúp BLoC hoặc UI xử lý message dễ hơn
      rethrow;
    }
  }

  @override
  Future<String?> getSavedToken() => localDataSource.getToken();
  
  @override
  Future<UserEntity> getProfile(String token) async {
    if (token == null) throw Exception('No token found');
    return remoteDataSource.getProfile(token);
  }
  
  @override
  Future<void> logout() {
    return localDataSource.clearToken();
  }


}
