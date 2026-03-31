class GradeModel {
  final String id;
  final String subject;
  final double ccScore;
  final double snScore;
  final String? comment;
  final DateTime date;

  const GradeModel({
    required this.id,
    required this.subject,
    required this.ccScore,
    required this.snScore,
    this.comment,
    required this.date,
  });

  // Final score = CC 30% + SN 70%
  double get finalScore => (ccScore * 0.3) + (snScore * 0.7);

  // Validate score between 0 and 100
  static bool isValidScore(double score) => score >= 0 && score <= 100;

  // Copy with updated fields
  GradeModel copyWith({
    String? id,
    String? subject,
    double? ccScore,
    double? snScore,
    String? comment,
    DateTime? date,
  }) =>
      GradeModel(
        id: id ?? this.id,
        subject: subject ?? this.subject,
        ccScore: ccScore ?? this.ccScore,
        snScore: snScore ?? this.snScore,
        comment: comment ?? this.comment,
        date: date ?? this.date,
      );

  // Convert to Map
  Map<String, dynamic> toMap() => {
        'id': id,
        'subject': subject,
        'ccScore': ccScore,
        'snScore': snScore,
        'finalScore': finalScore,
        'comment': comment ?? '',
        'date': date.toIso8601String(),
      };

  // Create from Map
  factory GradeModel.fromMap(Map<String, dynamic> map) => GradeModel(
        id: map['id'] as String,
        subject: map['subject'] as String,
        ccScore: (map['ccScore'] as num).toDouble(),
        snScore: (map['snScore'] as num).toDouble(),
        comment: map['comment'] as String?,
        date: DateTime.parse(map['date'] as String),
      );

  @override
  String toString() =>
      'GradeModel(subject: $subject, CC: $ccScore, SN: $snScore, Final: $finalScore)';
}
