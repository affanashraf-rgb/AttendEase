import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../widgets/sidebar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'student_management_screen.dart';
import 'history_screen.dart';
import 'take_attendance_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Student> _allStudents = initialStudents;
  final List<Subject> _subjects = initialSubjects;

  void _addSubject(String name) {
    setState(() {
      _subjects.add(Subject(id: DateTime.now().toString(), name: name));
    });
  }

  void _editSubject(Subject subject) {
    final controller = TextEditingController(text: subject.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: controller, decoration: const InputDecoration(hintText: 'Subject Name')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  final index = _subjects.indexWhere((s) => s.id == subject.id);
                  _subjects[index] = Subject(
                    id: subject.id,
                    name: controller.text,
                    studentIds: subject.studentIds,
                    attendanceRecords: subject.attendanceRecords,
                  );
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            child: const Text('Update'),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}? This will remove all student enrollments for this subject.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _subjects.removeWhere((s) => s.id == subject.id);
                // Also update students' enrolledSubjectIds
                for (int i = 0; i < _allStudents.length; i++) {
                  List<String> updatedEnrolled = List.from(_allStudents[i].enrolledSubjectIds)..remove(subject.id);
                  _allStudents[i] = Student(
                    id: _allStudents[i].id,
                    name: _allStudents[i].name,
                    rollNumber: _allStudents[i].rollNumber,
                    enrolledSubjectIds: updatedEnrolled,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addStudent(String name, String roll) {
    setState(() {
      _allStudents.add(Student(id: DateTime.now().toString(), name: name, rollNumber: roll));
    });
  }

  void _editStudent(Student student) {
    final name = TextEditingController(text: student.name);
    final roll = TextEditingController(text: student.rollNumber);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: name, decoration: const InputDecoration(hintText: 'Name')),
          const SizedBox(height: 12),
          TextField(controller: roll, decoration: const InputDecoration(hintText: 'Roll Number')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (name.text.isNotEmpty) {
                setState(() {
                  final index = _allStudents.indexWhere((s) => s.id == student.id);
                  _allStudents[index] = Student(
                    id: student.id,
                    name: name.text,
                    rollNumber: roll.text,
                    enrolledSubjectIds: student.enrolledSubjectIds,
                  );
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            child: const Text('Update'),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _deleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _allStudents.removeWhere((s) => s.id == student.id);
                for (int i = 0; i < _subjects.length; i++) {
                  List<String> updatedIds = List.from(_subjects[i].studentIds)..remove(student.id);
                  _subjects[i] = Subject(
                    id: _subjects[i].id,
                    name: _subjects[i].name,
                    studentIds: updatedIds,
                    attendanceRecords: _subjects[i].attendanceRecords,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _enrollStudent(Student student) {
    List<String> tempSelectedSubjectIds = List.from(student.enrolledSubjectIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enroll ${student.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Select subjects to enroll this student in:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ..._subjects.map((subject) {
                bool isEnrolled = tempSelectedSubjectIds.contains(subject.id);
                return CheckboxListTile(
                  title: Text(subject.name),
                  value: isEnrolled,
                  activeColor: const Color(0xFF7C3AED),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        tempSelectedSubjectIds.add(subject.id);
                      } else {
                        tempSelectedSubjectIds.remove(subject.id);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final studentIndex = _allStudents.indexWhere((s) => s.id == student.id);
                      _allStudents[studentIndex] = Student(
                        id: student.id,
                        name: student.name,
                        rollNumber: student.rollNumber,
                        enrolledSubjectIds: tempSelectedSubjectIds,
                      );

                      for (int i = 0; i < _subjects.length; i++) {
                        bool shouldBeEnrolled = tempSelectedSubjectIds.contains(_subjects[i].id);
                        List<String> updatedStudentIds = List.from(_subjects[i].studentIds);
                        
                        if (shouldBeEnrolled && !updatedStudentIds.contains(student.id)) {
                          updatedStudentIds.add(student.id);
                        } else if (!shouldBeEnrolled && updatedStudentIds.contains(student.id)) {
                          updatedStudentIds.remove(student.id);
                        }

                        _subjects[i] = Subject(
                          id: _subjects[i].id,
                          name: _subjects[i].name,
                          studentIds: updatedStudentIds,
                          attendanceRecords: _subjects[i].attendanceRecords,
                        );
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Enrollment', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAttendance(Subject subject, AttendanceRecord record) {
    setState(() {
      final index = _subjects.indexWhere((s) => s.id == subject.id);
      if (index != -1) {
        List<AttendanceRecord> updatedRecords = List.from(_subjects[index].attendanceRecords)..add(record);
        _subjects[index] = Subject(
          id: _subjects[index].id,
          name: _subjects[index].name,
          studentIds: _subjects[index].studentIds,
          attendanceRecords: updatedRecords,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final bool useMobileLayout = !isWideScreen;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: useMobileLayout 
        ? AppBar(
            title: const Text('AttendEase', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED), fontSize: 20)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          )
        : null,
      body: Row(
        children: [
          if (!useMobileLayout) 
            Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          Expanded(
            child: SafeArea(
              child: _buildCurrentScreen(isWideScreen),
            ),
          ),
        ],
      ),
      bottomNavigationBar: useMobileLayout 
        ? BottomNavBar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          )
        : null,
      floatingActionButton: (useMobileLayout && _selectedIndex != 2)
          ? FloatingActionButton(
              onPressed: () => _selectedIndex == 0 ? _showAddSubjectDialog() : _showAddStudentDialog(),
              backgroundColor: const Color(0xFF7C3AED),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCurrentScreen(bool isWide) {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          isWide: isWide,
          allStudents: _allStudents,
          subjects: _subjects,
          onAddSubject: _showAddSubjectDialog,
          onMarkAttendance: (subject) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakeAttendanceScreen(
                  subject: subject,
                  allStudents: _allStudents,
                  onSave: (record) => _saveAttendance(subject, record),
                ),
              ),
            );
          },
          onEditSubject: _editSubject,
          onDeleteSubject: _deleteSubject,
        );
      case 1:
        return StudentManagementScreen(
          isWide: isWide,
          allStudents: _allStudents,
          onEdit: _editStudent,
          onDelete: _deleteStudent,
          onEnroll: _enrollStudent,
        );
      case 2:
        return HistoryScreen(isWide: isWide);
      default:
        return Container();
    }
  }

  void _showAddSubjectDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: controller, decoration: const InputDecoration(hintText: 'e.g. Algorithms')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () { if (controller.text.isNotEmpty) _addSubject(controller.text); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            child: const Text('Add'),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _showAddStudentDialog() {
    final name = TextEditingController();
    final roll = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: name, decoration: const InputDecoration(hintText: 'Name')),
          const SizedBox(height: 12),
          TextField(controller: roll, decoration: const InputDecoration(hintText: 'Roll Number')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () { if (name.text.isNotEmpty) _addStudent(name.text, roll.text); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            child: const Text('Add'),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
