import 'package:dio/dio.dart';
import 'package:front_end/core/network/api_config.dart';
import 'package:front_end/core/network/dio_client.dart';
import 'package:front_end/features/auth/domain/entities/user_entity.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String email, String password);
  Future<UserEntity> getProfile(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio); // constructor không cần tham số

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.authLogin,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.statusMessage,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<UserEntity> getProfile(String token) async {
    final response = await _dio.get(
      '/api/auth/me',
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    return UserEntity.fromJson(response.data);
  }


}
