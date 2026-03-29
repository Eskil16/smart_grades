import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/student_model.dart';
import '../../data/models/grade_model.dart';
import '../providers/students_provider.dart';

class AddStudentScreen extends StatefulWidget {
  final StudentModel? existingStudent;
  const AddStudentScreen({super.key, this.existingStudent});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();

  // Grade form
  final _scoreController = TextEditingController();
  final _commentController = TextEditingController();
  String _selectedSubject = AppConstants.defaultSubjects.first;

  final List<GradeModel> _grades = [];
  bool get _isEditing => widget.existingStudent != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingStudent!.name;
      _studentIdController.text = widget.existingStudent!.studentId;
      _emailController.text = widget.existingStudent!.email ?? '';
      _grades.addAll(widget.existingStudent!.grades);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _scoreController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _addGrade() {
    final score = double.tryParse(_scoreController.text);
    if (score == null || !GradeModel.isValidScore(score)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid score (0–100)')),
      );
      return;
    }
    setState(() {
      _grades.add(GradeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: _selectedSubject,
        score: score,
        comment:
            _commentController.text.isEmpty ? null : _commentController.text,
        date: DateTime.now(),
      ));
      _scoreController.clear();
      _commentController.clear();
    });
  }

  void _removeGrade(int index) {
    setState(() => _grades.removeAt(index));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<StudentsProvider>();
    final student = StudentModel(
      id: _isEditing
          ? widget.existingStudent!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      grades: _grades,
    );
    if (_isEditing) {
      provider.updateStudent(student);
    } else {
      provider.addStudent(student);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing
            ? '${student.name} updated successfully!'
            : '${student.name} added successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Student' : 'Add Student'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Student info section
            _sectionHeader(Icons.person, 'Student Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID *',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Student ID is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // Grades section
            _sectionHeader(Icons.grade, 'Add Grades'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                      items: AppConstants.defaultSubjects
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSubject = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _scoreController,
                      decoration: const InputDecoration(
                        labelText: 'Score (0–100)',
                        prefixIcon: Icon(Icons.score_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comment (optional)',
                        prefixIcon: Icon(Icons.comment_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addGrade,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Grade'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Added grades list
            if (_grades.isNotEmpty) ...[
              _sectionHeader(Icons.list, 'Grades Added (${_grades.length})'),
              const SizedBox(height: 8),
              ..._grades.asMap().entries.map((entry) {
                final g = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.gradeColor(g.score >= 90
                              ? 'A'
                              : g.score >= 80
                                  ? 'B'
                                  : g.score >= 70
                                      ? 'C'
                                      : g.score >= 60
                                          ? 'D'
                                          : 'F')
                          .withOpacity(0.2),
                      child: Text(
                        g.score >= 90
                            ? 'A'
                            : g.score >= 80
                                ? 'B'
                                : g.score >= 70
                                    ? 'C'
                                    : g.score >= 60
                                        ? 'D'
                                        : 'F',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gradeColor(g.score >= 90
                              ? 'A'
                              : g.score >= 80
                                  ? 'B'
                                  : g.score >= 70
                                      ? 'C'
                                      : g.score >= 60
                                          ? 'D'
                                          : 'F'),
                        ),
                      ),
                    ),
                    title: Text(g.subject,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(g.comment ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${g.score}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => _removeGrade(entry.key),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
