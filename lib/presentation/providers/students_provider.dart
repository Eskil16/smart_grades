import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentsProvider extends ChangeNotifier {
  final StudentRepository _repository = StudentRepository();

  List<StudentModel> _students = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<StudentModel> get students => _searchQuery.isEmpty
      ? _repository.getAll().toList()
      : _repository.search(_searchQuery);

  Map<String, dynamic> get stats => _repository.getStats();

  // Add student
  void addStudent(StudentModel student) {
    _repository.add(student);
    notifyListeners();
  }

  // Update student
  void updateStudent(StudentModel student) {
    _repository.update(student);
    notifyListeners();
  }

  // Delete student
  void deleteStudent(String id) {
    _repository.delete(id);
    notifyListeners();
  }

  // Add grade to student
  void addGrade(String studentId, GradeModel grade) {
    _repository.addGrade(studentId, grade);
    notifyListeners();
  }

  // Remove grade from student
  void removeGrade(String studentId, String gradeId) {
    _repository.removeGrade(studentId, gradeId);
    notifyListeners();
  }

  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Get single student (fresh from repo)
  StudentModel? getStudent(String id) => _repository.getById(id);

  // Load sample data for testing
  void loadSampleData() {
    final samples = [
      StudentModel(
        id: '1',
        name: 'Alice Mbarga',
        studentId: 'STU001',
        email: 'alice@example.com',
        grades: [
          GradeModel(
              id: 'g1',
              subject: 'Mathematics',
              score: 88,
              date: DateTime.now()),
          GradeModel(
              id: 'g2', subject: 'Physics', score: 92, date: DateTime.now()),
          GradeModel(
              id: 'g3', subject: 'English', score: 75, date: DateTime.now()),
        ],
      ),
      StudentModel(
        id: '2',
        name: 'Bob Ngono',
        studentId: 'STU002',
        email: 'bob@example.com',
        grades: [
          GradeModel(
              id: 'g4',
              subject: 'Mathematics',
              score: 65,
              date: DateTime.now()),
          GradeModel(
              id: 'g5', subject: 'Physics', score: 58, date: DateTime.now()),
          GradeModel(
              id: 'g6', subject: 'English', score: 70, date: DateTime.now()),
        ],
      ),
      StudentModel(
        id: '3',
        name: 'Claire Nkomo',
        studentId: 'STU003',
        email: 'claire@example.com',
        grades: [
          GradeModel(
              id: 'g7',
              subject: 'Mathematics',
              score: 95,
              date: DateTime.now()),
          GradeModel(
              id: 'g8', subject: 'Physics', score: 98, date: DateTime.now()),
          GradeModel(
              id: 'g9', subject: 'English', score: 91, date: DateTime.now()),
        ],
      ),
    ];
    for (final s in samples) {
      _repository.add(s);
    }
    notifyListeners();
  }
}
