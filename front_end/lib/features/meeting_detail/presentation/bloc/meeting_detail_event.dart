// lib/features/meeting/presentation/bloc/transcript/transcript_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class TranscriptEvent extends Equatable {
  const TranscriptEvent();

  @override
  List<Object?> get props => [];
}

class UploadAudioFileEvent extends TranscriptEvent {
  final String meetingId;
  final File audioFile;

  const UploadAudioFileEvent({
    required this.meetingId,
    required this.audioFile,
  });

  @override
  List<Object?> get props => [meetingId, audioFile];
}

class GetTranscriptEvent extends TranscriptEvent {
  final String meetingId;

  const GetTranscriptEvent(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}

class StartPollingEvent extends TranscriptEvent {
  final String meetingId;

  const StartPollingEvent(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}

class StopPollingEvent extends TranscriptEvent {
  const StopPollingEvent();
}