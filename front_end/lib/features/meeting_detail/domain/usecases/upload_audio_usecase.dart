import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transcript_repository.dart';

class UploadAudioUsecase {
  final TranscriptRepository repository;

  UploadAudioUsecase(this.repository);

  Future<Either<Failure, String>> call(UploadAudioParams params) async {
    return await repository.uploadAudioFile(
      meetingId: params.meetingId,
      audioFile: params.audioFile,
    );
  }
}

class UploadAudioParams {
  final String meetingId;
  final File audioFile;

  UploadAudioParams({
    required this.meetingId,
    required this.audioFile,
  });
}