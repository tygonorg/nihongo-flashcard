class Kanji {
  int? id;
  String character;
  String onyomi;
  String kunyomi;
  String meaning;
  String hanviet;
  String level;

  /// SRS fields (SM-2)
  double easiness;
  int repetitions;
  int intervalDays;
  DateTime? lastReviewedAt;
  DateTime? dueAt;

  bool favorite;
  DateTime createdAt;
  DateTime updatedAt;

  Kanji({
    this.id,
    required this.character,
    required this.onyomi,
    required this.kunyomi,
    required this.meaning,
    required this.hanviet,
    required this.level,
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
      'character': character,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'meaning': meaning,
      'hanviet': hanviet,
      'level': level,
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

  factory Kanji.fromMap(Map<String, dynamic> map) {
    return Kanji(
      id: map['id'] as int?,
      character: map['character'] as String,
      onyomi: map['onyomi'] as String,
      kunyomi: map['kunyomi'] as String,
      meaning: map['meaning'] as String,
      hanviet: map['hanviet'] as String,
      level: map['level'] as String,
      easiness: (map['easiness'] as num?)?.toDouble() ?? 2.5,
      repetitions: map['repetitions'] as int? ?? 0,
      intervalDays: map['intervalDays'] as int? ?? 0,
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReviewedAt'] as int)
          : null,
      dueAt: map['dueAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueAt'] as int)
          : null,
      favorite: map['favorite'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Kanji copyWith({
    int? id,
    String? character,
    String? onyomi,
    String? kunyomi,
    String? meaning,
    String? hanviet,
    String? level,
    double? easiness,
    int? repetitions,
    int? intervalDays,
    DateTime? lastReviewedAt,
    DateTime? dueAt,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Kanji(
      id: id ?? this.id,
      character: character ?? this.character,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      meaning: meaning ?? this.meaning,
      hanviet: hanviet ?? this.hanviet,
      level: level ?? this.level,
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
    return other is Kanji &&
        other.id == id &&
        other.character == character &&
        other.onyomi == onyomi &&
        other.kunyomi == kunyomi &&
        other.meaning == meaning &&
        other.hanviet == hanviet &&
        other.level == level &&
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
      character,
      onyomi,
      kunyomi,
      meaning,
      hanviet,
      level,
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
    return 'Kanji{id: $id, character: $character, onyomi: $onyomi, kunyomi: $kunyomi, meaning: $meaning, hanviet: $hanviet, level: $level, easiness: $easiness, repetitions: $repetitions, intervalDays: $intervalDays, lastReviewedAt: $lastReviewedAt, dueAt: $dueAt, favorite: $favorite, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

class KanjiReviewLog {
  int? id;
  int kanjiId;
  DateTime reviewedAt;
  int grade;
  int intervalAfter;

  KanjiReviewLog({
    this.id,
    required this.kanjiId,
    required this.reviewedAt,
    required this.grade,
    required this.intervalAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kanjiId': kanjiId,
      'reviewedAt': reviewedAt.millisecondsSinceEpoch,
      'grade': grade,
      'intervalAfter': intervalAfter,
    };
  }

  factory KanjiReviewLog.fromMap(Map<String, dynamic> map) {
    return KanjiReviewLog(
      id: map['id'] as int?,
      kanjiId: map['kanjiId'] as int,
      reviewedAt: DateTime.fromMillisecondsSinceEpoch(map['reviewedAt'] as int),
      grade: map['grade'] as int,
      intervalAfter: map['intervalAfter'] as int,
    );
  }
}

