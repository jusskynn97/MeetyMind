// features/main_navigation/presentation/pages/main_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/calendar/presentation/pages/calendar_page.dart';
import 'package:front_end/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_bloc.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_event.dart';
import 'package:front_end/features/recording/presentation/bloc/recording_state.dart';
import 'package:front_end/features/recording/presentation/pages/recording_page.dart';
import 'package:front_end/features/recording/presentation/widgets/recording_bottom_sheet.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  late final List<Widget> _screens = [
    const DashboardPage(),
    const CalendarPage(),
    const RecordingPage(),
    const ScreenContent(title: 'Notifications', icon: Icons.notifications_rounded),
    const ScreenContent(title: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });
  }

  void _onCenterTapped() {
    _fabController.forward().then((_) => _fabController.reverse());

    final recordingBloc = context.read<RecordingBloc>();
    
    if (recordingBloc.state.isRecording) {
      // Nếu đang ghi, mở lại popup
      _showRecordingSheet();
    } else {
      // Nếu chưa ghi, bắt đầu ghi và mở popup
      recordingBloc.add(StartRecordingEvent());
      _showRecordingSheet();
    }
  }

  void _showRecordingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<RecordingBloc>(),
        child: const RecordingBottomSheet(),
      ),
    ).whenComplete(() {
      // force rebuild để MiniBar hiện lên
      if (mounted) setState(() {});
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, recordingState) {
        return Scaffold(
          backgroundColor: ColorManager.background,
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
              
              // Mini recording bar khi đang ghi và không mở popup
              if (recordingState.isRecording)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 70,
                  child: GestureDetector(
                    onTap: _showRecordingSheet,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[400]!, Colors.red[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Pulsing record icon
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (value * 0.2),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                            onEnd: () {
                              if (mounted && recordingState.isRecording) {
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Đang ghi âm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(recordingState.recordingSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 70,
            decoration: const BoxDecoration(color: ColorManager.background),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_rounded, 0),
                _buildNavItem(Icons.calendar_month_sharp, 1),
                const SizedBox(width: 4),
                _buildCenterButton(recordingState),
                const SizedBox(width: 4),
                _buildNavItem(Icons.notifications_rounded, 3),
                _buildNavItem(Icons.person_rounded, 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimations[index].value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isSelected ? 8 : 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: ColorManager.primary.colors.map((c) => c.withOpacity(0.1)).toList(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return isSelected
                        ? LinearGradient(
                            colors: ColorManager.primary.colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds)
                        : const LinearGradient(
                            colors: [Colors.grey, Colors.grey],
                          ).createShader(bounds);
                  },
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          );  
        },
      ),
    );
  }

  Widget _buildCenterButton(RecordingState recordingState) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: GestureDetector(
        onTap: _onCenterTapped,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: recordingState.isRecording ? null : ColorManager.primary,
            color: recordingState.isRecording ? Colors.red : null,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (recordingState.isRecording ? Colors.red : ColorManager.primarySolid).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: recordingState.isRecording ? 3 : 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            recordingState.isRecording ? Icons.graphic_eq_rounded : Icons.mic,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class ScreenContent extends StatelessWidget {
  final String title;
  final IconData icon;

  const ScreenContent({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: const Color(0xFF5DBEA3).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}