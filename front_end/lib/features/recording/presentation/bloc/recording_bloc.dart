// features/recording/presentation/bloc/recording_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'recording_event.dart';
import 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  Timer? _recordingTimer;

  RecordingBloc() : super(const RecordingState()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<UpdateRecordingTimeEvent>(_onUpdateRecordingTime);
    on<PauseRecordingEvent>(_onPauseRecording);
    on<ResumeRecordingEvent>(_onResumeRecording);
  }

  void _onStartRecording(
    StartRecordingEvent event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(
      status: RecordingStatus.recording,
      recordingSeconds: 0,
    ));

    _startTimer();
  }

  void _onStopRecording(
    StopRecordingEvent event,
    Emitter<RecordingState> emit,
  ) {
    _stopTimer();
    emit(state.copyWith(
      status: RecordingStatus.idle,
      recordingSeconds: 0,
    ));
  }

  void _onUpdateRecordingTime(
    UpdateRecordingTimeEvent event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(recordingSeconds: event.seconds));
  }

  void _onPauseRecording(
    PauseRecordingEvent event,
    Emitter<RecordingState> emit,
  ) {
    _stopTimer();
    emit(state.copyWith(status: RecordingStatus.paused));
  }

  void _onResumeRecording(
    ResumeRecordingEvent event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(status: RecordingStatus.recording));
    _startTimer();
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        add(UpdateRecordingTimeEvent(state.recordingSeconds + 1));
      },
    );
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}