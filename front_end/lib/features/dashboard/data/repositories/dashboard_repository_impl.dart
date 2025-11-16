import 'package:front_end/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:front_end/features/dashboard/domain/entities/user_entity.dart';
import 'package:front_end/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl(this.remote);

  @override
  Future<UserEntity> getMe() async {
    final model = await remote.getMe();
    return model; // vì UserModel extends UserEntity
  }
}