import 'package:dio/dio.dart';
import 'package:front_end/features/meeting/data/datasources/meeting_remote_data_source.dart';
import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';
import 'package:front_end/features/meeting/domain/repositories/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteDataSource remote;

  MeetingRepositoryImpl(this.remote);

  @override
  Future<void> createMeeting(MeetingCreateRequest meetingCreateRequest) {
    try {
      final model = remote.createMeeting(meetingCreateRequest);
      return model;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    // TODO: implement createMeeting
  }

  @override
  Future<List> fetchMeetings(DateTime date) {
    // TODO: implement fetchMeetings
    throw UnimplementedError();
  }
}