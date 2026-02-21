import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rollNumber TEXT NOT NULL,
        enrolledSubjectIds TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        studentIds TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId TEXT NOT NULL,
        date TEXT NOT NULL,
        studentStatuses TEXT NOT NULL
      )
    ''');
  }

  // Student Methods
  Future<void> insertStudent(Student student) async {
    final db = await instance.database;
    await db.insert('students', {
      'id': student.id,
      'name': student.name,
      'rollNumber': student.rollNumber,
      'enrolledSubjectIds': student.enrolledSubjectIds.join(','),
    });
  }

  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students');
    return result.map((json) => Student(
      id: json['id'] as String,
      name: json['name'] as String,
      rollNumber: json['rollNumber'] as String,
      enrolledSubjectIds: (json['enrolledSubjectIds'] as String).isEmpty 
          ? [] 
          : (json['enrolledSubjectIds'] as String).split(','),
    )).toList();
  }

  Future<void> updateStudent(Student student) async {
    final db = await instance.database;
    await db.update('students', {
      'name': student.name,
      'rollNumber': student.rollNumber,
      'enrolledSubjectIds': student.enrolledSubjectIds.join(','),
    }, where: 'id = ?', whereArgs: [student.id]);
  }

  Future<void> deleteStudent(String id) async {
    final db = await instance.database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // Subject Methods
  Future<void> insertSubject(Subject subject) async {
    final db = await instance.database;
    await db.insert('subjects', {
      'id': subject.id,
      'name': subject.name,
      'studentIds': subject.studentIds.join(','),
    });
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await instance.database;
    final subjectsJson = await db.query('subjects');
    
    List<Subject> subjects = [];
    for (var json in subjectsJson) {
      final subjectId = json['id'] as String;
      final records = await getAttendanceRecordsForSubject(subjectId);
      
      subjects.add(Subject(
        id: subjectId,
        name: json['name'] as String,
        studentIds: (json['studentIds'] as String).isEmpty 
            ? [] 
            : (json['studentIds'] as String).split(','),
        attendanceRecords: records,
      ));
    }
    return subjects;
  }

  Future<void> updateSubject(Subject subject) async {
    final db = await instance.database;
    await db.update('subjects', {
      'name': subject.name,
      'studentIds': subject.studentIds.join(','),
    }, where: 'id = ?', whereArgs: [subject.id]);
  }

  Future<void> deleteSubject(String id) async {
    final db = await instance.database;
    await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
    await db.delete('attendance_records', where: 'subjectId = ?', whereArgs: [id]);
  }

  // Attendance Record Methods
  // Note: Using '|' as a delimiter because student IDs (DateTime strings) contain ':'
  Future<void> insertAttendanceRecord(String subjectId, AttendanceRecord record) async {
    final db = await instance.database;
    final statusMap = record.studentStatuses.map((key, value) => MapEntry(key, value.index.toString()));
    
    await db.insert('attendance_records', {
      'subjectId': subjectId,
      'date': record.date.toIso8601String(),
      'studentStatuses': statusMap.entries.map((e) => '${e.key}|${e.value}').join(','),
    });
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    final db = await instance.database;
    final statusMap = record.studentStatuses.map((key, value) => MapEntry(key, value.index.toString()));
    
    await db.update('attendance_records', {
      'studentStatuses': statusMap.entries.map((e) => '${e.key}|${e.value}').join(','),
    }, where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteAttendanceRecord(int id) async {
    final db = await instance.database;
    await db.delete('attendance_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsForSubject(String subjectId) async {
    final db = await instance.database;
    final result = await db.query('attendance_records', where: 'subjectId = ?', whereArgs: [subjectId]);
    
    return result.map((json) {
      final statusString = json['studentStatuses'] as String;
      Map<String, AttendanceStatus> statuses = {};
      
      if (statusString.isNotEmpty) {
        final pairs = statusString.split(',');
        for (var pair in pairs) {
          // Splitting by '|' to avoid conflict with ':' in DateTime-based student IDs
          final parts = pair.split('|');
          if (parts.length == 2) {
            statuses[parts[0]] = AttendanceStatus.values[int.parse(parts[1])];
          }
        }
      }
      
      return AttendanceRecord(
        id: json['id'] as int,
        date: DateTime.parse(json['date'] as String),
        studentStatuses: statuses,
      );
    }).toList();
  }
}
