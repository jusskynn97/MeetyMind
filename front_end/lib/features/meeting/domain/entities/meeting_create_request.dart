class MeetingCreateRequest {
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final List<String> participants;

  const MeetingCreateRequest({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.participants,
  });
}
