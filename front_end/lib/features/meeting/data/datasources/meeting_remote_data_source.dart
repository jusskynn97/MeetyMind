import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:front_end/core/network/api_config.dart';
import 'package:front_end/features/meeting/data/models/meeting_create_model.dart';
import 'package:front_end/features/meeting/data/models/meeting_model.dart';
import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';

abstract class MeetingRemoteDataSource {
  Future<void> createMeeting(MeetingCreateRequest meetingCreateRequest);
  Future<List<MeetingModel>> fetchMeetings(String token);
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  final Dio _dio;

  MeetingRemoteDataSourceImpl(this._dio);
  
  @override
  Future<void> createMeeting(MeetingCreateRequest meetingCreateRequest) async {
    try {
      // print("Token: ${_dio.options.headers['Authorization']}");

      final response = await _dio.post(
        ApiConfig.meetingCreate,
        data: MeetingCreateModel.fromEntity(meetingCreateRequest).toJson(),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.statusMessage,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<MeetingModel>> fetchMeetings(String token) {
    // TODO: implement fetchMeetings
    throw UnimplementedError();
  }

}