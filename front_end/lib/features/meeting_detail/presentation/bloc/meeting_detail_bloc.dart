// lib/features/meeting/presentation/bloc/transcript/transcript_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/meeting_detail/domain/entities/transcript.dart';
import 'package:front_end/features/meeting_detail/domain/repositories/transcript_repository.dart';
import 'package:front_end/features/meeting_detail/domain/usecases/get_transcript_usecase.dart';
import 'package:front_end/features/meeting_detail/domain/usecases/upload_audio_usecase.dart';
import 'package:front_end/features/meeting_detail/presentation/bloc/meeting_detail_event.dart';
import 'package:front_end/features/meeting_detail/presentation/bloc/meeting_detail_state.dart';

class TranscriptBloc extends Bloc<TranscriptEvent, TranscriptState> {
  final UploadAudioUsecase uploadAudioUsecase;
  final GetTranscriptUsecase getTranscriptUsecase;
  
  Timer? _pollingTimer;

  TranscriptBloc(this.uploadAudioUsecase,this.getTranscriptUsecase) : super(TranscriptInitial()) {
    on<UploadAudioFileEvent>(_onUploadAudioFile);
    on<GetTranscriptEvent>(_onGetTranscript);
    on<StartPollingEvent>(_onStartPolling);
    on<StopPollingEvent>(_onStopPolling);
  }

  Future<void> _onUploadAudioFile(
    UploadAudioFileEvent event,
    Emitter<TranscriptState> emit,
  ) async {
    emit(const TranscriptUploading('Uploading audio file...'));

    final result = await uploadAudioUsecase(
      UploadAudioParams(
        meetingId: event.meetingId,
        audioFile: event.audioFile,
      ),
    );

    result.fold(
      (failure) => emit(TranscriptError(failure.message)),
      (success) {
        // Bắt đầu polling sau khi upload thành công
        add(StartPollingEvent(event.meetingId));
      },
    );
  }

  Future<void> _onGetTranscript(
    GetTranscriptEvent event,
    Emitter<TranscriptState> emit,
  ) async {
    emit(TranscriptLoading());

    final result = await getTranscriptUsecase(event.meetingId);

    result.fold(
      (failure) {
        if (failure.message.toLowerCase().contains('not found')) {
          emit(TranscriptInitial());
        } else {
          emit(TranscriptError(failure.message));
        }
      },
      (transcript) {
        if (transcript == null) {
          emit(TranscriptInitial());
          return;
        }
        if (transcript.status == TranscriptionStatus.completed) {
          emit(TranscriptLoaded(transcript));
        } else if (transcript.status == TranscriptionStatus.failed) {
          emit(TranscriptError(
            transcript.errorMessage ?? 'Transcription failed',
          ));
        } else {
          emit(TranscriptProcessing(
            status: transcript.status,
            message: _getStatusMessage(transcript.status),
          ));
        }
      },
    );
  }

  Future<void> _onStartPolling(
    StartPollingEvent event,
    Emitter<TranscriptState> emit,
  ) async {
    // Cancel existing timer if any
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        final result = await getTranscriptUsecase(event.meetingId);

        result.fold(
          (failure) {
            timer.cancel();
            emit(TranscriptError(failure.message));
          },
          (transcript) {
            if (transcript == null) {
              return;
            }
            if (transcript.status == TranscriptionStatus.completed) {
              timer.cancel();
              emit(TranscriptLoaded(transcript));
            } else if (transcript.status == TranscriptionStatus.failed) {
              timer.cancel();
              emit(TranscriptError(
                transcript.errorMessage ?? 'Transcription failed',
              ));
            } else {
              emit(TranscriptProcessing(
                status: transcript.status,
                message: _getStatusMessage(transcript.status),
              ));
            }
          },
        );
      },
    );
  }

  void _onStopPolling(
    StopPollingEvent event,
    Emitter<TranscriptState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  String _getStatusMessage(TranscriptionStatus status) {
    switch (status) {
      case TranscriptionStatus.queued:
        return 'Waiting in queue...';
      case TranscriptionStatus.processing:
        return 'Processing audio...';
      case TranscriptionStatus.uploading:
        return 'Uploading to cloud...';
      case TranscriptionStatus.completed:
        return 'Completed';
      case TranscriptionStatus.failed:
        return 'Failed';
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}