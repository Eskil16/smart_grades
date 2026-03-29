import '../constants/app_constants.dart';

// Pure functional grade utilities — no side effects, no state
class GradeUtils {
  GradeUtils._();

  // Compute letter grade from numeric score
  static String letterGrade(double score) => switch (score) {
        >= AppConstants.gradeA => AppConstants.labelA,
        >= AppConstants.gradeB => AppConstants.labelB,
        >= AppConstants.gradeC => AppConstants.labelC,
        >= AppConstants.gradeD => AppConstants.labelD,
        _ => AppConstants.labelF,
      };

  // Compute average from a list of scores
  static double average(List<double> scores) =>
      scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;

  // Compute highest score
  static double highest(List<double> scores) =>
      scores.isEmpty ? 0.0 : scores.reduce((a, b) => a > b ? a : b);

  // Compute lowest score
  static double lowest(List<double> scores) =>
      scores.isEmpty ? 0.0 : scores.reduce((a, b) => a < b ? a : b);

  // Check if student is passing (average >= 60)
  static bool isPassing(List<double> scores) =>
      average(scores) >= AppConstants.gradeD;

  // Format score to 2 decimal places
  static String formatScore(double score) => score.toStringAsFixed(2);

  // Grade color helper (returns color hex string)
  static String gradeColorHex(double score) => switch (score) {
        >= AppConstants.gradeA => '#4CAF50',
        >= AppConstants.gradeB => '#2196F3',
        >= AppConstants.gradeC => '#FF9800',
        >= AppConstants.gradeD => '#FF5722',
        _ => '#F44336',
      };

  // Count students per grade category
  static Map<String, int> gradeDistribution(List<double> averages) {
    return averages.fold({'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0},
        (map, score) {
      final grade = letterGrade(score);
      return {...map, grade: (map[grade] ?? 0) + 1};
    });
  }

  // Class average from list of student averages
  static double classAverage(List<double> averages) => average(averages);
}
