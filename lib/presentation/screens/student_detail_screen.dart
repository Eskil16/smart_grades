import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/grade_utils.dart';
import '../../data/models/student_model.dart';
import '../providers/students_provider.dart';
import '../widgets/grade_card.dart';
import 'add_student_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentsProvider>(
      builder: (context, provider, _) {
        final student = provider.getStudent(studentId);
        if (student == null) {
          return const Scaffold(
            body: Center(child: Text('Student not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(student.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit student',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddStudentScreen(existingStudent: student),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete student',
                onPressed: () => _confirmDelete(context, provider, student),
              ),
            ],
          ),
          body: student.grades.isEmpty
              ? _emptyGrades(context, student)
              : ListView(
                  children: [
                    _profileCard(context, student),
                    _statsRow(student),
                    if (student.grades.length >= 2) _barChart(student),
                    _gradeListHeader(student),
                    ...student.grades.map((g) => GradeCard(
                          grade: g,
                          onDelete: () =>
                              provider.removeGrade(student.id, g.id),
                        )),
                    const SizedBox(height: 32),
                  ],
                ),
        );
      },
    );
  }

  // ── Profile card ──────────────────────────────────────────────
  Widget _profileCard(BuildContext context, StudentModel student) {
    final color = AppTheme.gradeColor(student.letterGrade);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(
              student.letterGrade,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${student.studentId}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
                if (student.email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    student.email!,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    student.isPassing ? '✓ Passing' : '✗ Failing',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                GradeUtils.formatScore(student.average),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Average',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'GPA ${GradeUtils.formatGpa(student.gpa)}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────
  Widget _statsRow(StudentModel student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _miniStat(
              'Highest', GradeUtils.formatScore(student.highest), Colors.green),
          const SizedBox(width: 12),
          _miniStat(
              'Lowest', GradeUtils.formatScore(student.lowest), Colors.red),
          const SizedBox(width: 12),
          _miniStat(
              'Subjects', '${student.grades.length}', AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── Bar chart — shows CC, SN, Final per subject ───────────────
  Widget _barChart(StudentModel student) {
    final grades = student.grades;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grade Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _legendDot(Colors.blue, 'CC (30%)'),
              const SizedBox(width: 16),
              _legendDot(Colors.indigo, 'SN (70%)'),
              const SizedBox(width: 16),
              _legendDot(AppTheme.primaryColor, 'Final'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final g = grades[groupIndex];
                      final labels = ['CC', 'SN', 'Final'];
                      final values = [g.ccScore, g.snScore, g.finalScore];
                      return BarTooltipItem(
                        '${labels[rodIndex]}: ${GradeUtils.formatScore(values[rodIndex])}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= grades.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            grades[i].subject.length > 4
                                ? grades[i].subject.substring(0, 4)
                                : grades[i].subject,
                            style: const TextStyle(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: grades.asMap().entries.map((entry) {
                  final g = entry.value;
                  final finalColor =
                      AppTheme.gradeColor(GradeUtils.letterGrade(g.finalScore));
                  return BarChartGroupData(
                    x: entry.key,
                    groupVertically: false,
                    barRods: [
                      BarChartRodData(
                        toY: g.ccScore,
                        color: Colors.blue,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: g.snScore,
                        color: Colors.indigo,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: g.finalScore,
                        color: finalColor,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  // ── Grade list header ─────────────────────────────────────────
  Widget _gradeListHeader(StudentModel student) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.list_alt, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'All Grades (${student.grades.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────
  Widget _emptyGrades(BuildContext context, StudentModel student) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No grades yet for ${student.name}',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddStudentScreen(existingStudent: student),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Grades'),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation ───────────────────────────────────────
  void _confirmDelete(
      BuildContext context, StudentsProvider provider, StudentModel student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Student'),
        content: Text(
            'Are you sure you want to delete ${student.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteStudent(student.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
