// features/recording/presentation/pages/recording_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_event.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_state.dart';
import 'package:front_end/features/recording/presentation/widgets/recording_bottom_sheet.dart';

class RecordingPage extends StatelessWidget {
  const RecordingPage({super.key});

  void _showRecordingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<RecordingBloc>(),
        child: const RecordingBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecordingBloc, RecordingState>(
      listener: (context, state) {
        // Có thể thêm các listener khác nếu cần
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 120,
              color: const Color(0xFF5DBEA3).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Voice Recording',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<RecordingBloc, RecordingState>(
              builder: (context, state) {
                return ElevatedButton.icon(
                  onPressed: () {
                    if (!state.isRecording) {
                      context.read<RecordingBloc>().add(StartRecordingEvent());
                    }
                    _showRecordingSheet(context);
                  },
                  icon: Icon(
                    state.isRecording ? Icons.graphic_eq_rounded : Icons.mic,
                  ),
                  label: Text(
                    state.isRecording ? 'Đang ghi âm...' : 'Bắt đầu ghi âm',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor:
                        state.isRecording ? Colors.red : const Color(0xFF5DBEA3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}