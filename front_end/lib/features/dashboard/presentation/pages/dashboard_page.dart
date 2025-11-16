import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_event.dart';
import 'package:front_end/features/dashboard/presentation/widget/meeting_today_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboardEvent());
      },
      child: Scaffold(
        backgroundColor: ColorManager.background,
        body: Column(
          children: [
            ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                decoration: BoxDecoration(gradient: ColorManager.primary),
                height: 350,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 8,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final imageHeight = constraints.maxHeight; 
                          final imageWidth = constraints.maxWidth;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Image.asset(
                              'assets/images/male.webp',
                              alignment: Alignment.bottomCenter,
                              height: imageHeight,
                              width: imageWidth,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 60,
                              ),
                              child: MeetingTodayWidget()
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 50),
                    //   child: Image.asset(
                    //     'assets/images/male.webp',
                    //     width: 250,
                    //     height: 250,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    for (int i = 0; i < 10; i++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double h = size.height;
    double w = size.width;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, h - 100);
    path.quadraticBezierTo(0, h - 50, 50, h - 50);
    path.lineTo(50, h - 50);
    path.lineTo(w - 50, h - 50);
    path.quadraticBezierTo(w, h - 50, w, h);
    path.lineTo(w, h);
    path.lineTo(w, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
