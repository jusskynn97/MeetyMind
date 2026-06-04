import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_state.dart';
import 'package:front_end/features/meeting/presentation/widgets/calendar_meeting_card_widget.dart';

class CalendarScheduleWidget extends StatelessWidget {
  final DateTime? selectedDay;
  final Function(int?, Map<String, dynamic>?) onMeetingSelected;
  final int? selectedMeetingIndex;
  final AnimationController blurController;

  const CalendarScheduleWidget({
    super.key,
    required this.selectedDay,
    required this.onMeetingSelected,
    this.selectedMeetingIndex,
    required this.blurController,
  });

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              "Schedules on ${_formatDate(selectedDay!)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // BlocBuilder để lắng nghe state từ MeetingBloc
            Expanded(
              child: BlocBuilder<MeetingBloc, MeetingState>(
                builder: (context, state) {
                  if (state is Loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is Failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            state.error,
                            style: TextStyle(fontSize: 16, color: Colors.red.shade400),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<MeetingBloc>().add(GetMeetingByDateEvent(selectedDay!));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is Success && state.meetings.isEmpty) {
                    return const Center(
                      child: Text(
                        "No schedules yet.\nTap + to add one!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  if (state is Success) {
                    return ListView.builder(
                      itemCount: state.meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = state.meetings[index];

                        final meetingMap = {
                          'meetingId': meeting.meetingId,
                          'title': meeting.title,
                          'description': meeting.description,
                          'location': meeting.location,
                          'startTime': meeting.startTime,
                          'endTime': meeting.endTime,
                          'isOwner': meeting.isOwner,
                          'color': meeting.isOwner ? 0xFF0066FF : 0xFF00A3A3,
                        };

                        return CalendarMeetingCardWidget(
                          meeting: meetingMap,
                          index: index,
                          onLongPress: () => onMeetingSelected(index, meetingMap),
                        );
                      },
                    );
                  }

                  // Trường hợp Initial hoặc chưa fetch
                  return const Center(
                    child: Text(
                      "No schedules yet.\nTap + to add one!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
}
