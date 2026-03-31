import 'grade_model.dart';
import '../../core/utils/grade_utils.dart';

class StudentModel {
  final String id;
  final String name;
  final String studentId;
  final String? email;
  final List<GradeModel> grades;

  const StudentModel({
    required this.id,
    required this.name,
    required this.studentId,
    this.email,
    this.grades = const [],
  });

  // Computed properties using finalScore
  double get average =>
      GradeUtils.average(grades.map((g) => g.finalScore).toList());
  double get highest =>
      GradeUtils.highest(grades.map((g) => g.finalScore).toList());
  double get lowest =>
      GradeUtils.lowest(grades.map((g) => g.finalScore).toList());
  double get gpa =>
      GradeUtils.averageGpa(grades.map((g) => g.finalScore).toList());
  String get letterGrade => GradeUtils.letterGrade(average);
  bool get isPassing =>
      GradeUtils.isPassing(grades.map((g) => g.finalScore).toList());

  StudentModel copyWith({
    String? id,
    String? name,
    String? studentId,
    String? email,
    List<GradeModel>? grades,
  }) =>
      StudentModel(
        id: id ?? this.id,
        name: name ?? this.name,
        studentId: studentId ?? this.studentId,
        email: email ?? this.email,
        grades: grades ?? this.grades,
      );

  StudentModel addGrade(GradeModel grade) =>
      copyWith(grades: [...grades, grade]);

  StudentModel removeGrade(String gradeId) =>
      copyWith(grades: grades.where((g) => g.id != gradeId).toList());

  StudentModel updateGrade(GradeModel updated) => copyWith(
        grades: grades.map((g) => g.id == updated.id ? updated : g).toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'studentId': studentId,
        'email': email ?? '',
        'average': average,
        'gpa': gpa,
        'letterGrade': letterGrade,
        'isPassing': isPassing,
        'grades': grades.map((g) => g.toMap()).toList(),
      };

  factory StudentModel.fromMap(Map<String, dynamic> map) => StudentModel(
        id: map['id'] as String,
        name: map['name'] as String,
        studentId: map['studentId'] as String,
        email: map['email'] as String?,
        grades: (map['grades'] as List<dynamic>? ?? [])
            .map((g) => GradeModel.fromMap(g as Map<String, dynamic>))
            .toList(),
      );

  @override
  String toString() =>
      'StudentModel(name: $name, average: $average, gpa: $gpa)';
}
