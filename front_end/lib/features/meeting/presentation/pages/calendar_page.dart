import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_bottom_sheet.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_header_widget.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_menu_widget.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_meeting_preview_widget.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_schedule_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  int? _selectedMeetingIndex;
  Map<String, dynamic>? _selectedMeeting;
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;
  late Animation<double> _overlayAnimation;
  late MeetingBloc _meetingBloc;

  final DateTime _firstDay = DateTime.now().subtract(const Duration(days: 365));
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 180));

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    
    // Khởi tạo MeetingBloc
    _meetingBloc = sl<MeetingBloc>();
    
    // Fetch meetings cho ngày hiện tại
    _meetingBloc.add(GetMeetingByDateEvent(_selectedDay!));
    
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeOut),
    );
    
    _overlayAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _blurController.dispose();
    _meetingBloc.close();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedMeetingIndex = null;
      _selectedMeeting = null;
    });
    _blurController.reverse();
    
    // Fetch meetings cho ngày mới được chọn
    _meetingBloc.add(GetMeetingByDateEvent(selectedDay));
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() => _focusedDay = focusedDay);
  }

  void _onMeetingSelected(int? index, Map<String, dynamic>? meeting) {
    setState(() {
      _selectedMeetingIndex = index;
      _selectedMeeting = meeting;
    });
    if (index != null) {
      _blurController.forward();
    } else {
      _blurController.reverse();
    }
  }

  void _onMeetingDeleted(String meetingId) {
    // _meetingBloc.add(DeleteMeetingEvent(meetingId));
    _onMeetingSelected(null, null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _meetingBloc,
      child: Scaffold(
        backgroundColor: ColorManager.background,
        body: SafeArea(
          child: Stack(
            children: [
              // Nội dung chính với blur
              AnimatedBuilder(
                animation: _blurAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: _blurAnimation.value,
                          sigmaY: _blurAnimation.value,
                        ),
                        child: AbsorbPointer(
                          absorbing: _selectedMeetingIndex != null,
                          child: Column(
                            children: [
                              CalendarHeaderWidget(
                                firstDay: _firstDay,
                                lastDay: _lastDay,
                                focusedDay: _focusedDay,
                                selectedDay: _selectedDay,
                                onDaySelected: _onDaySelected,
                                onPageChanged: _onPageChanged,
                              ),
                              const SizedBox(height: 16),
                              CalendarScheduleWidget(
                                selectedDay: _selectedDay,
                                onMeetingSelected: _onMeetingSelected,
                                selectedMeetingIndex: _selectedMeetingIndex,
                                blurController: _blurController,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Dark overlay
                      if (_selectedMeetingIndex != null)
                        Container(
                          color: Colors.black.withOpacity(_overlayAnimation.value),
                        ),
                    ],
                  );
                },
              ),

              // FAB
              if (_selectedMeetingIndex == null)
                Positioned(
                  bottom: 30,
                  right: 24,
                  child: FloatingActionButton(
                    onPressed: _selectedDay == null
                        ? null
                        : () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) {
                                return BlocProvider.value(
                                  value: _meetingBloc,
                                  child: CalendarBottomSheet(selectedDate: _selectedDay),
                                );
                              },
                            ).then((_) {
                              // Refresh meetings sau khi đóng bottom sheet
                              _meetingBloc.add(GetMeetingByDateEvent(_selectedDay!));
                            }),
                    backgroundColor: _selectedDay == null
                        ? Colors.grey.shade400
                        : ColorManager.primary.colors.first,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    child: const Icon(Icons.add_rounded, size: 32),
                  ),
                ),

              // Meeting card và menu overlay
              if (_selectedMeetingIndex != null && _selectedMeeting != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => _onMeetingSelected(null, null),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {}, // Prevent dismiss when tapping card/menu
                        child: AnimatedBuilder(
                          animation: _blurController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.85 + (_blurController.value * 0.15),
                              child: Opacity(
                                opacity: _blurController.value.clamp(0.0, 1.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Menu options
                                    CalendarMenuWidget(
                                      meeting: _selectedMeeting!,
                                      onViewDetails: () {
                                        _onMeetingSelected(null, null);
                                        // TODO: Navigate to meeting details page
                                      },
                                      onEdit: () {
                                        _onMeetingSelected(null, null);
                                        // TODO: Navigate to edit meeting page
                                      },
                                      onDelete: () {
                                        _showDeleteConfirmation();
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    // Meeting card preview
                                    CalendarMeetingPreviewWidget(meeting: _selectedMeeting!),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Meeting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${_selectedMeeting!['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _onMeetingDeleted(_selectedMeeting!['meetingId']);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Meeting deleted successfully'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
