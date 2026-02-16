class Student {
  final String id;
  final String name;
  final String rollNumber;
  final List<String> enrolledSubjectIds;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.enrolledSubjectIds = const [],
  });
}

class Subject {
  final String id;
  final String name;
  final List<String> studentIds;
  final List<AttendanceRecord> attendanceRecords;

  Subject({
    required this.id,
    required this.name,
    this.studentIds = const [],
    this.attendanceRecords = const [],
  });

  double get attendancePercentage {
    if (attendanceRecords.isEmpty || studentIds.isEmpty) return 0.0;
    int totalSlots = attendanceRecords.length * studentIds.length;
    int presentCount = 0;
    for (var record in attendanceRecords) {
      presentCount += record.presentStudentIds.length;
    }
    return (presentCount / totalSlots) * 100;
  }
}

class AttendanceRecord {
  final DateTime date;
  final List<String> presentStudentIds;

  AttendanceRecord({required this.date, required this.presentStudentIds});
}
