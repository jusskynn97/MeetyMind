// lib/features/meeting/domain/usecases/get_transcript.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transcript.dart';
import '../repositories/transcript_repository.dart';

class GetTranscriptUsecase {
  final TranscriptRepository repository;

  GetTranscriptUsecase(this.repository);

  Future<Either<Failure, Transcript?>> call(String meetingId) async {
    return await repository.getTranscript(meetingId);
  }
}