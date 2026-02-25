enum AttendanceStatus { present, absent, late }

enum AttendanceType { classAttendance, labAttendance }

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

class AttendanceRecord {
  final int? id;
  final DateTime date;
  final Map<String, AttendanceStatus> studentStatuses;
  final AttendanceType type; // Added type

  AttendanceRecord({
    this.id, 
    required this.date, 
    required this.studentStatuses,
    this.type = AttendanceType.classAttendance, // Default to class
  });

  int get presentCount => studentStatuses.values.where((s) => s == AttendanceStatus.present).length;
  int get absentCount => studentStatuses.values.where((s) => s == AttendanceStatus.absent).length;
  int get lateCount => studentStatuses.values.where((s) => s == AttendanceStatus.late).length;
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
    int totalPossible = attendanceRecords.length * studentIds.length;
    int actualPresent = 0;
    for (var record in attendanceRecords) {
      actualPresent += record.presentCount;
      actualPresent += record.lateCount;
    }
    return (actualPresent / totalPossible) * 100;
  }
}
