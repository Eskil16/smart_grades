import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/grade_utils.dart';
import '../../data/models/student_model.dart';
import '../providers/students_provider.dart';
import '../widgets/stat_card.dart';
import 'add_student_screen.dart';
import 'add_session_screen.dart';
import 'student_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<StudentsProvider>().activeSession;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session?.name ?? 'Smart Grades',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (session != null)
              Text(
                session.academicYear,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit session',
            onPressed: () {
              if (session != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddSessionScreen(existingSession: session),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            onPressed: () => _showExportDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StudentsTab(searchController: _searchController),
          const _DashboardTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddStudentScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ExportSheet(),
    );
  }
}

// ── Students Tab ───────────────────────────────────────────────────────────
class _StudentsTab extends StatelessWidget {
  final TextEditingController searchController;
  const _StudentsTab({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or student ID...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
                onChanged: provider.setSearchQuery,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${provider.students.length} student(s)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.students.isEmpty
                  ? _emptyState(context)
                  : ListView.builder(
                      itemCount: provider.students.length,
                      itemBuilder: (context, index) {
                        return _StudentTile(student: provider.students[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 90, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No students yet',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first student',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Student Tile ───────────────────────────────────────────────────────────
class _StudentTile extends StatelessWidget {
  final StudentModel student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(student.letterGrade);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDetailScreen(studentId: student.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Grade badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    student.letterGrade,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.studentId,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: student.average / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Score + GPA
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    GradeUtils.formatScore(student.average),
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'GPA ${GradeUtils.formatGpa(GradeUtils.averageGpa(student.grades.map((g) => g.score).toList()))}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: student.isPassing
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student.isPassing ? 'Passing' : 'Failing',
                      style: TextStyle(
                        fontSize: 11,
                        color: student.isPassing
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Tab ──────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentsProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        final students = provider.students;

        if (students.isEmpty) {
          return const Center(child: Text('No data yet. Add students first.'));
        }

        final averages = students.map((s) => s.average).toList();
        final distribution = GradeUtils.gradeDistribution(averages);
        final classAvg = GradeUtils.classAverage(averages);
        final classGpa = GradeUtils.averageGpa(averages);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stat cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  title: 'TOTAL',
                  value: '${stats['total']}',
                  icon: Icons.people,
                  color: AppTheme.primaryColor,
                  subtitle: 'Students enrolled',
                ),
                StatCard(
                  title: 'CLASS AVG',
                  value: GradeUtils.formatScore(classAvg),
                  icon: Icons.analytics,
                  color: AppTheme.infoColor,
                  subtitle: 'GPA ${GradeUtils.formatGpa(classGpa)}',
                ),
                StatCard(
                  title: 'PASSING',
                  value: '${stats['passing']}',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.successColor,
                  subtitle: 'Students passing',
                ),
                StatCard(
                  title: 'FAILING',
                  value: '${stats['failing']}',
                  icon: Icons.warning_amber_outlined,
                  color: AppTheme.errorColor,
                  subtitle: 'Students failing',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pie chart — grade distribution
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grade Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: distribution.entries
                            .where((e) => e.value > 0)
                            .map((e) {
                          final color = AppTheme.gradeColor(e.key);
                          return PieChartSectionData(
                            color: color,
                            value: e.value.toDouble(),
                            title: '${e.key}\n${e.value}',
                            radius: 55,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: distribution.entries.map((e) {
                      final color = AppTheme.gradeColor(e.key);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('${e.key}: ${e.value}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top students
            const Text(
              'Top Students',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(() {
              final sorted = [...students]
                ..sort((a, b) => b.average.compareTo(a.average));
              return sorted.take(3).toList();
            }())
                .asMap()
                .entries
                .map((entry) {
              final medals = ['🥇', '🥈', '🥉'];
              final s = entry.value;
              final color = AppTheme.gradeColor(s.letterGrade);
              final gpa =
                  GradeUtils.averageGpa(s.grades.map((g) => g.score).toList());
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Text(medals[entry.key],
                      style: const TextStyle(fontSize: 24)),
                  title: Text(s.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle:
                      Text('${s.studentId} • GPA ${GradeUtils.formatGpa(gpa)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        GradeUtils.formatScore(s.average),
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        s.letterGrade,
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ── Export Sheet ───────────────────────────────────────────────────────────
class _ExportSheet extends StatelessWidget {
  const _ExportSheet();

  @override
  Widget build(BuildContext context) {
    final formats = [
      {
        'label': 'Excel (.xlsx)',
        'icon': Icons.table_chart,
        'color': Colors.green,
        'format': 'xlsx'
      },
      {
        'label': 'PDF',
        'icon': Icons.picture_as_pdf,
        'color': Colors.red,
        'format': 'pdf'
      },
      {
        'label': 'CSV',
        'icon': Icons.grid_on,
        'color': Colors.blue,
        'format': 'csv'
      },
      {
        'label': 'JSON',
        'icon': Icons.code,
        'color': Colors.orange,
        'format': 'json'
      },
      {
        'label': 'TXT',
        'icon': Icons.text_snippet,
        'color': Colors.teal,
        'format': 'txt'
      },
      {
        'label': 'XML',
        'icon': Icons.data_object,
        'color': Colors.purple,
        'format': 'xml'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export Grades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Choose a format to export all student data',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: formats.map((f) {
              final color = f['color'] as Color;
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Exporting as ${f['label']}...'),
                      backgroundColor: color,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(f['icon'] as IconData, color: color, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        f['label'] as String,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
