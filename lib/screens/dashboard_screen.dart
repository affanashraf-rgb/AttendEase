import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/stat_card.dart';
import '../widgets/subject_card.dart';

class DashboardScreen extends StatelessWidget {
  final bool isWide;
  final List<Student> allStudents;
  final List<Subject> subjects;
  final VoidCallback onAddSubject;
  final Function(Subject) onMarkAttendance;
  final Function(Subject) onEditSubject;
  final Function(Subject) onDeleteSubject;
  final Function(Subject) onEnrollStudents;

  const DashboardScreen({
    super.key,
    required this.isWide,
    required this.allStudents,
    required this.subjects,
    required this.onAddSubject,
    required this.onMarkAttendance,
    required this.onEditSubject,
    required this.onDeleteSubject,
    required this.onEnrollStudents,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 40.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Professor',
                      style: TextStyle(
                        fontSize: isWide ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const Text(
                      'Manage your subjects and track attendance.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isWide)
                ElevatedButton.icon(
                  onPressed: onAddSubject,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          _buildStatsGrid(context),
          const SizedBox(height: 48),
          const Text(
            'Your Subjects',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 24),
          _buildSubjectsGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    // Calculate Overall Attendance
    int totalPossibleAttendance = 0;
    int totalActualAttendance = 0;

    for (var subject in subjects) {
      if (subject.studentIds.isNotEmpty) {
        totalPossibleAttendance += subject.attendanceRecords.length * subject.studentIds.length;
        for (var record in subject.attendanceRecords) {
          totalActualAttendance += record.presentCount + record.lateCount;
        }
      }
    }

    double overallPercentage = totalPossibleAttendance == 0 
        ? 0.0 
        : (totalActualAttendance / totalPossibleAttendance) * 100;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isWide ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isWide ? 2.5 : 2.0,
          children: [
            StatCard(
              title: 'Total Students',
              value: '${allStudents.length}',
              trend: 'Across all classes',
              icon: Icons.group,
              isPrimary: true,
            ),
            StatCard(
              title: 'Active Subjects',
              value: '${subjects.length}',
              trend: 'Currently teaching',
              icon: Icons.book_outlined,
            ),
            StatCard(
              title: 'Overall Attendance',
              value: '${overallPercentage.toStringAsFixed(1)}%',
              trend: 'Average rate',
              icon: Icons.pie_chart_outline,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubjectsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isWide ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isWide ? 2.2 : 1.8,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) => SubjectCard(
            subject: subjects[index],
            isWide: isWide,
            onMarkAttendance: () => onMarkAttendance(subjects[index]),
            onEdit: () => onEditSubject(subjects[index]),
            onDelete: () => onDeleteSubject(subjects[index]),
            onEnroll: () => onEnrollStudents(subjects[index]),
          ),
        );
      },
    );
  }
}
