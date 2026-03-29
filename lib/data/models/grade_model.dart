class GradeModel {
  final String id;
  final String subject;
  final double score;
  final String? comment;
  final DateTime date;

  const GradeModel({
    required this.id,
    required this.subject,
    required this.score,
    this.comment,
    required this.date,
  });

  // Validate score is between 0 and 100
  static bool isValidScore(double score) => score >= 0 && score <= 100;

  // Copy with updated fields
  GradeModel copyWith({
    String? id,
    String? subject,
    double? score,
    String? comment,
    DateTime? date,
  }) =>
      GradeModel(
        id: id ?? this.id,
        subject: subject ?? this.subject,
        score: score ?? this.score,
        comment: comment ?? this.comment,
        date: date ?? this.date,
      );

  // Convert to Map (for export)
  Map<String, dynamic> toMap() => {
        'id': id,
        'subject': subject,
        'score': score,
        'comment': comment ?? '',
        'date': date.toIso8601String(),
      };

  // Create from Map
  factory GradeModel.fromMap(Map<String, dynamic> map) => GradeModel(
        id: map['id'] as String,
        subject: map['subject'] as String,
        score: (map['score'] as num).toDouble(),
        comment: map['comment'] as String?,
        date: DateTime.parse(map['date'] as String),
      );

  @override
  String toString() => 'GradeModel(subject: $subject, score: $score)';
}
