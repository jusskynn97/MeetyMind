import 'package:flutter/material.dart';
import 'package:front_end/app/theme/colors.dart';

class NextMeetingWidget extends StatefulWidget {
  const NextMeetingWidget({super.key});

  @override
  State<NextMeetingWidget> createState() => _NextMeetingWidgetState();
}

class _NextMeetingWidgetState extends State<NextMeetingWidget> {
  final PageController _pageController = PageController(
    viewportFraction: 0.78, // Hiện 1 item lớn + 2 item nhỏ 2 bên
  );

  @override
  Widget build(BuildContext context) {
    final meetings = [
      {
        "title": "Project Meeting",
        "agenda": "Status Update",
        "date": "July 6th",
        "time": "9:15 AM",
        "color": Colors.teal,
      },
      {
        "title": "Brainstorm Session",
        "agenda": "New Ideas",
        "date": "July 9th",
        "time": "10:30 AM",
        "color": Colors.deepOrange,
      },
      {
        "title": "Client Meeting",
        "agenda": "Requirement Sync",
        "date": "July 12th",
        "time": "11:00 AM",
        "color": Colors.indigo,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Next Meeting",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColorManager.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final item = meetings[index];

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index).abs();
                    value = (1 - (value * 0.2)).clamp(0.8, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOut.transform(value),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _MeetingCard(
                    title: item["title"]! as String,
                    agenda: item["agenda"]! as String,
                    date: item["date"]! as String,
                    time: item["time"]! as String,
                    color: item["color"]! as Color,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final String title;
  final String agenda;
  final String date;
  final String time;
  final Color color;

  const _MeetingCard({
    required this.title,
    required this.agenda,
    required this.date,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Agenda: $agenda",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Text(
                      "Going:",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 10, backgroundColor: Colors.white),
                    SizedBox(width: 4),
                    CircleAvatar(radius: 10, backgroundColor: Colors.white),
                    SizedBox(width: 4),
                    CircleAvatar(radius: 10, backgroundColor: Colors.white),
                  ],
                )
              ],
            ),
          ),

          // Right: Date
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          )
        ],
      ),
    );
  }
}
