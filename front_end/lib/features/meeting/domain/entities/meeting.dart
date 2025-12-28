class Meeting {
  final String meetingId;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Meeting({
    required this.meetingId,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });
}
