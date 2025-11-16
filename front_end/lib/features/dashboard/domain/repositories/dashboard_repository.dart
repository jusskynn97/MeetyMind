
import 'package:front_end/features/dashboard/domain/entities/user_entity.dart';

abstract class DashboardRepository {
  Future<UserEntity> getMe();
}