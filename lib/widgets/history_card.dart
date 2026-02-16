import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String subjectName;
  final String date;
  final double percentage;
  final int present;
  final int total;

  const HistoryCard({
    super.key,
    required this.subjectName,
    required this.date,
    required this.percentage,
    required this.present,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subjectName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                date,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$present/$total Present',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
