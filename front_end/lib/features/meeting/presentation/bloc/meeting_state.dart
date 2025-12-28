abstract class MeetingState {}

class CreateMeetingInitial extends MeetingState {}
class CreateMeetingLoading extends MeetingState {}
class CreateMeetingSuccess extends MeetingState {}
class CreateMeetingFailure extends MeetingState {
  final String error;
  CreateMeetingFailure(this.error);
}