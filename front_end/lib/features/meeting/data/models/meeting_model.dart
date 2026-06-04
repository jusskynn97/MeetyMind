import 'package:front_end/features/meeting/domain/entities/meeting.dart';
class MeetingModel extends Meeting {
  const MeetingModel({
    required super.meetingId,
    required super.createdBy,
    required super.title,
    required super.description,
    required super.location,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.createdAt,
    required super.updatedAt,
    required super.isOwner,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      meetingId: json['meetingId'],
      createdBy: json['createdBy'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']),
      isOwner: json['isOwner'],
    );
  }

  Meeting toEntity() {
    return Meeting(
      meetingId: meetingId,
      createdBy: createdBy,
      title: title,
      description: description,
      location: location,
      date: date,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isOwner: isOwner,
    );
  }
}