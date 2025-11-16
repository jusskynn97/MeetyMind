import 'package:flutter/material.dart';
import 'package:front_end/app/theme/colors.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: const Center(
        child: Text('Calendar Page'),
      ),
    );
  }
}