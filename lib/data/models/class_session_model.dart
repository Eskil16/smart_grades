import 'student_model.dart';
import '../../core/constants/app_constants.dart';

class ClassSessionModel {
  final String id;
  final String name;
  final String? description;
  final String academicYear;
  final List<String> subjects;
  final List<StudentModel> students;
  final DateTime createdAt;

  const ClassSessionModel({
    required this.id,
    required this.name,
    this.description,
    required this.academicYear,
    required this.subjects,
    this.students = const [],
    required this.createdAt,
  });

  // Total students
  int get totalStudents => students.length;

  // Passing students
  int get passingStudents => students.where((s) => s.isPassing).length;

  // Failing students
  int get failingStudents => totalStudents - passingStudents;

  // Class average
  double get classAverage => students.isEmpty
      ? 0.0
      : students.map((s) => s.average).reduce((a, b) => a + b) /
          students.length;

  // Copy with updated fields
  ClassSessionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? academicYear,
    List<String>? subjects,
    List<StudentModel>? students,
    DateTime? createdAt,
  }) =>
      ClassSessionModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        academicYear: academicYear ?? this.academicYear,
        subjects: subjects ?? this.subjects,
        students: students ?? this.students,
        createdAt: createdAt ?? this.createdAt,
      );

  // Add student
  ClassSessionModel addStudent(StudentModel student) =>
      copyWith(students: [...students, student]);

  // Remove student
  ClassSessionModel removeStudent(String studentId) =>
      copyWith(students: students.where((s) => s.id != studentId).toList());

  // Update student
  ClassSessionModel updateStudent(StudentModel updated) => copyWith(
        students:
            students.map((s) => s.id == updated.id ? updated : s).toList(),
      );

  // Add custom subject
  ClassSessionModel addSubject(String subject) => subjects.contains(subject)
      ? this
      : copyWith(subjects: [...subjects, subject]);

  // Remove custom subject
  ClassSessionModel removeSubject(String subject) =>
      copyWith(subjects: subjects.where((s) => s != subject).toList());

  // Convert to map
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description ?? '',
        'academicYear': academicYear,
        'subjects': subjects,
        'students': students.map((s) => s.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  // Create from map
  factory ClassSessionModel.fromMap(Map<String, dynamic> map) =>
      ClassSessionModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        academicYear: map['academicYear'] as String,
        subjects: List<String>.from(map['subjects'] as List),
        students: (map['students'] as List<dynamic>? ?? [])
            .map((s) => StudentModel.fromMap(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  @override
  String toString() => 'ClassSession(name: $name, students: $totalStudents)';
}
