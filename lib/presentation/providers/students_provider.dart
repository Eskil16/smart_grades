import 'package:flutter/material.dart';
import '../../data/models/class_session_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/grade_model.dart';
import '../../core/constants/app_constants.dart';

class StudentsProvider extends ChangeNotifier {
  final List<ClassSessionModel> _sessions = [];
  String? _activeSessionId;
  String _searchQuery = '';

  // ── Session getters ──────────────────────────────────────────
  List<ClassSessionModel> get sessions => List.unmodifiable(_sessions);

  ClassSessionModel? get activeSession => _activeSessionId == null
      ? null
      : _sessions.firstWhere((s) => s.id == _activeSessionId,
          orElse: () => _sessions.first);

  void setActiveSession(String id) {
    _activeSessionId = id;
    _searchQuery = '';
    notifyListeners();
  }

  // ── Session CRUD ─────────────────────────────────────────────
  void addSession(ClassSessionModel session) {
    _sessions.add(session);
    _activeSessionId ??= session.id;
    notifyListeners();
  }

  void updateSession(ClassSessionModel updated) {
    final i = _sessions.indexWhere((s) => s.id == updated.id);
    if (i != -1) _sessions[i] = updated;
    notifyListeners();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSessionId == id) {
      _activeSessionId = _sessions.isEmpty ? null : _sessions.first.id;
    }
    notifyListeners();
  }

  // ── Subject management ───────────────────────────────────────
  void addSubjectToSession(String sessionId, String subject) {
    final i = _sessions.indexWhere((s) => s.id == sessionId);
    if (i != -1) _sessions[i] = _sessions[i].addSubject(subject);
    notifyListeners();
  }

  void removeSubjectFromSession(String sessionId, String subject) {
    final i = _sessions.indexWhere((s) => s.id == sessionId);
    if (i != -1) _sessions[i] = _sessions[i].removeSubject(subject);
    notifyListeners();
  }

  // ── Student getters ──────────────────────────────────────────
  List<StudentModel> get students {
    final session = activeSession;
    if (session == null) return [];
    if (_searchQuery.isEmpty) return session.students;
    final q = _searchQuery.toLowerCase();
    return session.students
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.studentId.toLowerCase().contains(q))
        .toList();
  }

  Map<String, dynamic> get stats {
    final session = activeSession;
    if (session == null)
      return {'total': 0, 'passing': 0, 'failing': 0, 'classAverage': 0.0};
    return {
      'total': session.totalStudents,
      'passing': session.passingStudents,
      'failing': session.failingStudents,
      'classAverage': session.classAverage,
    };
  }

  StudentModel? getStudent(String id) {
    try {
      return activeSession?.students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Student CRUD ─────────────────────────────────────────────
  void addStudent(StudentModel student) {
    final i = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (i != -1) _sessions[i] = _sessions[i].addStudent(student);
    notifyListeners();
  }

  void updateStudent(StudentModel student) {
    final i = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (i != -1) _sessions[i] = _sessions[i].updateStudent(student);
    notifyListeners();
  }

  void deleteStudent(String id) {
    final i = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (i != -1) _sessions[i] = _sessions[i].removeStudent(id);
    notifyListeners();
  }

  // ── Grade CRUD ───────────────────────────────────────────────
  void addGrade(String studentId, GradeModel grade) {
    final student = getStudent(studentId);
    if (student != null) updateStudent(student.addGrade(grade));
  }

  void removeGrade(String studentId, String gradeId) {
    final student = getStudent(studentId);
    if (student != null) updateStudent(student.removeGrade(gradeId));
  }

  // ── Search ───────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  String get searchQuery => _searchQuery;

  // ── Sample data ──────────────────────────────────────────────
  void loadSampleData() {
    final session1 = ClassSessionModel(
      id: '1',
      name: 'IRT 3A — Morning',
      description: 'Information & Communication Technology',
      academicYear: '2025/2026',
      subjects: [...AppConstants.defaultSubjects],
      createdAt: DateTime.now(),
      students: [
        StudentModel(
          id: 's1',
          name: 'Alice Mbarga',
          studentId: 'STU001',
          email: 'alice@example.com',
          grades: [
            GradeModel(
                id: 'g1',
                subject: 'Mathematics',
                score: 85,
                date: DateTime.now()),
            GradeModel(
                id: 'g2', subject: 'Physics', score: 72, date: DateTime.now()),
            GradeModel(
                id: 'g3', subject: 'English', score: 55, date: DateTime.now()),
          ],
        ),
        StudentModel(
          id: 's2',
          name: 'Bob Ngono',
          studentId: 'STU002',
          email: 'bob@example.com',
          grades: [
            GradeModel(
                id: 'g4',
                subject: 'Mathematics',
                score: 43,
                date: DateTime.now()),
            GradeModel(
                id: 'g5', subject: 'Physics', score: 38, date: DateTime.now()),
            GradeModel(
                id: 'g6', subject: 'English', score: 61, date: DateTime.now()),
          ],
        ),
        StudentModel(
          id: 's3',
          name: 'Claire Nkomo',
          studentId: 'STU003',
          grades: [
            GradeModel(
                id: 'g7',
                subject: 'Mathematics',
                score: 92,
                date: DateTime.now()),
            GradeModel(
                id: 'g8', subject: 'Physics', score: 88, date: DateTime.now()),
            GradeModel(
                id: 'g9', subject: 'English', score: 76, date: DateTime.now()),
          ],
        ),
      ],
    );

    final session2 = ClassSessionModel(
      id: '2',
      name: 'IRT 3B — Afternoon',
      description: 'Information & Communication Technology',
      academicYear: '2025/2026',
      subjects: [...AppConstants.defaultSubjects],
      createdAt: DateTime.now(),
      students: [
        StudentModel(
          id: 's4',
          name: 'David Eto',
          studentId: 'STU004',
          grades: [
            GradeModel(
                id: 'g10',
                subject: 'Algorithms',
                score: 78,
                date: DateTime.now()),
            GradeModel(
                id: 'g11',
                subject: 'Networking',
                score: 65,
                date: DateTime.now()),
          ],
        ),
      ],
    );

    _sessions.addAll([session1, session2]);
    _activeSessionId = session1.id;
    notifyListeners();
  }
}
