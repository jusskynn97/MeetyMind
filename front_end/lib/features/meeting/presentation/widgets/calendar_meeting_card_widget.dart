import 'package:flutter/material.dart';

class CalendarMeetingCardWidget extends StatelessWidget {
  final Map<String, dynamic> meeting;
  final int index;
  final VoidCallback onLongPress;

  const CalendarMeetingCardWidget({
    super.key,
    required this.meeting,
    required this.index,
    required this.onLongPress,
  });

  String _formatTime(String startTime, String endTime) {
    final start = startTime.substring(0, 5);
    final end = endTime.substring(0, 5);
    return "$start - $end";
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(meeting['color'] ?? 0xFF0066FF);

    return GestureDetector(
      onTap: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     color: color.withOpacity(0.2),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Icon(Icons.event_rounded, color: color, size: 20),
                // ),
                // const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meeting['title'] ?? 'Untitled Meeting',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (meeting['isOwner'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Owner',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(
                              meeting['startTime'] ?? '00:00:00',
                              meeting['endTime'] ?? '00:00:00',
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    meeting['location'] ?? 'No location',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (meeting['description']?.toString().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                meeting['description'],
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
