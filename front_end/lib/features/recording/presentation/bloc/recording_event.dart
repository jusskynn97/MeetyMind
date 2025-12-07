// features/recording/presentation/bloc/recording_event.dart

abstract class RecordingEvent {}

class StartRecordingEvent extends RecordingEvent {}

class StopRecordingEvent extends RecordingEvent {}

class UpdateRecordingTimeEvent extends RecordingEvent {
  final int seconds;
  
  UpdateRecordingTimeEvent(this.seconds);
}

class PauseRecordingEvent extends RecordingEvent {}

class ResumeRecordingEvent extends RecordingEvent {}