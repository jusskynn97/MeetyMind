// lib/features/meeting/presentation/widgets/conversation_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:front_end/features/meeting_detail/presentation/bloc/meeting_detail_bloc.dart';
import 'package:front_end/features/meeting_detail/presentation/bloc/meeting_detail_event.dart';
import 'package:front_end/features/meeting_detail/presentation/bloc/meeting_detail_state.dart';
import 'dart:io';
import '../../domain/entities/transcript.dart';

class ConversationTab extends StatefulWidget {
  final String meetingId;
  final bool isOwner;

  const ConversationTab({
    super.key,
    required this.meetingId,
    required this.isOwner,
  });

  @override
  State<ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends State<ConversationTab>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _currentTime = 0.0;
  double _totalDuration = 0.0;
  bool _isPlaying = false;
  Transcript? _currentTranscript;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();

    // Load transcript khi vào tab
    context.read<TranscriptBloc>().add(GetTranscriptEvent(widget.meetingId));
  }

  void _initializeAudioPlayer() {
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentTime = position.inMilliseconds / 1000.0;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration.inMilliseconds / 1000.0;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentTime = 0.0;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'ogg'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        if (mounted) {
          context.read<TranscriptBloc>().add(
            UploadAudioFileEvent(meetingId: widget.meetingId, audioFile: file),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playPauseAudio() async {
    if (_currentTranscript?.audioPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentTime == 0.0) {
        await _audioPlayer.play(UrlSource(_currentTranscript!.audioPath!));
        print('Playing audio from URL: ${_currentTranscript!.audioPath!}');
      } else {
        await _audioPlayer.resume();
      }
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> _seekTo(double seconds) async {
    await _audioPlayer.seek(Duration(milliseconds: (seconds * 1000).toInt()));
    setState(() {
      _currentTime = seconds;
    });
  }

  String _formatTime(double seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String _getSpeakerName(String speaker) {
    return speaker.replaceAll('SPEAKER_', 'Speaker ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TranscriptBloc, TranscriptState>(
      listener: (context, state) {
        if (state is TranscriptError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is TranscriptLoading) {
          return _buildLoadingState();
        }

        if (state is TranscriptUploading) {
          return _buildUploadingState(state.message);
        }

        if (state is TranscriptProcessing) {
          return _buildProcessingState(state.status, state.message);
        }

        if (state is TranscriptLoaded) {
          _currentTranscript = state.transcript;

          if (state.transcript.segments == null ||
              state.transcript.segments!.isEmpty) {
            return widget.isOwner
                ? _buildEmptyStateForOwner()
                : _buildEmptyStateForNonOwner();
          }

          return _buildTranscriptView(state.transcript);
        }

        // Initial or error state
        return widget.isOwner
            ? _buildEmptyStateForOwner()
            : _buildEmptyStateForNonOwner();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildUploadingState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingState(TranscriptionStatus status, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(status),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDescription(TranscriptionStatus status) {
    switch (status) {
      case TranscriptionStatus.queued:
        return 'Your audio is in the queue';
      case TranscriptionStatus.processing:
        return 'AI is transcribing your audio';
      case TranscriptionStatus.uploading:
        return 'Uploading to cloud storage';
      default:
        return '';
    }
  }

  Widget _buildTranscriptView(Transcript transcript) {
    final segments = transcript.segments!;

    return Column(
      children: [
        // Audio Player Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                iconSize: 32,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _playPauseAudio,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(_currentTime),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: _currentTime.clamp(0.0, _totalDuration),
                    min: 0.0,
                    max: _totalDuration > 0 ? _totalDuration : 1.0,
                    onChanged: _seekTo,
                  ),
                ),
              ),
              Text(
                _formatTime(_totalDuration),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Transcript Segments
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: segments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final segment = segments[index];
              final isActive =
                  _currentTime >= segment.start && _currentTime <= segment.end;

              return _buildTranscriptSegment(
                speaker: _getSpeakerName(segment.speaker),
                segment: segment,
                isActive: isActive,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptSegment({
    required String speaker,
    required TranscriptSegment segment,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _seekTo(segment.start),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.3),
                  child: Text(
                    speaker[0],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    speaker,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatTime(segment.start),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: segment.words.map((word) {
                final isWordActive =
                    isActive &&
                    _currentTime >= word.start &&
                    _currentTime <= word.end;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: isWordActive
                      ? BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        )
                      : null,
                  child: Text(
                    word.word,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isWordActive
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                      fontWeight: isWordActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateForOwner() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Not yet recorded or uploaded',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload audio file for transcript of this meeting',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleUploadFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload audio file'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateForNonOwner() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_off_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Not yet recorded or uploaded',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Owner of this meeting\nnot yet uploaded any audio recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
