import 'package:flutter/material.dart';

class CalendarMenuWidget extends StatelessWidget {
  final Map<String, dynamic> meeting;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CalendarMenuWidget({
    super.key,
    required this.meeting,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModernOption(
            icon: Icons.visibility_outlined,
            label: 'View Details',
            onTap: onViewDetails,
          ),
          if (meeting['isOwner']) ...[
            _buildDivider(),
            _buildModernOption(
              icon: Icons.edit_outlined,
              label: 'Edit',
              onTap: onEdit,
            ),
            _buildDivider(),
            _buildModernOption(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: Colors.red.shade400,
              onTap: onDelete,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? Colors.grey.shade800;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: optionColor, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: optionColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}
