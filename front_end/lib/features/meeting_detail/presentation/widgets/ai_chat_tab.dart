import 'package:flutter/material.dart';
import 'package:front_end/app/theme/colors.dart';

class AIChatTab extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const AIChatTab({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final suggested = List<String>.from(meeting['suggestedQuestions'] ?? meeting['aiSuggestions'] ?? [
      'What were the main topics discussed?',
      'Who is responsible for the next actions?',
      'What decisions were made?',
    ]);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 40),
              Text('Ask questions about this conversation', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ColorManager.textPrimary)),
              const SizedBox(height: 8),
              Text('Get answers from Otter AI Chat or your team', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: ColorManager.textSecondary)),
              const SizedBox(height: 32),
              ...suggested.map((q) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildSuggestedQuestion(q))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: ColorManager.background,
            border: Border(top: BorderSide(color: ColorManager.border, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(24)),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Message people or @otter',
                        hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(20)),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF8E8E93), size: 24),
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedQuestion(String question) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: ColorManager.card, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.auto_awesome, color: ColorManager.primarySolid, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(question, style: TextStyle(fontSize: 15, height: 1.4, color: ColorManager.textPrimary)),
          ),
        ],
      ),
    );
  }
}