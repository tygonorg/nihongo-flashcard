class Grammar {
  final String title;
  final String meaning;
  final String level;
  final String? example;

  Grammar({
    required this.title,
    required this.meaning,
    required this.level,
    this.example,
  });

  factory Grammar.fromMap(Map<String, dynamic> map) {
    return Grammar(
      title: map['title'] as String,
      meaning: map['meaning'] as String,
      level: map['level'] as String,
      example: map['example'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'meaning': meaning,
      'level': level,
      if (example != null) 'example': example,
    };
  }
}
