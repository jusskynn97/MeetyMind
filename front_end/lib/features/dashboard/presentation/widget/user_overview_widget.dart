import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import 'package:front_end/features/dashboard/presentation/blocs/dashboard_state.dart';

class UserOverviewWidget extends StatelessWidget {
  const UserOverviewWidget({super.key});

  Widget _buildInfoCard({
    required IconData icon,
    required String count,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        // Lấy firstName an toàn
        final firstName = state is DashboardLoaded ? state.user.firstName : 'User';

        final card1 = _buildInfoCard(
          icon: Icons.check_circle_rounded,
          count: '19',
          label: 'meeting completed',
          backgroundColor: ColorManager.floatingPrimary.withOpacity(1),
          textColor: ColorManager.secondarySolid,
        );

        final card2 = _buildInfoCard(
          icon: Icons.pending_rounded,
          count: '3',
          label: 'meetings pending',
          backgroundColor: ColorManager.floatingPrimary.withOpacity(0.9),
          textColor: ColorManager.secondarySolid,
        );

        final card3 = _buildInfoCard(
          icon: Icons.access_time_filled_rounded,
          count: '22',
          label: 'Meeting today',
          backgroundColor: ColorManager.floatingPrimary.withOpacity(0.9),
          textColor: ColorManager.secondarySolid,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // CHỈ SỬA DÒNG NÀY
            Text(
              'Hi $firstName 👋 ',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            Text(
              'Your day looks like this:',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 8),

            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  card1,
                  const SizedBox(height: 8),
                  card2,
                  const SizedBox(height: 8),
                  card3,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}