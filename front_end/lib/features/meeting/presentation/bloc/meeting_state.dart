import 'package:front_end/features/meeting/domain/entities/meeting.dart';

abstract class MeetingState {
  const MeetingState();
}

// ====== Dùng cho Create Meeting (giữ nguyên như cũ của bạn) ======
class CreateMeetingInitial extends MeetingState {}
class CreateMeetingLoading extends MeetingState {}
class CreateMeetingSuccess extends MeetingState {}
class CreateMeetingFailure extends MeetingState {
  final String error;
  CreateMeetingFailure(this.error);
}

// ====== Dùng cho Fetch meetings theo ngày (sửa ở đây) ======
class Initial extends MeetingState {}
class Loading extends MeetingState {}

class Success extends MeetingState {
  final List<Meeting> meetings;  // THÊM DÒNG NÀY
  const Success(this.meetings);  // THÊM DÒNG NÀY
}

class Failure extends MeetingState {  // Đổi tên từ Loaded thành Failure cho rõ nghĩa
  final String error;
  const Failure(this.error);
}