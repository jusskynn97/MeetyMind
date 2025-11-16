import 'package:dio/dio.dart';
import 'package:front_end/core/network/api_config.dart';
import 'package:front_end/features/dashboard/data/models/user_model.dart';

abstract class DashboardRemoteDataSource {
  Future<UserModel> getMe();
}

class UserRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> getMe() async {
    final response = await dio.get(ApiConfig.userMe);
    return UserModel.fromJson(response.data['data']);
  }
}
