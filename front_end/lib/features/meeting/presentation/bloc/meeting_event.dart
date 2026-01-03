part of 'meeting_bloc.dart';

abstract class MeetingEvent {}

class CreateMeetingEvent extends MeetingEvent {
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final List<String> participants;

  CreateMeetingEvent({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.participants,
  });
}


class GetMeetingByDateEvent extends MeetingEvent {
  final DateTime date;

  GetMeetingByDateEvent(this.date);
}

class DeleteMeetingEvent extends MeetingEvent {
  final String meetingId;

  DeleteMeetingEvent({required this.meetingId});
}

class UpdateMeetingEvent extends MeetingEvent {
  final String meetingId;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final List<String> participants;

  UpdateMeetingEvent({
    required this.meetingId,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.participants,
  });
}