// lib/features/meeting/presentation/bloc/transcript/transcript_state.dart
import 'package:equatable/equatable.dart';
import 'package:front_end/features/meeting_detail/domain/entities/transcript.dart';

abstract class TranscriptState extends Equatable {
  const TranscriptState();

  @override
  List<Object?> get props => [];
}

class TranscriptInitial extends TranscriptState {}

class TranscriptLoading extends TranscriptState {}

class TranscriptUploading extends TranscriptState {
  final String message;

  const TranscriptUploading(this.message);

  @override
  List<Object?> get props => [message];
}

class TranscriptProcessing extends TranscriptState {
  final TranscriptionStatus status;
  final String message;

  const TranscriptProcessing({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [status, message];
}

class TranscriptLoaded extends TranscriptState {
  final Transcript transcript;

  const TranscriptLoaded(this.transcript);

  @override
  List<Object?> get props => [transcript];
}

class TranscriptError extends TranscriptState {
  final String message;

  const TranscriptError(this.message);

  @override
  List<Object?> get props => [message];
}