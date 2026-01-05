
import 'package:dio/dio.dart';
import 'package:front_end/features/meeting_detail/data/datasources/transcript_remote_datesource.dart';
import 'package:front_end/features/meeting_detail/data/repositories/transcript_repository_impl.dart';
import 'package:front_end/features/meeting_detail/domain/repositories/transcript_repository.dart';
import 'package:front_end/features/meeting_detail/domain/usecases/get_transcript_usecase.dart';
import 'package:front_end/features/meeting_detail/domain/usecases/upload_audio_usecase.dart';
import 'package:front_end/features/meeting_detail/presentation/bloc/meeting_detail_bloc.dart';
import 'package:get_it/get_it.dart';

class MeetingDetailInjection {
  static void register(GetIt sl) {
    sl.registerFactory(
      () => TranscriptBloc(
        sl<UploadAudioUsecase>(),
        sl<GetTranscriptUsecase>(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => UploadAudioUsecase(sl()));
    sl.registerLazySingleton(() => GetTranscriptUsecase(sl()));

    // Repository
    sl.registerLazySingleton<TranscriptRepository>(
      () => TranscriptRepositoryImpl(sl<TranscriptRemoteDataSource>()),
    );

    // Data sources
    sl.registerLazySingleton<TranscriptRemoteDataSource>(
      () => TranscriptRemoteDataSourceImpl(sl<Dio>()),
    );
  }
}