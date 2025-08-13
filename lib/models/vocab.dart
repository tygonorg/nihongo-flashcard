class Vocab {
  int? id;
  String term;
  String hiragana;
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
    required this.hiragana,
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
      'hiragana': hiragana,
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
      hiragana: map['hiragana'],
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

  /// Create a copy of this Vocab with specified fields replaced
  Vocab copyWith({
    int? id,
    String? term,
    String? hiragana,
    String? meaning,
    String? level,
    String? note,
    double? easiness,
    int? repetitions,
    int? intervalDays,
    DateTime? lastReviewedAt,
    DateTime? dueAt,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vocab(
      id: id ?? this.id,
      term: term ?? this.term,
      hiragana: hiragana ?? this.hiragana,
      meaning: meaning ?? this.meaning,
      level: level ?? this.level,
      note: note ?? this.note,
      easiness: easiness ?? this.easiness,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      dueAt: dueAt ?? this.dueAt,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vocab &&
        other.id == id &&
        other.term == term &&
        other.hiragana == hiragana &&
        other.meaning == meaning &&
        other.level == level &&
        other.note == note &&
        other.easiness == easiness &&
        other.repetitions == repetitions &&
        other.intervalDays == intervalDays &&
        other.lastReviewedAt == lastReviewedAt &&
        other.dueAt == dueAt &&
        other.favorite == favorite &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      term,
      hiragana,
      meaning,
      level,
      note,
      easiness,
      repetitions,
      intervalDays,
      lastReviewedAt,
      dueAt,
      favorite,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vocab{' 'id: $id, term: $term, hiragana: $hiragana, meaning: $meaning, level: $level, note: $note, ' 'easiness: $easiness, repetitions: $repetitions, intervalDays: $intervalDays, lastReviewedAt: $lastReviewedAt, ' 'dueAt: $dueAt, favorite: $favorite, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
