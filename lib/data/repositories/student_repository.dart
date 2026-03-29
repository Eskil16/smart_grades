import '../models/student_model.dart';
import '../models/grade_model.dart';

class StudentRepository {
  // In-memory storage (list is private)
  final List<StudentModel> _students = [];

  // Get all students (returns unmodifiable copy)
  List<StudentModel> getAll() => List.unmodifiable(_students);

  // Get student by id
  StudentModel? getById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Add a new student
  void add(StudentModel student) {
    _students.add(student);
  }

  // Update existing student
  void update(StudentModel updated) {
    final index = _students.indexWhere((s) => s.id == updated.id);
    if (index != -1) _students[index] = updated;
  }

  // Delete student by id
  void delete(String id) {
    _students.removeWhere((s) => s.id == id);
  }

  // Add grade to a student
  void addGrade(String studentId, GradeModel grade) {
    final student = getById(studentId);
    if (student != null) update(student.addGrade(grade));
  }

  // Remove grade from a student
  void removeGrade(String studentId, String gradeId) {
    final student = getById(studentId);
    if (student != null) update(student.removeGrade(gradeId));
  }

  // Search students by name or ID
  List<StudentModel> search(String query) {
    final q = query.toLowerCase();
    return _students
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.studentId.toLowerCase().contains(q))
        .toList();
  }

  // Get class statistics
  Map<String, dynamic> getStats() {
    if (_students.isEmpty) {
      return {
        'total': 0,
        'passing': 0,
        'failing': 0,
        'classAverage': 0.0,
      };
    }
    final averages = _students.map((s) => s.average).toList();
    final passing = _students.where((s) => s.isPassing).length;
    return {
      'total': _students.length,
      'passing': passing,
      'failing': _students.length - passing,
      'classAverage': averages.reduce((a, b) => a + b) / averages.length,
    };
  }
}
