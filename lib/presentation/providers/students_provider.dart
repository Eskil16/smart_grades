import 'package:flutter/material.dart';
import '../../data/models/class_session_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/constants/app_constants.dart';

class StudentsProvider extends ChangeNotifier {
  final List<ClassSessionModel> _sessions = [];
  String? _activeSessionId;
  String _searchQuery = '';
  bool _isLoading = true;

  bool get isLoading => _isLoading;

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

  // ── Persistence ──────────────────────────────────────────────
  Future<void> loadFromStorage() async {
    _isLoading = true;
    notifyListeners();
    final saved = await LocalStorageService.loadSessions();
    _sessions.clear();
    _sessions.addAll(saved);
    if (_sessions.isNotEmpty) _activeSessionId = _sessions.first.id;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await LocalStorageService.saveSessions(_sessions);
  }

  // ── Session CRUD ─────────────────────────────────────────────
  void addSession(ClassSessionModel session) {
    _sessions.add(session);
    _activeSessionId ??= session.id;
    notifyListeners();
    _save();
  }

  void updateSession(ClassSessionModel updated) {
    final i = _sessions.indexWhere((s) => s.id == updated.id);
    if (i != -1) _sessions[i] = updated;
    notifyListeners();
    _save();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSessionId == id) {
      _activeSessionId = _sessions.isEmpty ? null : _sessions.first.id;
    }
    notifyListeners();
    _save();
  }

  // ── Subject management ───────────────────────────────────────
  void addSubjectToSession(String sessionId, String subject) {
    final i = _sessions.indexWhere((s) => s.id == sessionId);
    if (i != -1) _sessions[i] = _sessions[i].addSubject(subject);
    notifyListeners();
    _save();
  }

  void removeSubjectFromSession(String sessionId, String subject) {
    final i = _sessions.indexWhere((s) => s.id == sessionId);
    if (i != -1) _sessions[i] = _sessions[i].removeSubject(subject);
    notifyListeners();
    _save();
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
    if (session == null) {
      return {'total': 0, 'passing': 0, 'failing': 0, 'classAverage': 0.0};
    }
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
    _save();
  }

  void updateStudent(StudentModel student) {
    final i = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (i != -1) _sessions[i] = _sessions[i].updateStudent(student);
    notifyListeners();
    _save();
  }

  void deleteStudent(String id) {
    final i = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (i != -1) _sessions[i] = _sessions[i].removeStudent(id);
    notifyListeners();
    _save();
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
}
