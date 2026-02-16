import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/student_card.dart';

class StudentManagementScreen extends StatelessWidget {
  final bool isWide;
  final List<Student> allStudents;
  final Function(Student) onEdit;
  final Function(Student) onDelete;
  final Function(Student) onEnroll;

  const StudentManagementScreen({
    super.key,
    required this.isWide,
    required this.allStudents,
    required this.onEdit,
    required this.onDelete,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 40.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const Text(
            'Add and manage your student database.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildSearchAndFilter(),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allStudents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => StudentCard(
              student: allStudents[index],
              isWide: isWide,
              onEdit: () => onEdit(allStudents[index]),
              onDelete: () => onDelete(allStudents[index]),
              onEnroll: () => onEnroll(allStudents[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search students...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey, size: 20),
        ),
      ),
    );
  }
}
