import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';

abstract class MeetingRepository {
  Future<void> createMeeting(MeetingCreateRequest meetingCreateRequest);
  Future<List<dynamic>> fetchMeetings(DateTime date);
}