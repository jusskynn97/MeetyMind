import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front_end/core/network/dio_client.dart';

class CoreInjection {
  static Future<void> register(GetIt sl) async {
    // Dio: sync
    sl.registerLazySingleton<Dio>(() => DioClient.instance);

    // SharedPreferences: async → dùng registerSingletonAsync
    sl.registerSingletonAsync<SharedPreferences>(() async {
      return await SharedPreferences.getInstance();
    });
  }
}