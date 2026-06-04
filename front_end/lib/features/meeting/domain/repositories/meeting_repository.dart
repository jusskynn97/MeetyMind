import 'package:front_end/features/meeting/domain/entities/meeting.dart';
import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';

abstract class MeetingRepository {
  Future<void> createMeeting(MeetingCreateRequest meetingCreateRequest);
  Future<List<Meeting>> getMeetingsByDate(DateTime date);
}