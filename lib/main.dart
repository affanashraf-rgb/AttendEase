import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          if (isWideScreen) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                if (!isWideScreen) _buildMobileAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: _buildCurrentTab(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isWideScreen ? Drawer(child: _buildSidebarContent()) : null,
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildStudentManagementContent();
      case 2:
        return _buildHistoryContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildMobileAppBar() {
    return AppBar(
      title: const Text('AttendEase', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
              SizedBox(width: 12),
              Text(
                'AttendEase',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sidebarItem(Icons.grid_view_rounded, 'Subjects', 0),
        _sidebarItem(Icons.group_outlined, 'Students', 1),
        _sidebarItem(Icons.history, 'History', 2),
      ],
    );
  }

  Widget _sidebarItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dashboard Tab ---
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome, Professor', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const Text('Manage your subjects and track student attendance with ease.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 32),
        _buildStatsGrid(),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Subjects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            ElevatedButton.icon(
              onPressed: () => _showAddSubjectDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Subject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSubjectsGrid(),
      ],
    );
  }

  // --- Student Management Tab ---
  Widget _buildStudentManagementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Student Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const Text('Add, edit, and manage subject enrollment for all students.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _allStudents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildStudentCard(_allStudents[index]),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Student student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(student.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(student.rollNumber, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: student.enrolledSubjectIds.map((id) {
                    final subject = _subjects.firstWhere((s) => s.id == id, orElse: () => Subject(id: '0', name: 'Unknown'));
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.1)),
                      ),
                      child: Text(
                        subject.name,
                        style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.book_outlined, color: Colors.grey[400])),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: Colors.grey[400])),
        ],
      ),
    );
  }

  // --- History Tab ---
  Widget _buildHistoryContent() {
    final List<Map<String, dynamic>> historyData = [
      {'name': 'Calculus', 'date': 'Oct 25, 2023', 'present': 42, 'total': 45, 'percent': 93},
      {'name': 'Data Structures', 'date': 'Oct 24, 2023', 'present': 35, 'total': 38, 'percent': 92},
      {'name': 'Assembly', 'date': 'Oct 24, 2023', 'present': 30, 'total': 32, 'percent': 94},
      {'name': 'Calculus', 'date': 'Oct 23, 2023', 'present': 44, 'total': 45, 'percent': 98},
      {'name': 'Algorithms', 'date': 'Oct 22, 2023', 'present': 39, 'total': 40, 'percent': 98},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attendance History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const Text('View and export past attendance records.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 32),
        Row(
          children: [
            _buildFilterButton(Icons.calendar_today_outlined, 'Date Range'),
            const SizedBox(width: 12),
            _buildFilterButton(Icons.filter_list, 'All Subjects'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF111827),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyData.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildHistoryCard(historyData[index]),
        ),
      ],
    );
  }

  Widget _buildFilterButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(data['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('COMPLETED', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text('${data['percent']}%', style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(data['date'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(width: 12),
              Text('•', style: TextStyle(color: Colors.grey[300])),
              const SizedBox(width: 12),
              Text('${data['present']}/${data['total']} Students Present', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: const Text('View List', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data['percent'] / 100,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 2.5,
          children: [
            _statCard('Total Students', '155', '+4 since last semester', Icons.group, true),
            _statCard('Active Subjects', '4', 'Across 2 departments', Icons.book_outlined, false),
            _statCard('Overall Attendance', '88.4%', '+2.1% from last month', Icons.pie_chart_outline, false),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String value, String trend, IconData icon, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF7C3AED) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: isPrimary ? Colors.white.withOpacity(0.8) : Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 8),
                Text(value, style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF111827), fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(trend, style: TextStyle(color: isPrimary ? Colors.white.withOpacity(0.7) : Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: isPrimary ? Colors.white.withOpacity(0.3) : const Color(0xFF7C3AED).withOpacity(0.3), size: 40),
        ],
      ),
    );
  }

  Widget _buildSubjectsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 2.2,
          ),
          itemCount: _subjects.length,
          itemBuilder: (context, index) => _subjectCard(_subjects[index]),
        );
      },
    );
  }

  Widget _subjectCard(Subject subject) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${subject.studentIds.length} Students',
              style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Next Class: 10:30 AM', style: TextStyle(color: Colors.grey, fontSize: 14)),
              TextButton(
                onPressed: () {},
                child: const Text('Mark Attendance', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Subject Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addSubject(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final rollController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Student Name')),
            TextField(controller: rollController, decoration: const InputDecoration(hintText: 'Roll Number (e.g. CS-001)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && rollController.text.isNotEmpty) {
                _addStudent(nameController.text, rollController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
