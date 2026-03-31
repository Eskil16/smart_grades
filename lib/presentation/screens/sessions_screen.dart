import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/grade_utils.dart';
import '../../data/models/class_session_model.dart';
import '../providers/students_provider.dart';
import 'add_session_screen.dart';
import 'home_screen.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Grades'),
        centerTitle: true,
      ),
      body: Consumer<StudentsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = provider.sessions;
          return sessions.isEmpty
              ? _emptyState(context)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '${sessions.length} class session(s)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                    ...sessions
                        .map((session) => _SessionCard(session: session)),
                    const SizedBox(height: 80),
                  ],
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddSessionScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 90, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first class session to get started',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSessionScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Session'),
          ),
        ],
      ),
    );
  }
}

// ── Session Card ───────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final ClassSessionModel session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StudentsProvider>();
    final avg = session.classAverage;
    final grade = session.totalStudents > 0 ? GradeUtils.letterGrade(avg) : '-';
    final color =
        session.totalStudents > 0 ? AppTheme.gradeColor(grade) : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          provider.setActiveSession(session.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        grade,
                        style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        if (session.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            session.description!,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500]),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          session.academicYear,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppTheme.primaryColor),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddSessionScreen(existingSession: session),
                      ),
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, provider, session),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statChip(Icons.people_outline, '${session.totalStudents}',
                      'Students', AppTheme.primaryColor),
                  _statChip(
                      Icons.check_circle_outline,
                      '${session.passingStudents}',
                      'Passing',
                      AppTheme.successColor),
                  _statChip(Icons.cancel_outlined, '${session.failingStudents}',
                      'Failing', AppTheme.errorColor),
                  _statChip(Icons.book_outlined, '${session.subjects.length}',
                      'Subjects', AppTheme.infoColor),
                ],
              ),

              // Class average bar
              if (session.totalStudents > 0) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Class avg: ${GradeUtils.formatScore(avg)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: avg / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      grade,
                      style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  void _confirmDelete(BuildContext context, StudentsProvider provider,
      ClassSessionModel session) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Session'),
        content: Text(
            'Delete "${session.name}"? All students and grades will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteSession(session.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
