// core/network/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:front_end/features/auth/data/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;

  AuthInterceptor(this.localDataSource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await localDataSource.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Optional: Xử lý 401 → logout
    if (err.response?.statusCode == 401) {
      // Có thể emit event logout
    }
    handler.next(err);
  }
}