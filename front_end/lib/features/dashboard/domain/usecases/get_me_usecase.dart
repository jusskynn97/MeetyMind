
import 'package:front_end/features/dashboard/domain/entities/user_entity.dart';
import 'package:front_end/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetMeUseCase {
  final DashboardRepository repository;

  GetMeUseCase(this.repository);

  Future<UserEntity> call() => repository.getMe();
}