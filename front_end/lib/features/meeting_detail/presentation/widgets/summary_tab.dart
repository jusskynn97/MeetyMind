import 'package:flutter/material.dart';
import 'package:front_end/app/theme/colors.dart';

class SummaryTab extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const SummaryTab({super.key, required this.meeting});

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'Not specified';
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Unknown';
    final minutes = duration.inMinutes;
    return '$minutes minute${minutes != 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = (meeting['startTime'] is DateTime)
        ? meeting['startTime'] as DateTime?
        : DateTime.tryParse(meeting['startTime'] ?? '');
    final endTime = (meeting['endTime'] is DateTime)
        ? meeting['endTime'] as DateTime?
        : DateTime.tryParse(meeting['endTime'] ?? '');
    final duration = (startTime != null && endTime != null) ? endTime.difference(startTime) : null;

    final participantsCount = meeting['participants'] is List
        ? (meeting['participants'] as List).length
        : meeting['participantsCount'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorManager.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorManager.floatingPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.calendar_today_outlined, size: 20, color: ColorManager.primarySolid),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date & Time', style: TextStyle(fontSize: 13, color: ColorManager.textSecondary)),
                          const SizedBox(height: 2),
                          Text(_formatDateTime(startTime),
                              style: TextStyle(fontSize: 15, color: ColorManager.textPrimary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorManager.floatingPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.access_time, size: 20, color: ColorManager.primarySolid),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duration', style: TextStyle(fontSize: 13, color: ColorManager.textSecondary)),
                          const SizedBox(height: 2),
                          Text(_formatDuration(duration),
                              style: TextStyle(fontSize: 15, color: ColorManager.textPrimary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorManager.floatingPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.people_outline, size: 20, color: ColorManager.primarySolid),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Participants', style: TextStyle(fontSize: 13, color: ColorManager.textSecondary)),
                          const SizedBox(height: 2),
                          Text('$participantsCount members attended',
                              style: TextStyle(fontSize: 15, color: ColorManager.textPrimary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorManager.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meeting Overview',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: ColorManager.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  meeting['summary'] ?? 'No summary available yet.',
                  style: TextStyle(fontSize: 15, height: 1.5, color: ColorManager.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}