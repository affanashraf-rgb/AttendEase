import '../models/models.dart';

List<Student> initialStudents = [
  Student(id: '1', name: 'Affan Ahmed', rollNumber: 'CS-001', enrolledSubjectIds: ['1', '2']),
  Student(id: '2', name: 'Bisma Khan', rollNumber: 'CS-002', enrolledSubjectIds: ['1', '3']),
  Student(id: '3', name: 'Daniyal Shah', rollNumber: 'CS-003', enrolledSubjectIds: ['2', '4']),
  Student(id: '4', name: 'Esha Malik', rollNumber: 'CS-004', enrolledSubjectIds: ['1', '4']),
  Student(id: '5', name: 'Fahad Mustafa', rollNumber: 'CS-005', enrolledSubjectIds: ['1', '2']),
];

List<Subject> initialSubjects = [
  Subject(id: '1', name: 'Calculus', studentIds: ['1', '2', '4', '5']),
  Subject(id: '2', name: 'Data Structures', studentIds: ['1', '3', '5']),
  Subject(id: '3', name: 'Assembly', studentIds: ['2']),
  Subject(id: '4', name: 'Algorithms', studentIds: ['3', '4']),
];
