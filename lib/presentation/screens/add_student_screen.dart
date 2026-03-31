import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/grade_utils.dart';
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
  final _ccController = TextEditingController();
  final _snController = TextEditingController();
  final _commentController = TextEditingController();

  List<String> _sessionSubjects = [];
  String? _selectedSubject;
  final List<GradeModel> _grades = [];
  bool get _isEditing => widget.existingStudent != null;

  // Live preview of final score
  double get _previewFinal {
    final cc = double.tryParse(_ccController.text) ?? 0;
    final sn = double.tryParse(_snController.text) ?? 0;
    return (cc * 0.3) + (sn * 0.7);
  }

  @override
  void initState() {
    super.initState();
    final session = context.read<StudentsProvider>().activeSession;
    _sessionSubjects = session?.subjects ?? [];
    _selectedSubject =
        _sessionSubjects.isNotEmpty ? _sessionSubjects.first : null;

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
    _ccController.dispose();
    _snController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _addGrade() {
    if (_selectedSubject == null) return;

    final cc = double.tryParse(_ccController.text);
    final sn = double.tryParse(_snController.text);

    if (cc == null || !GradeModel.isValidScore(cc)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('CC score invalide — doit être entre 0 et 100')),
      );
      return;
    }
    if (sn == null || !GradeModel.isValidScore(sn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('SN score invalide — doit être entre 0 et 100')),
      );
      return;
    }

    // Check if subject already added
    if (_grades.any((g) => g.subject == _selectedSubject)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '$_selectedSubject already added. Delete it first to update.')),
      );
      return;
    }

    setState(() {
      _grades.add(GradeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: _selectedSubject!,
        ccScore: cc,
        snScore: sn,
        comment:
            _commentController.text.isEmpty ? null : _commentController.text,
        date: DateTime.now(),
      ));
      _ccController.clear();
      _snController.clear();
      _commentController.clear();
    });
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
            ? '${student.name} mis à jour!'
            : '${student.name} ajouté!'),
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
            // ── Student Info ──────────────────────────────────
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

            // ── Add Grade ─────────────────────────────────────
            _sectionHeader(Icons.grade, 'Add Grade per Subject'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Subject dropdown
                    if (_sessionSubjects.isEmpty)
                      const Text(
                        'No subjects in this session.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          prefixIcon: Icon(Icons.book_outlined),
                        ),
                        items: _sessionSubjects
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSubject = v),
                      ),
                    const SizedBox(height: 12),

                    // CC and SN fields side by side
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ccController,
                            decoration: const InputDecoration(
                              labelText: 'CC (0–100)',
                              prefixIcon: Icon(Icons.edit_note),
                              helperText: '30% of final',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _snController,
                            decoration: const InputDecoration(
                              labelText: 'SN (0–100)',
                              prefixIcon: Icon(Icons.assignment),
                              helperText: '70% of final',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Live preview
                    if (_ccController.text.isNotEmpty ||
                        _snController.text.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Preview: (${_ccController.text.isEmpty ? '0' : _ccController.text} × 30%) + (${_snController.text.isEmpty ? '0' : _snController.text} × 70%)',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              '= ${GradeUtils.formatScore(_previewFinal)}  ${GradeUtils.letterGrade(_previewFinal)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gradeColor(
                                    GradeUtils.letterGrade(_previewFinal)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

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

            // ── Grades list ───────────────────────────────────
            if (_grades.isNotEmpty) ...[
              _sectionHeader(Icons.list, 'Grades Added (${_grades.length})'),
              const SizedBox(height: 8),
              ..._grades.asMap().entries.map((entry) {
                final g = entry.value;
                final grade = GradeUtils.letterGrade(g.finalScore);
                final color = AppTheme.gradeColor(grade);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Text(grade,
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(g.subject,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'CC: ${g.ccScore} | SN: ${g.snScore} | Final: ${GradeUtils.formatScore(g.finalScore)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'GPA ${GradeUtils.formatGpa(GradeUtils.gpaPoints(g.finalScore))}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () =>
                              setState(() => _grades.removeAt(entry.key)),
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
