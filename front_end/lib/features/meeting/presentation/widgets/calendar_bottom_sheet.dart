// features/calendar/presentation/widgets/calendar_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_bloc.dart';
import 'package:front_end/features/meeting/presentation/bloc/meeting_state.dart';

class CalendarBottomSheet extends StatefulWidget {
  final DateTime? selectedDate;

  const CalendarBottomSheet({super.key, required this.selectedDate});

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    print(widget.selectedDate.toString());
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorManager.primary.colors.first,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? _startTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorManager.primary.colors.first,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  bool _isFormValid() {
    return _titleCtrl.text.isNotEmpty && _startTime != null && _endTime != null;
  }

  void _saveSchedule() {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Format thời gian đúng định dạng HH:mm:ss
    final startTimeStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00';
    final endTimeStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00';

    context.read<MeetingBloc>().add(
      CreateMeetingEvent(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        location: _locationCtrl.text,
        date: _selectedDate,
        startTime: startTimeStr,  // Đã format đúng
        endTime: endTimeStr,      // Đã format đúng
      ),
    );
    
    // Chỉ đóng dialog sau khi nhận được success
    // Navigator.pop(context); // Xóa dòng này, sẽ xử lý trong listener
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return "${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BlocConsumer<MeetingBloc, MeetingState>(
            listener: (context, state) {
              if (state is CreateMeetingSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meeting created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // Đóng bottom sheet
              } else if (state is CreateMeetingFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: ColorManager.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.event_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Schedule',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Fill in the details below',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Date picker
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: ColorManager.primary.colors
                                        .map((c) => c.withOpacity(0.1))
                                        .toList(),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ColorManager.primary.colors.first
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: ColorManager.primarySolid,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatDate(_selectedDate),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: ColorManager.primarySolid,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _isToday(_selectedDate)
                                                ? 'Today'
                                                : _isTomorrow(_selectedDate)
                                                ? 'Tomorrow'
                                                : '${_selectedDate.difference(DateTime.now()).inDays} days from now',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: ColorManager.primarySolid,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Title field
                        _buildTextField(
                          controller: _titleCtrl,
                          label: 'Title',
                          hint: 'Meeting with team',
                          icon: Icons.title_rounded,
                          required: true,
                        ),

                        const SizedBox(height: 20),

                        // Description field
                        _buildTextField(
                          controller: _descCtrl,
                          label: 'Description',
                          hint: 'Add notes or details...',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 20),

                        // Location field
                        _buildTextField(
                          controller: _locationCtrl,
                          label: 'Location',
                          hint: 'Conference Room A',
                          icon: Icons.location_on_outlined,
                        ),

                        const SizedBox(height: 24),

                        // Time section
                        const Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            // Start time
                            Expanded(
                              child: _buildTimePicker(
                                label: 'Start',
                                time: _startTime,
                                onTap: () => _pickTime(true),
                                icon: Icons.access_time_rounded,
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // End time
                            Expanded(
                              child: _buildTimePicker(
                                label: 'End',
                                time: _endTime,
                                onTap: () => _pickTime(false),
                                icon: Icons.timer_outlined,
                                required: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Save button
                        Container(
                          decoration: BoxDecoration(
                            gradient: ColorManager.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.primarySolid.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: state is CreateMeetingLoading ? null : _saveSchedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state is CreateMeetingLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Schedule',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Cancel button
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required IconData icon,
    bool required = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: time != null
              ? LinearGradient(
                  colors: ColorManager.primary.colors
                      .map((c) => c.withOpacity(0.1))
                      .toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: time == null ? Colors.grey[50] : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: time != null
                ? ColorManager.primary.colors.first.withOpacity(0.3)
                : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: time != null
                      ? ColorManager.primarySolid
                      : Colors.grey[400],
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: time != null ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                if (required)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time?.format(context) ?? 'Select',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: time != null
                    ? ColorManager.primarySolid
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
