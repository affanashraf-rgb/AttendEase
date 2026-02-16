import 'package:flutter/material.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends StatelessWidget {
  final bool isWide;

  const HistoryScreen({
    super.key,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 40.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const Text(
            'View logs of previous sessions.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => const HistoryCard(
              subjectName: 'Calculus',
              date: 'Oct 25, 2023',
              percentage: 0.93,
              present: 42,
              total: 45,
            ),
          ),
        ],
      ),
    );
  }
}
