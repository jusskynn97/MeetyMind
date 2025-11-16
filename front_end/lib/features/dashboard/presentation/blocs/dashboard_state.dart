import 'package:front_end/features/dashboard/domain/entities/user_entity.dart';

abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final UserEntity user;
  DashboardLoaded(this.user);
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}