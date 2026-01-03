// widgets/schedule_widget.dart - Updated version

import 'dart:ui';
import 'package:flutter/material.dart';
// Import meeting model và widget
// import 'package:your_app/models/meeting_model.dart';
// import 'package:your_app/widgets/meeting_card_widget.dart';

// models/meeting_model.dart

class Meeting {
  final String meetingId;
  final String createdBy;
  final String title;
  final String description;
  final String location;
  final String date;
  final String startTime;
  final String endTime;
  final String createdAt;
  final String? updatedAt;
  final bool isOwner;

  Meeting({
    required this.meetingId,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.updatedAt,
    required this.isOwner,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      meetingId: json['meetingId'],
      createdBy: json['createdBy'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isOwner: json['isOwner'],
    );
  }
}

// Mock data
class MockMeetings {
  static List<Meeting> getMeetings() {
    return [
      Meeting(
        meetingId: "28f5259d-c020-46bc-a74d-a37dc1c53476",
        createdBy: "58c8d870-1baf-42b8-afdd-c6223dfe6cb0",
        title: "Developer Workshop",
        description: "Thảo luận về các best practices trong Flutter development",
        location: "Meeting Room A - Floor 3",
        date: "2025-01-05",
        startTime: "09:00:00",
        endTime: "11:00:00",
        createdAt: "2025-01-03T10:00:00.000000Z",
        updatedAt: null,
        isOwner: true,
      ),
      Meeting(
        meetingId: "a8b2c3d4-e5f6-47g8-h9i0-j1k2l3m4n5o6",
        createdBy: "12345678-1234-1234-1234-123456789012",
        title: "Team Standup",
        description: "Daily standup meeting với team",
        location: "Online - Google Meet",
        date: "2025-01-05",
        startTime: "14:00:00",
        endTime: "14:30:00",
        createdAt: "2025-01-03T08:30:00.000000Z",
        updatedAt: null,
        isOwner: false,
      ),
      Meeting(
        meetingId: "b9c3d4e5-f6g7-48h9-i0j1-k2l3m4n5o6p7",
        createdBy: "87654321-4321-4321-4321-210987654321",
        title: "Client Presentation",
        description: "Trình bày demo sản phẩm cho khách hàng",
        location: "Conference Room B",
        date: "2025-01-06",
        startTime: "15:00:00",
        endTime: "16:30:00",
        createdAt: "2025-01-02T14:20:00.000000Z",
        updatedAt: "2025-01-03T09:15:00.000000Z",
        isOwner: true,
      ),
      Meeting(
        meetingId: "c0d4e5f6-g7h8-49i0-j1k2-l3m4n5o6p7q8",
        createdBy: "11111111-2222-3333-4444-555555555555",
        title: "Code Review Session",
        description: "Review PR #234 và #235",
        location: "Dev Room",
        date: "2025-01-07",
        startTime: "10:00:00",
        endTime: "11:30:00",
        createdAt: "2025-01-03T11:45:00.000000Z",
        updatedAt: null,
        isOwner: false,
      ),
    ];
  }
  
  static List<Meeting> getMeetingsForDate(DateTime date) {
    final allMeetings = getMeetings();
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return allMeetings.where((m) => m.date == dateStr).toList();
  }
}

class ScheduleWidget extends StatefulWidget {
  final DateTime? selectedDay;

  const ScheduleWidget({
    super.key,
    required this.selectedDay,
  });

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> with SingleTickerProviderStateMixin {
  int? _selectedMeetingIndex;
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Mock data meetings
  List<Map<String, dynamic>> _getMeetingsForDay(DateTime day) {
    final dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    
    // Mock data
    final allMeetings = [
      {
        "meetingId": "28f5259d-c020-46bc-a74d-a37dc1c53476",
        "createdBy": "58c8d870-1baf-42b8-afdd-c6223dfe6cb0",
        "title": "Developer Workshop",
        "description": "Thảo luận về các best practices trong Flutter development",
        "location": "Meeting Room A - Floor 3",
        "date": "2025-01-05",
        "startTime": "09:00:00",
        "endTime": "11:00:00",
        "createdAt": "2025-01-03T10:00:00.000000Z",
        "updatedAt": null,
        "isOwner": true,
        "color": 0xFF0066FF,
      },
      {
        "meetingId": "a8b2c3d4-e5f6-47g8-h9i0-j1k2l3m4n5o6",
        "createdBy": "12345678-1234-1234-1234-123456789012",
        "title": "Team Standup",
        "description": "Daily standup meeting với team",
        "location": "Online - Google Meet",
        "date": "2025-01-05",
        "startTime": "14:00:00",
        "endTime": "14:30:00",
        "createdAt": "2025-01-03T08:30:00.000000Z",
        "updatedAt": null,
        "isOwner": false,
        "color": 0xFF00C853,
      },
      {
        "meetingId": "b9c3d4e5-f6g7-48h9-i0j1-k2l3m4n5o6p7",
        "createdBy": "87654321-4321-4321-4321-210987654321",
        "title": "Client Presentation",
        "description": "Trình bày demo sản phẩm cho khách hàng",
        "location": "Conference Room B",
        "date": "2025-01-06",
        "startTime": "15:00:00",
        "endTime": "16:30:00",
        "createdAt": "2025-01-02T14:20:00.000000Z",
        "updatedAt": "2025-01-03T09:15:00.000000Z",
        "isOwner": true,
        "color": 0xFFFF6B00,
      },
      {
        "meetingId": "c0d4e5f6-g7h8-49i0-j1k2-l3m4n5o6p7q8",
        "createdBy": "11111111-2222-3333-4444-555555555555",
        "title": "Code Review Session",
        "description": "Review PR #234 và #235",
        "location": "Dev Room",
        "date": "2025-01-07",
        "startTime": "10:00:00",
        "endTime": "11:30:00",
        "createdAt": "2025-01-03T11:45:00.000000Z",
        "updatedAt": null,
        "isOwner": false,
        "color": 0xFF9C27B0,
      },
    ];

    return allMeetings.where((m) => m['date'] == dateStr).toList();
  }

  String _formatTime(String startTime, String endTime) {
    final start = startTime.substring(0, 5);
    final end = endTime.substring(0, 5);
    return "$start - $end";
  }

  void _handleLongPress(int index) {
    setState(() => _selectedMeetingIndex = index);
    _animationController.forward();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() => _selectedMeetingIndex = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetings = _getMeetingsForDay(widget.selectedDay!);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedules on ${formatDate(widget.selectedDay!)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            meetings.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        "No schedules yet.\nTap + to add one!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        final isSelected = _selectedMeetingIndex == index;
                        
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final opacity = _selectedMeetingIndex == null 
                                ? 1.0 
                                : isSelected 
                                    ? 1.0 
                                    : (1.0 - (_animationController.value * 0.7)).clamp(0.0, 1.0);
                            
                            return Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: isSelected 
                                    ? 1.0 + (_animationController.value * 0.03) 
                                    : 1.0,
                                child: _buildMeetingCard(
                                  meeting: meeting,
                                  index: index,
                                  isSelected: isSelected,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCard({
    required Map<String, dynamic> meeting,
    required int index,
    required bool isSelected,
  }) {
    final color = Color(meeting['color']);
    
    return GestureDetector(
      onLongPress: () => _handleLongPress(index),
      onTap: isSelected ? _handleDismiss : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final borderWidth = isSelected 
              ? 1.5 + (_animationController.value * 0.5)
              : 1.5;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(isSelected ? 0.6 : 0.3),
                width: borderWidth,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4 * _animationController.value),
                        blurRadius: 20 * _animationController.value,
                        spreadRadius: 2 * _animationController.value,
                        offset: Offset(0, 8 * _animationController.value),
                      ),
                    ]
                  : [
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meeting['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (meeting['isOwner'])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
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
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(meeting['startTime'], meeting['endTime']),
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
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meeting['location'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (meeting['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    meeting['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}