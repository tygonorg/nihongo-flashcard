class ReviewLog {
  int? id;
  int vocabId;
  DateTime reviewedAt;
  int grade; // 0-5 theo SM-2
  int intervalAfter;

  ReviewLog({
    this.id,
    required this.vocabId,
    required this.reviewedAt,
    required this.grade,
    required this.intervalAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vocabId': vocabId,
      'reviewedAt': reviewedAt.millisecondsSinceEpoch,
      'grade': grade,
      'intervalAfter': intervalAfter,
    };
  }

  factory ReviewLog.fromMap(Map<String, dynamic> map) {
    return ReviewLog(
      id: map['id'],
      vocabId: map['vocabId'],
      reviewedAt: DateTime.fromMillisecondsSinceEpoch(map['reviewedAt']),
      grade: map['grade'],
      intervalAfter: map['intervalAfter'],
    );
  }

  /// Create a copy of this ReviewLog with specified fields replaced
  ReviewLog copyWith({
    int? id,
    int? vocabId,
    DateTime? reviewedAt,
    int? grade,
    int? intervalAfter,
  }) {
    return ReviewLog(
      id: id ?? this.id,
      vocabId: vocabId ?? this.vocabId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      grade: grade ?? this.grade,
      intervalAfter: intervalAfter ?? this.intervalAfter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewLog &&
        other.id == id &&
        other.vocabId == vocabId &&
        other.reviewedAt == reviewedAt &&
        other.grade == grade &&
        other.intervalAfter == intervalAfter;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      vocabId,
      reviewedAt,
      grade,
      intervalAfter,
    );
  }

  @override
  String toString() {
    return 'ReviewLog{id: $id, vocabId: $vocabId, reviewedAt: $reviewedAt, grade: $grade, intervalAfter: $intervalAfter}';
  }
}
