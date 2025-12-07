import 'package:front_end/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:get_it/get_it.dart';

class RecordingInjection {
  static void register(GetIt sl) {
    sl.registerFactory<RecordingBloc>(
      () => RecordingBloc(),
    );
  }
}