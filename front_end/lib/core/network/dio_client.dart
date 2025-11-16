import 'package:dio/dio.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/core/network/api_config.dart';
import 'package:front_end/core/network/auth_interceptor.dart';
import 'package:front_end/features/auth/data/datasources/auth_local_data_source.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl, 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  static Dio get instance {
    // Xóa interceptor cũ nếu có
    _dio.interceptors.clear();

    // Thêm AuthInterceptor
    final localDataSource = sl<AuthLocalDataSource>();
    _dio.interceptors.add(AuthInterceptor(localDataSource));

    // Optional: Logging
    // _dio.interceptors.add(LogInterceptor(responseBody: true));

    return _dio;
  }
}