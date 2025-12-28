import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_bottom_sheet.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_header_widget.dart';
import 'package:front_end/features/meeting/presentation/widgets/schedule_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  bool _showTimeSheet = false;

  final DateTime _firstDay = DateTime.now().subtract(const Duration(days: 365));
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 180));


  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  // List<ScheduleItem> _getSchedulesForDay(DateTime day) {
  //   final key = DateTime(day.year, day.month, day.day);
  //   return _schedules[key] ?? [];
  // }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() => _focusedDay = focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    // final schedulesToday = _getSchedulesForDay(_selectedDay ?? DateTime.now());

    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Calendar
                CalendarHeaderWidget(
                  firstDay: _firstDay,
                  lastDay: _lastDay, 
                  focusedDay: _focusedDay, 
                  selectedDay: _selectedDay, 
                  onDaySelected: _onDaySelected, 
                  onPageChanged: _onPageChanged,
                ),

                const SizedBox(height: 16),

                // Schedule list
                ScheduleWidget(
                  selectedDay: _selectedDay,
                ),
              ],
            ),

            // Nút + để mở bottom sheet thêm lịch
            Positioned(
              bottom: 30,
              right: 24,
              child: FloatingActionButton(
                onPressed: _selectedDay == null
                    ? null
                    // : () => setState(() => _showTimeSheet = true), // Dùng đúng biến
                    : () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      // builder: (_) => CalendarBottomSheet(selectedDate: _selectedDay,),
                      builder: (_) {
                        return BlocProvider<MeetingBloc>(
                          create: (_) => sl<MeetingBloc>(),
                          child: CalendarBottomSheet(selectedDate: _selectedDay),
                        );
                      },
                    ),
                backgroundColor: _selectedDay == null
                    ? Colors.grey.shade400
                    : ColorManager.primary.colors.first,
                foregroundColor: Colors.white,
                elevation: 8,
                child: const Icon(Icons.add_rounded, size: 32),
              ),
            ),

            // Bottom sheet thêm lịch trình
            // if (_showTimeSheet)
            //   GestureDetector(
            //     onTap: () => setState(() => _showTimeSheet = false),
            //     child: Container(
            //       color: Colors.black.withOpacity(0.5),
            //       child: GestureDetector(
            //         onTap: () {},
            //         child: Align(
            //           alignment: Alignment.bottomCenter,
            //           child: Container(
            //             margin: const EdgeInsets.all(20),
            //             padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(28),
            //               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30)],
            //             ),
            //             child: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   children: [
            //                     const Text("Add Schedule", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            //                     const Spacer(),
            //                     IconButton(
            //                       onPressed: () => setState(() => _showTimeSheet = false),
            //                       icon: const Icon(Icons.close_rounded, size: 28),
            //                     ),
            //                   ],
            //                 ),
            //                 const SizedBox(height: 28),
            //                 _timeSlot(title: "Pickup", time: "10:00 AM – 11:00 AM", color: const Color(0xFF0066FF)),
            //                 const SizedBox(height: 20),
            //                 _timeSlot(title: "Dropoff", time: "5:00 PM – 6:00 PM", color: const Color(0xFFFF6B00)),
            //                 const SizedBox(height: 32),
            //                 SizedBox(
            //                   width: double.infinity,
            //                   child: ElevatedButton(
            //                     onPressed: () {
            //                       ScaffoldMessenger.of(context).showSnackBar(
            //                         SnackBar(
            //                           content: Text("Added to ${(_selectedDay!)}"),
            //                           backgroundColor: Colors.green.shade600,
            //                         ),
            //                       );
            //                       setState(() => _showTimeSheet = false);
            //                     },
            //                     style: ElevatedButton.styleFrom(
            //                       backgroundColor: ColorManager.primary.colors.first,
            //                       padding: const EdgeInsets.symmetric(vertical: 18),
            //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            //                     ),
            //                     child: const Text("Confirm & Add", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _timeSlot({required String title, required String time, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(time, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class ScheduleItem {
  final String time;
  final String type;
  final Color color;
  ScheduleItem({required this.time, required this.type, required this.color});
}