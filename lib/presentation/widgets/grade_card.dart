import 'package:flutter/material.dart';
import '../../data/models/grade_model.dart';
import '../../core/utils/grade_utils.dart';
import '../../core/theme/app_theme.dart';

class GradeCard extends StatelessWidget {
  final GradeModel grade;
  final VoidCallback? onDelete;

  const GradeCard({
    super.key,
    required this.grade,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final letter = GradeUtils.letterGrade(grade.finalScore);
    final color = AppTheme.gradeColor(letter);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — subject + grade badge
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grade.subject,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 11, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            '${grade.date.day}/${grade.date.month}/${grade.date.year}',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Final score badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        GradeUtils.formatScore(grade.finalScore),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Final',
                        style: TextStyle(
                            color: color.withOpacity(0.7), fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete grade',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // CC and SN breakdown
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  _scoreChip('CC (30%)', GradeUtils.formatScore(grade.ccScore),
                      Colors.blue),
                  const SizedBox(width: 8),
                  const Icon(Icons.add, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  _scoreChip('SN (70%)', GradeUtils.formatScore(grade.snScore),
                      Colors.indigo),
                  const Spacer(),
                  const Icon(Icons.drag_handle, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  _scoreChip(
                    'GPA',
                    GradeUtils.formatGpa(
                        GradeUtils.gpaPoints(grade.finalScore)),
                    color,
                  ),
                ],
              ),
            ),
            if (grade.comment != null && grade.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.comment_outlined,
                      size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      grade.comment!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _scoreChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 10),
        ),
      ],
    );
  }
}
