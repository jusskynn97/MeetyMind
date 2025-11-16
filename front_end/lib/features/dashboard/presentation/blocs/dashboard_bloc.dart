// features/user/presentation/blocs/dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/dashboard/domain/usecases/get_me_usecase.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_event.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetMeUseCase getMe;

  DashboardBloc(this.getMe) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final user = await getMe();
      emit(DashboardLoaded(user));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(RefreshDashboardEvent event, Emitter<DashboardState> emit) async {
    // add code for refreshment in here
    print("Refresh successful");
  }
}