// lib/features/meeting/data/datasources/transcript_remote_data_source.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:front_end/core/network/api_config.dart';
import '../models/transcript_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class TranscriptRemoteDataSource {
  Future<String> uploadAudioFile({
    required String meetingId,
    required File audioFile,
  });

  Future<TranscriptModel?> getTranscript(String meetingId);
}

class TranscriptRemoteDataSourceImpl implements TranscriptRemoteDataSource {
  final Dio dio;

  TranscriptRemoteDataSourceImpl(this.dio);

  @override
  Future<String> uploadAudioFile({
    required String meetingId,
    required File audioFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        ApiConfig.uploadAudio + meetingId,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? 'Audio uploaded successfully';
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Upload failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<TranscriptModel?> getTranscript(String meetingId) async {
    try {
      final response = await dio.get(
        ApiConfig.getTranscript + meetingId,
      );

      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        }
        return TranscriptModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get transcript',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }
}