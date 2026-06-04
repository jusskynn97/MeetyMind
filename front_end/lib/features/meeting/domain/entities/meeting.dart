class Meeting {
  final String meetingId;
  final String title;
  final String createdBy;
  final String description;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOwner;

  const Meeting({
    required this.meetingId,
    required this.title,
    required this.createdBy,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.updatedAt,
    required this.isOwner,
  });
}
