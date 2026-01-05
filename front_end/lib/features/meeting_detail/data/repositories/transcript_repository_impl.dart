// lib/features/meeting/data/repositories/transcript_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:front_end/features/meeting_detail/data/datasources/transcript_remote_datesource.dart';
import '../../domain/entities/transcript.dart';
import '../../domain/repositories/transcript_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class TranscriptRepositoryImpl implements TranscriptRepository {
  final TranscriptRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo;

  TranscriptRepositoryImpl(this.remoteDataSource);
    // required this.networkInfo,);

  @override
  Future<Either<Failure, String>> uploadAudioFile({
    required String meetingId,
    required File audioFile,
  }) async {
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure());
    // }

    try {
      final result = await remoteDataSource.uploadAudioFile(
        meetingId: meetingId,
        audioFile: audioFile,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Transcript?>> getTranscript(String meetingId) async {
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure());
    // }

    try {
      final result = await remoteDataSource.getTranscript(meetingId);
      print(result?.audioPath);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> pollTranscriptStatus({
    required String meetingId,
    required Function(TranscriptionStatus) onStatusUpdate,
  }) async {
    try {
      while (true) {
        await Future.delayed(const Duration(seconds: 3));
        
        final result = await getTranscript(meetingId);
        
        result.fold(
          (failure) => throw Exception('Failed to poll status'),
          (transcript) {
            onStatusUpdate(transcript!.status);
            
            if (transcript.status == TranscriptionStatus.completed ||
                transcript.status == TranscriptionStatus.failed) {
              return;
            }
          },
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}