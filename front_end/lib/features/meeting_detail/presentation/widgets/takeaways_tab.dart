import 'package:flutter/material.dart';
import 'package:front_end/app/theme/colors.dart';

class TakeawaysTab extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const TakeawaysTab({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final takeaways = List<Map<String, dynamic>>.from(meeting['takeaways'] ?? []);

    if (takeaways.isEmpty) {
      return Center(child: Text('No takeaways available yet.', style: TextStyle(color: ColorManager.textSecondary)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: takeaways.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = takeaways[index];
        return _buildTakeawayItem(
          title: item['title'] ?? 'Key Point ${index + 1}',
          description: item['description'] ?? item['content'] ?? '',
        );
      },
    );
  }

  Widget _buildTakeawayItem({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: ColorManager.card, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(color: ColorManager.primarySolid, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ColorManager.textPrimary)),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 15, height: 1.4, color: ColorManager.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}