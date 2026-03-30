import '../constants/app_constants.dart';

class GradeUtils {
  GradeUtils._();

  // Get grade entry for a score
  static Map<String, dynamic> _gradeEntry(double score) =>
      AppConstants.gradeScale.firstWhere(
        (g) => score >= (g['min'] as double),
        orElse: () => AppConstants.gradeScale.last,
      );

  // Letter grade from score
  static String letterGrade(double score) =>
      _gradeEntry(score)['label'] as String;

  // GPA points from score
  static double gpaPoints(double score) =>
      (_gradeEntry(score)['gpa'] as num).toDouble();

  // Average GPA from list of scores
  static double averageGpa(List<double> scores) => scores.isEmpty
      ? 0.0
      : scores.map(gpaPoints).reduce((a, b) => a + b) / scores.length;

  // Average score from list
  static double average(List<double> scores) =>
      scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;

  // Highest score
  static double highest(List<double> scores) =>
      scores.isEmpty ? 0.0 : scores.reduce((a, b) => a > b ? a : b);

  // Lowest score
  static double lowest(List<double> scores) =>
      scores.isEmpty ? 0.0 : scores.reduce((a, b) => a < b ? a : b);

  // Passing check
  static bool isPassing(List<double> scores) =>
      average(scores) >= AppConstants.passingScore;

  // Format score
  static String formatScore(double score) => score.toStringAsFixed(2);

  // Format GPA
  static String formatGpa(double gpa) => gpa.toStringAsFixed(2);

  // Grade distribution from list of averages
  static Map<String, int> gradeDistribution(List<double> averages) {
    final Map<String, int> dist = {
      'A': 0,
      'B+': 0,
      'B': 0,
      'C+': 0,
      'C': 0,
      'D+': 0,
      'D': 0,
      'F': 0
    };
    for (final score in averages) {
      final label = letterGrade(score);
      dist[label] = (dist[label] ?? 0) + 1;
    }
    return dist;
  }

  // Class average
  static double classAverage(List<double> averages) => average(averages);
}
