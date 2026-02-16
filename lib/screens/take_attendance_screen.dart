import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final Subject subject;
  final List<Student> allStudents;
  final Function(AttendanceRecord) onSave;

  const TakeAttendanceScreen({
    super.key,
    required this.subject,
    required this.allStudents,
    required this.onSave,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  late Map<String, AttendanceStatus> _statuses;
  late List<Student> _subjectStudents;

  @override
  void initState() {
    super.initState();
    _subjectStudents = widget.allStudents
        .where((s) => widget.subject.studentIds.contains(s.id))
        .toList();
    _statuses = {
      for (var s in _subjectStudents) s.id: AttendanceStatus.present
    };
  }

  void _updateStatus(String studentId, AttendanceStatus status) {
    setState(() {
      _statuses[studentId] = status;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var id in _statuses.keys) {
        _statuses[id] = AttendanceStatus.present;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int present = _statuses.values.where((s) => s == AttendanceStatus.present).length;
    int absent = _statuses.values.where((s) => s == AttendanceStatus.absent).length;
    int lateCount = _statuses.values.where((s) => s == AttendanceStatus.late).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf_outlined, size: 20)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, size: 20)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                _summaryCard('PRESENT', present, Colors.green),
                const SizedBox(width: 12),
                _summaryCard('ABSENT', absent, Colors.red),
                const SizedBox(width: 12),
                _summaryCard('LATE', lateCount, Colors.orange),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Students (${_subjectStudents.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: _markAllPresent,
                  child: const Text('Mark All Present', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _subjectStudents.length,
              itemBuilder: (context, index) {
                final student = _subjectStudents[index];
                return _studentAttendanceTile(student);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(AttendanceRecord(date: DateTime.now(), studentStatuses: _statuses));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _studentAttendanceTile(Student student) {
    final status = _statuses[student.id];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(student.rollNumber, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              _statusButton(student.id, AttendanceStatus.present, 'Present', Colors.green),
              const SizedBox(width: 8),
              _statusButton(student.id, AttendanceStatus.absent, 'Absent', Colors.red),
              const SizedBox(width: 8),
              _statusButton(student.id, AttendanceStatus.late, 'Late', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String studentId, AttendanceStatus status, String label, Color color) {
    bool isSelected = _statuses[studentId] == status;
    return Expanded(
      child: InkWell(
        onTap: () => _updateStatus(studentId, status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
