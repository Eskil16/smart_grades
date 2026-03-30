class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Grades';
  static const String appVersion = '1.0.0';

  // Grade scale (min score → label, GPA)
  static const List<Map<String, dynamic>> gradeScale = [
    {'min': 80.0, 'label': 'A', 'gpa': 4.0},
    {'min': 70.0, 'label': 'B+', 'gpa': 3.5},
    {'min': 60.0, 'label': 'B', 'gpa': 3.0},
    {'min': 55.0, 'label': 'C+', 'gpa': 2.5},
    {'min': 50.0, 'label': 'C', 'gpa': 2.0},
    {'min': 45.0, 'label': 'D+', 'gpa': 1.5},
    {'min': 40.0, 'label': 'D', 'gpa': 1.0},
    {'min': 0.0, 'label': 'F', 'gpa': 0.0},
  ];

  // Passing threshold
  static const double passingScore = 40.0;

  // Export file base name
  static const String exportBaseName = 'smart_grades_export';

  // Default subjects (lecturer can add more per session)
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
    'Statistics',
    'Algorithms',
    'Networking',
    'Database Systems',
    'Operating Systems',
  ];
}
