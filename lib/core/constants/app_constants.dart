class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Grades';
  static const String appVersion = '1.0.0';

  // Grade thresholds
  static const double gradeA = 90.0;
  static const double gradeB = 80.0;
  static const double gradeC = 70.0;
  static const double gradeD = 60.0;

  // Grade labels
  static const String labelA = 'A';
  static const String labelB = 'B';
  static const String labelC = 'C';
  static const String labelD = 'D';
  static const String labelF = 'F';

  // Export file names
  static const String exportBaseName = 'smart_grades_export';

  // Subjects list
  static const List<String> defaultSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English',
    'French',
    'History',
    'Geography',
    'Philosophy',
  ];
}
