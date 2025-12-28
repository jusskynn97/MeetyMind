import 'package:front_end/features/meeting/domain/entities/meeting.dart';

class MeetingModel extends Meeting {
  const MeetingModel({
    required super.meetingId,
    required super.title,
    required super.description,
    required super.location,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      meetingId: json["meetingId"],
      title: json["title"],
      description: json["description"],
      location: json["location"],
      date: DateTime.parse(json["date"]),
      startTime: json["startTime"],
      endTime: json["endTime"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}
