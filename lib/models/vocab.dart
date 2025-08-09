class Vocab {
  int? id;
  String term;
  String meaning;
  String level;
  String? note;
  
  /// Trường cho SRS (SM-2 rút gọn)
  double easiness;
  int repetitions;
  int intervalDays;
  DateTime? lastReviewedAt;
  DateTime? dueAt;
  
  /// Dùng cho flashcard tuỳ biến
  bool favorite;
  
  /// Thời điểm tạo/cập nhật  
  DateTime createdAt;
  DateTime updatedAt;

  Vocab({
    this.id,
    required this.term,
    required this.meaning,
    required this.level,
    this.note,
    this.easiness = 2.5,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.lastReviewedAt,
    this.dueAt,
    this.favorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'term': term,
      'meaning': meaning,
      'level': level,
      'note': note,
      'easiness': easiness,
      'repetitions': repetitions,
      'intervalDays': intervalDays,
      'lastReviewedAt': lastReviewedAt?.millisecondsSinceEpoch,
      'dueAt': dueAt?.millisecondsSinceEpoch,
      'favorite': favorite ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Vocab.fromMap(Map<String, dynamic> map) {
    return Vocab(
      id: map['id'],
      term: map['term'],
      meaning: map['meaning'],
      level: map['level'],
      note: map['note'],
      easiness: map['easiness'] ?? 2.5,
      repetitions: map['repetitions'] ?? 0,
      intervalDays: map['intervalDays'] ?? 0,
      lastReviewedAt: map['lastReviewedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReviewedAt']) 
          : null,
      dueAt: map['dueAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueAt']) 
          : null,
      favorite: map['favorite'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}

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
}
