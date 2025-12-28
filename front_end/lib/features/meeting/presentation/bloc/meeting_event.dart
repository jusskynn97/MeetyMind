part of 'meeting_bloc.dart';

abstract class MeetingEvent {}

class CreateMeetingEvent extends MeetingEvent {
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;

  CreateMeetingEvent({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}