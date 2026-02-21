import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends StatelessWidget {
  final bool isWide;
  final List<Subject> subjects;
  final Function(Subject, AttendanceRecord) onEditRecord;

  const HistoryScreen({
    super.key,
    required this.isWide,
    required this.subjects,
    required this.onEditRecord,
  });

  @override
  Widget build(BuildContext context) {
    // Flatten all attendance records from all subjects into a single list
    List<Map<String, dynamic>> allHistory = [];
    for (var subject in subjects) {
      for (var record in subject.attendanceRecords) {
        allHistory.add({
          'subject': subject,
          'record': record,
          'subjectName': subject.name,
          'date': record.date,
          'present': record.presentCount,
          'lateCount': record.lateCount,
          'total': subject.studentIds.length,
          'percentage': subject.studentIds.isEmpty 
              ? 0.0 
              : (record.presentCount + record.lateCount) / subject.studentIds.length,
        });
      }
    }

    // Sort by date (newest first)
    allHistory.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

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
            'View logs of previous sessions. Tap to edit.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (allHistory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No attendance records found.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = allHistory[index];
                return HistoryCard(
                  subjectName: item['subjectName'],
                  date: DateFormat('MMM d, yyyy • hh:mm a').format(item['date']),
                  percentage: item['percentage'],
                  present: item['present'],
                  lateCount: item['lateCount'],
                  total: item['total'],
                  onTap: () => onEditRecord(item['subject'], item['record']),
                );
              },
            ),
        ],
      ),
    );
  }
}
