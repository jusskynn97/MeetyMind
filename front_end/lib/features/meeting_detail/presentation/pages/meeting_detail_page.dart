// features/meeting/presentation/pages/meeting_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/app/di/injection.dart';
import 'package:front_end/app/theme/colors.dart';
import 'package:front_end/features/meeting_detail/presentation/bloc/meeting_detail_bloc.dart';
import 'package:front_end/features/meeting_detail/presentation/widgets/ai_chat_tab.dart';
import 'package:front_end/features/meeting_detail/presentation/widgets/conversation_tab.dart';
import 'package:front_end/features/meeting_detail/presentation/widgets/summary_tab.dart';
import 'package:front_end/features/meeting_detail/presentation/widgets/takeaways_tab.dart';

class MeetingDetailPage extends StatefulWidget {
  final Map<String, dynamic> meeting;

  const MeetingDetailPage({super.key, required this.meeting});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper để lấy dữ liệu an toàn
  String _get(String key, [String fallback = '']) {
    return widget.meeting[key]?.toString() ?? fallback;
  }

  DateTime? _getDateTime(String key) {
    final value = widget.meeting[key];
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<dynamic> _getList(String key) {
    final value = widget.meeting[key];
    return value is List ? value : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorManager.textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _get('title', 'Meeting Details'),
          style: const TextStyle(
            color: ColorManager.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add_outlined,
              color: ColorManager.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: ColorManager.background,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                color: ColorManager.floatingPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: ColorManager.primarySolid,
              unselectedLabelColor: ColorManager.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              dividerColor: Colors.transparent,
              tabs: [
                _buildTab('Summary'),
                _buildTab('Conversation'),
                _buildTab('AI Chat'),
                _buildTab('Takeaways'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SummaryTab(meeting: widget.meeting),
          BlocProvider<TranscriptBloc>(
            create: (context) => sl<TranscriptBloc>(),
            child: ConversationTab(
              meetingId: widget.meeting['meetingId'],
              isOwner: widget.meeting['isOwner'],
            ),
          ),
          AIChatTab(meeting: widget.meeting),
          TakeawaysTab(meeting: widget.meeting),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(text),
    );
  }
}
