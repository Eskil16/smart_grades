import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/class_session_model.dart';
import '../providers/students_provider.dart';

class AddSessionScreen extends StatefulWidget {
  final ClassSessionModel? existingSession;
  const AddSessionScreen({super.key, this.existingSession});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _yearController = TextEditingController();
  final _subjectController = TextEditingController();

  List<String> _subjects = [];
  bool get _isEditing => widget.existingSession != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingSession!.name;
      _descController.text = widget.existingSession!.description ?? '';
      _yearController.text = widget.existingSession!.academicYear;
      _subjects = [...widget.existingSession!.subjects];
    } else {
      _yearController.text = '2025/2026';
      _subjects = [...AppConstants.defaultSubjects];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _yearController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) return;
    if (_subjects.contains(subject)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject already exists')),
      );
      return;
    }
    setState(() => _subjects.add(subject));
    _subjectController.clear();
  }

  void _removeSubject(String subject) {
    setState(() => _subjects.remove(subject));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one subject')),
      );
      return;
    }

    final provider = context.read<StudentsProvider>();
    final session = ClassSessionModel(
      id: _isEditing
          ? widget.existingSession!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      academicYear: _yearController.text.trim(),
      subjects: _subjects,
      students: _isEditing ? widget.existingSession!.students : [],
      createdAt:
          _isEditing ? widget.existingSession!.createdAt : DateTime.now(),
    );

    if (_isEditing) {
      provider.updateSession(session);
    } else {
      provider.addSession(session);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing
            ? '${session.name} updated!'
            : '${session.name} created!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Session' : 'New Session'),
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
            // ── Session Info ──────────────────────────────────
            _sectionHeader(Icons.class_, 'Session Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Session Name *',
                hintText: 'e.g. IRT 3A Morning',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Information Technology',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Academic Year *',
                hintText: 'e.g. 2025/2026',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Academic year is required'
                  : null,
            ),
            const SizedBox(height: 24),

            // ── Subjects ──────────────────────────────────────
            _sectionHeader(Icons.book, 'Subjects (${_subjects.length})'),
            const SizedBox(height: 12),

            // Add custom subject
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Add custom subject',
                          prefixIcon: Icon(Icons.add_circle_outline),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addSubject(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addSubject,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Subjects list
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: _subjects.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No subjects added yet'),
                    )
                  : Column(
                      children: _subjects.asMap().entries.map((entry) {
                        final subject = entry.value;
                        final isDefault =
                            AppConstants.defaultSubjects.contains(subject);
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(subject),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'default',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.primaryColor),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () => _removeSubject(subject),
                                tooltip: 'Remove subject',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
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
