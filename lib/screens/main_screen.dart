import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/database_helper.dart';
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
  List<Student> _allStudents = [];
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final students = await DatabaseHelper.instance.getAllStudents();
    final subjects = await DatabaseHelper.instance.getAllSubjects();
    setState(() {
      _allStudents = students;
      _subjects = subjects;
      _isLoading = false;
    });
  }

  Future<void> _addSubject(String name) async {
    final subject = Subject(id: DateTime.now().toString(), name: name);
    await DatabaseHelper.instance.insertSubject(subject);
    _refreshData();
  }

  Future<void> _editSubject(Subject subject) async {
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
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final updated = Subject(
                  id: subject.id,
                  name: controller.text,
                  studentIds: subject.studentIds,
                  attendanceRecords: subject.attendanceRecords,
                );
                await DatabaseHelper.instance.updateSubject(updated);
                _refreshData();
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

  Future<void> _deleteSubject(Subject subject) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}? This will remove all student enrollments for this subject.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteSubject(subject.id);
              for (var student in _allStudents) {
                if (student.enrolledSubjectIds.contains(subject.id)) {
                  List<String> updated = List.from(student.enrolledSubjectIds)..remove(subject.id);
                  await DatabaseHelper.instance.updateStudent(Student(
                    id: student.id,
                    name: student.name,
                    rollNumber: student.rollNumber,
                    enrolledSubjectIds: updated,
                  ));
                }
              }
              _refreshData();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _addStudent(String name, String roll) async {
    final student = Student(id: DateTime.now().toString(), name: name, rollNumber: roll);
    await DatabaseHelper.instance.insertStudent(student);
    _refreshData();
  }

  Future<void> _editStudent(Student student) async {
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
            onPressed: () async {
              if (name.text.isNotEmpty) {
                final updated = Student(
                  id: student.id,
                  name: name.text,
                  rollNumber: roll.text,
                  enrolledSubjectIds: student.enrolledSubjectIds,
                );
                await DatabaseHelper.instance.updateStudent(updated);
                _refreshData();
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

  Future<void> _deleteStudent(Student student) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteStudent(student.id);
              for (var subject in _subjects) {
                if (subject.studentIds.contains(student.id)) {
                  List<String> updated = List.from(subject.studentIds)..remove(student.id);
                  await DatabaseHelper.instance.updateSubject(Subject(
                    id: subject.id,
                    name: subject.name,
                    studentIds: updated,
                    attendanceRecords: subject.attendanceRecords,
                  ));
                }
              }
              _refreshData();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _enrollStudent(Student student) async {
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
                  onPressed: () async {
                    await DatabaseHelper.instance.updateStudent(Student(
                      id: student.id,
                      name: student.name,
                      rollNumber: student.rollNumber,
                      enrolledSubjectIds: tempSelectedSubjectIds,
                    ));

                    for (var subject in _subjects) {
                      bool shouldBeEnrolled = tempSelectedSubjectIds.contains(subject.id);
                      List<String> updatedStudentIds = List.from(subject.studentIds);
                      
                      if (shouldBeEnrolled && !updatedStudentIds.contains(student.id)) {
                        updatedStudentIds.add(student.id);
                      } else if (!shouldBeEnrolled && updatedStudentIds.contains(student.id)) {
                        updatedStudentIds.remove(student.id);
                      }

                      await DatabaseHelper.instance.updateSubject(Subject(
                        id: subject.id,
                        name: subject.name,
                        studentIds: updatedStudentIds,
                        attendanceRecords: subject.attendanceRecords,
                      ));
                    }
                    _refreshData();
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

  Future<void> _enrollStudentsInSubject(Subject subject) async {
    List<String> tempSelectedStudentIds = List.from(subject.studentIds);

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
              Text('Enroll Students in ${subject.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Select students to enroll in this subject:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allStudents.length,
                  itemBuilder: (context, index) {
                    final student = _allStudents[index];
                    bool isSelected = tempSelectedStudentIds.contains(student.id);
                    return CheckboxListTile(
                      title: Text(student.name),
                      subtitle: Text(student.rollNumber),
                      value: isSelected,
                      activeColor: const Color(0xFF7C3AED),
                      onChanged: (bool? value) {
                        setModalState(() {
                          if (value == true) {
                            tempSelectedStudentIds.add(student.id);
                          } else {
                            tempSelectedStudentIds.remove(student.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Update Subject
                    await DatabaseHelper.instance.updateSubject(Subject(
                      id: subject.id,
                      name: subject.name,
                      studentIds: tempSelectedStudentIds,
                      attendanceRecords: subject.attendanceRecords,
                    ));

                    // Update Students
                    for (var student in _allStudents) {
                      bool shouldBeEnrolled = tempSelectedStudentIds.contains(student.id);
                      List<String> updatedEnrolledSubjectIds = List.from(student.enrolledSubjectIds);
                      
                      if (shouldBeEnrolled && !updatedEnrolledSubjectIds.contains(subject.id)) {
                        updatedEnrolledSubjectIds.add(subject.id);
                      } else if (!shouldBeEnrolled && updatedEnrolledSubjectIds.contains(subject.id)) {
                        updatedEnrolledSubjectIds.remove(subject.id);
                      }

                      await DatabaseHelper.instance.updateStudent(Student(
                        id: student.id,
                        name: student.name,
                        rollNumber: student.rollNumber,
                        enrolledSubjectIds: updatedEnrolledSubjectIds,
                      ));
                    }
                    _refreshData();
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

  Future<void> _saveAttendance(Subject subject, AttendanceRecord record) async {
    if (record.id != null) {
      await DatabaseHelper.instance.updateAttendanceRecord(record);
    } else {
      await DatabaseHelper.instance.insertAttendanceRecord(subject.id, record);
    }
    _refreshData();
  }

  void _editAttendanceRecord(Subject subject, AttendanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakeAttendanceScreen(
          subject: subject,
          allStudents: _allStudents,
          existingRecord: record,
          onSave: (updatedRecord) => _saveAttendance(subject, updatedRecord),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final bool useMobileLayout = !isWideScreen;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          onEnrollStudents: _enrollStudentsInSubject,
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
        return HistoryScreen(
          isWide: isWide, 
          subjects: _subjects,
          onEditRecord: _editAttendanceRecord,
        );
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
