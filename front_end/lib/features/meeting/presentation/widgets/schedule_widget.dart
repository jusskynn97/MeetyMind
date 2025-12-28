import 'package:flutter/material.dart';

class ScheduleItem {
  final String time;
  final String type;
  final Color color;
  ScheduleItem({required this.time, required this.type, required this.color});
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

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final Map<DateTime, List<ScheduleItem>> _schedules = {
    DateTime.now(): [
      ScheduleItem(time: "10:00 AM", type: "Pickup", color: Color(0xFF0066FF)),
      ScheduleItem(time: "5:00 PM", type: "Dropoff", color: Color(0xFFFF6B00)),
    ],
    DateTime.now().add(Duration(days: 2)): [
      ScheduleItem(time: "2:00 PM", type: "Delivery", color: Colors.purple),
    ],
  };

  List<ScheduleItem> _getSchedulesForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _schedules[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final schedulesToday = _getSchedulesForDay(widget.selectedDay!);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedules on ${formatDate(widget.selectedDay!)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            schedulesToday.isEmpty
                ? Center(
                    child: Text(
                      "No schedules yet.\nTap + to add one!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                      itemCount: schedulesToday.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = schedulesToday[index];
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.color.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: item.color),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.type,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      color: item.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
