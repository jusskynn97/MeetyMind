import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/calendar/presentation/pages/calendar_page.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_event.dart';
import 'package:front_end/features/dashboard/presentation/pages/dashboard_page.dart';

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

  // 👉 Không đổi gì, chỉ chuyển qua IndexedStack ở phần build()
  late final List<Widget> _screens = [
    const DashboardPage(),
    const CalendarPage(),
    const ScreenContent(title: 'Voice', icon: Icons.mic),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice feature coming soon!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,

      // 🔥🔥🔥 CHỈ SỬA DUY NHẤT PHẦN NÀY 🔥🔥🔥
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // END

      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(color: ColorManager.background),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard_rounded, 0),
            _buildNavItem(Icons.calendar_month_sharp, 1),
            const SizedBox(width: 4),
            _buildCenterButton(),
            const SizedBox(width: 4),
            _buildNavItem(Icons.notifications_rounded, 3),
            _buildNavItem(Icons.person_rounded, 4),
          ],
        ),
      ),
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

  Widget _buildCenterButton() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: GestureDetector(
        onTap: _onCenterTapped,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: ColorManager.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColorManager.primarySolid.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: _selectedIndex == 2 ? 3 : 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 30),
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
