// features/recording/presentation/pages/recording_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_event.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_state.dart';
import 'package:front_end/features/recording/presentation/widgets/recording_bottom_sheet.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  String? _selectedMeeting; // ID hoặc tên cuộc họp được chọn

  // Giả sử danh sách cuộc họp (bạn có thể fetch từ API hoặc Bloc)
  final List<String> _meetings = [
    'Cuộc họp tuần 1 - Dự án A',
    'Cuộc họp tháng 1 - Team B',
    'Cuộc họp khẩn - Khách hàng C',
    'Cuộc họp nội bộ - Q4',
  ];

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

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio, // Chỉ cho phép chọn file audio
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      // TODO: Xử lý file đã chọn (ví dụ: upload, transcribe, lưu vào Bloc...)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chọn file: ${result.files.single.name}')),
      );
      // Bạn có thể dispatch event vào Bloc nếu cần
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có file nào được chọn')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic,
                size: 120,
                color: Color(0xFF5DBEA3).withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Xử lý biên bản họp',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Phần chọn cuộc họp
              DropdownButtonFormField<String>(
                value: _selectedMeeting,
                hint: const Text('Chọn cuộc họp'),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _meetings.map((meeting) {
                  return DropdownMenuItem<String>(
                    value: meeting,
                    child: Text(meeting),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMeeting = value;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Chỉ hiển thị lựa chọn khi đã chọn cuộc họp
              if (_selectedMeeting != null) ...[
                const Text(
                  'Chọn cách nhập âm thanh cho cuộc họp:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nút Import file
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickAudioFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Import file audio'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Nút Ghi âm trực tiếp
                    Expanded(
                      child: BlocBuilder<RecordingBloc, RecordingState>(
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
                              state.isRecording ? 'Đang ghi âm...' : 'Ghi âm trực tiếp',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: state.isRecording
                                  ? Colors.red
                                  : const Color(0xFF5DBEA3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ] else
                const Text(
                  'Vui lòng chọn cuộc họp trước',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}