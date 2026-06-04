import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/transcript.dart';
import '../../../../core/error/failures.dart';

abstract class TranscriptRepository {
  Future<Either<Failure, String>> uploadAudioFile({
    required String meetingId,
    required File audioFile,
  });

  Future<Either<Failure, Transcript?>> getTranscript(String meetingId);

  Future<Either<Failure, void>> pollTranscriptStatus({
    required String meetingId,
    required Function(TranscriptionStatus) onStatusUpdate,
  });
}