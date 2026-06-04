import 'package:dio/dio.dart';
import 'package:front_end/features/meeting/data/datasources/meeting_remote_data_source.dart';
import 'package:front_end/features/meeting/data/repositories/meeting_repository_impl.dart';
import 'package:front_end/features/meeting/domain/repositories/meeting_repository.dart';
import 'package:front_end/features/meeting/domain/usecases/create_meeting_usecase.dart';
import 'package:front_end/features/meeting/domain/usecases/get_meetings_by_date_usecase.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:get_it/get_it.dart';

class MeetingInjection {
  static void register(GetIt sl) {
    sl.registerLazySingleton<MeetingRemoteDataSource>(
      () => MeetingRemoteDataSourceImpl(sl<Dio>()),
    );

    sl.registerLazySingleton<MeetingRepository>(
      () => MeetingRepositoryImpl(sl<MeetingRemoteDataSource>()),
    );

    sl.registerLazySingleton<CreateMeetingUsecase>(
      () => CreateMeetingUsecase(sl<MeetingRepository>()),
    );

    sl.registerLazySingleton<GetMeetingsByDateUsecase>(
      () => GetMeetingsByDateUsecase(sl<MeetingRepository>()),
    );

    sl.registerFactory(() => MeetingBloc(
      sl<CreateMeetingUsecase>(), 
      sl<GetMeetingsByDateUsecase>()
    ));
  }
}