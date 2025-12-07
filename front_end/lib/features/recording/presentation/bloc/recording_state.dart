import 'package:equatable/equatable.dart';

enum RecordingStatus {
  idle,
  recording,
  paused,
}

class RecordingState extends Equatable {
  final RecordingStatus status;
  final int recordingSeconds;

  const RecordingState({
    this.status = RecordingStatus.idle,
    this.recordingSeconds = 0,
  });

  // 👉 Getter tiện dụng
  bool get isRecording => status == RecordingStatus.recording;
  bool get isPaused => status == RecordingStatus.paused;
  bool get isIdle => status == RecordingStatus.idle;

  RecordingState copyWith({
    RecordingStatus? status,
    int? recordingSeconds,
  }) {
    return RecordingState(
      status: status ?? this.status,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
    );
  }

  @override
  List<Object?> get props => [status, recordingSeconds];
}
