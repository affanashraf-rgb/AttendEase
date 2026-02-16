import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'models.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AttendEase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          primary: const Color(0xFF7C3AED),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Student> _allStudents = [
    Student(id: '1', name: 'Affan Ahmed', rollNumber: 'CS-001', enrolledSubjectIds: ['1', '2']),
    Student(id: '2', name: 'Bisma Khan', rollNumber: 'CS-002', enrolledSubjectIds: ['1', '3']),
    Student(id: '3', name: 'Daniyal Shah', rollNumber: 'CS-003', enrolledSubjectIds: ['2', '4']),
  ];
  final List<Subject> _subjects = [
    Subject(id: '1', name: 'Calculus', studentIds: List.generate(45, (i) => '$i')),
    Subject(id: '2', name: 'Data Structures', studentIds: List.generate(38, (i) => '$i')),
    Subject(id: '3', name: 'Assembly', studentIds: List.generate(32, (i) => '$i')),
    Subject(id: '4', name: 'Algorithms', studentIds: List.generate(40, (i) => '$i')),
  ];

  void _addSubject(String name) {
    setState(() {
      _subjects.add(Subject(id: DateTime.now().toString(), name: name));
    });
  }

  void _addStudent(String name, String roll) {
    setState(() {
      _allStudents.add(Student(id: DateTime.now().toString(), name: name, rollNumber: roll));
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
          if (!useMobileLayout) _buildSidebar(),
          Expanded(
            child: SafeArea(
              child: _selectedIndex == 0 
                  ? _buildDashboardContent(isWideScreen) 
                  : (_selectedIndex == 1 ? _buildStudentManagementContent(isWideScreen) : _buildHistoryContent(isWideScreen)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: useMobileLayout 
        ? _buildBottomNavBar()
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

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                SizedBox(width: 12),
                Text('AttendEase', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sidebarItem(Icons.grid_view_rounded, 'Dashboard', 0),
          _sidebarItem(Icons.group_outlined, 'Students', 1),
          _sidebarItem(Icons.history, 'History', 2),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        onTap: () => setState(() => _selectedIndex = index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
        title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.group_rounded), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(bool isWide) {
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
                    Text('Welcome, Professor', style: TextStyle(fontSize: isWide ? 28 : 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    Text('Manage your subjects and track attendance.', style: TextStyle(fontSize: 14, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (isWide) ElevatedButton.icon(
                onPressed: _showAddSubjectDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Subject'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildStatsGrid(isWide),
          const SizedBox(height: 48),
          const Text('Your Subjects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 24),
          _buildSubjectsGrid(isWide),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isWide) {
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
            _statCard('Total Students', '155', '+4', Icons.group, true),
            _statCard('Active Subjects', '4', '0', Icons.book_outlined, false),
            _statCard('Overall Attendance', '88.4%', '+2.1%', Icons.pie_chart_outline, false),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String value, String trend, IconData icon, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF7C3AED) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(icon, color: isPrimary ? Colors.white.withOpacity(0.2) : const Color(0xFF7C3AED).withOpacity(0.1), size: 40),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(color: isPrimary ? Colors.white.withOpacity(0.8) : Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF111827), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(trend, style: TextStyle(color: isPrimary ? Colors.white.withOpacity(0.7) : Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsGrid(bool isWide) {
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
          itemCount: _subjects.length,
          itemBuilder: (context, index) => _subjectCard(_subjects[index], isWide),
        );
      },
    );
  }

  Widget _subjectCard(Subject subject, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(subject.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF111827)), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('${subject.studentIds.length} Students', style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Next: 10:30 AM', style: TextStyle(color: Colors.grey, fontSize: 13)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Mark Attendance', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentManagementContent(bool isWide) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 40.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const Text('Add and manage your student database.', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          _buildSearchAndFilter(isWide),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allStudents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _studentCard(_allStudents[index], isWide),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isWide) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const TextField(
        decoration: InputDecoration(hintText: 'Search students...', border: InputBorder.none, icon: Icon(Icons.search, color: Colors.grey, size: 20)),
      ),
    );
  }

  Widget _studentCard(Student student, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1), radius: 20, child: Text(student.name[0], style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(student.rollNumber, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20)),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(bool isWide) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 40.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const Text('View logs of previous sessions.', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _historyCard(isWide),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Text('93%', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Oct 25, 2023', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const Spacer(),
              const Text('42/45 Present', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(value: 0.93, backgroundColor: Color(0xFFF3F4F6), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)), minHeight: 6),
          ),
        ],
      ),
    );
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
