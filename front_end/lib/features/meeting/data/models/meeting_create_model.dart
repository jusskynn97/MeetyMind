import 'package:front_end/features/meeting/domain/entities/meeting_create_request.dart';

class MeetingCreateModel extends MeetingCreateRequest {
  const MeetingCreateModel({
    required super.title,
    required super.description,
    required super.location,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.participants,
  });

  Map<String, dynamic> toJson() {
  final formattedDate = '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
  return {
    "title": title,
    "description": description,
    "location": location,
    "date": formattedDate, // Format: yyyy-MM-dd
    "startTime": startTime,
    "endTime": endTime,
    "participants": participants,
  };
}

  factory MeetingCreateModel.fromEntity(MeetingCreateRequest req) {
    return MeetingCreateModel(
      title: req.title,
      description: req.description,
      location: req.location,
      date: req.date,
      startTime: req.startTime,
      endTime: req.endTime,
      participants: req.participants,
    );
  }
}
