import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/vocab.dart';
import '../models/review_log.dart';
import '../models/kanji.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;
  bool _initialized = false;
  String? _initError;

  // Default constructor for testing and mocking
  DatabaseService();

  // Singleton pattern
  DatabaseService._internal();

  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  String? get initializationError => _initError;
  bool get isInitialized => _initialized;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    try {
      _initError = null;

      // Use path_provider for proper app documents directory
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'nihongo.db');

      // Initialize SQLite database
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );

      _initialized = true;

      if (kDebugMode) {
        print('SQLite initialized successfully');
        print('Database path: $path');
      }

      return db;
    } catch (e, stackTrace) {
      _initError = e.toString();
      if (kDebugMode) {
        print('Failed to initialize SQLite: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    await database; // This will trigger initialization
  }

  Future<void> _createTables(Database db, int version) async {
    // Create vocab table
    await db.execute('''
      CREATE TABLE vocabs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        term TEXT NOT NULL,
        meaning TEXT NOT NULL,
        level TEXT NOT NULL,
        note TEXT,
        easiness REAL NOT NULL DEFAULT 2.5,
        repetitions INTEGER NOT NULL DEFAULT 0,
        intervalDays INTEGER NOT NULL DEFAULT 0,
        lastReviewedAt INTEGER,
        dueAt INTEGER,
        favorite INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create review_logs table
    await db.execute('''
      CREATE TABLE review_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vocabId INTEGER NOT NULL,
        reviewedAt INTEGER NOT NULL,
        grade INTEGER NOT NULL,
        intervalAfter INTEGER NOT NULL,
        FOREIGN KEY (vocabId) REFERENCES vocabs (id) ON DELETE CASCADE
      )
    ''');

    // Create kanji table
    await db.execute('''
      CREATE TABLE kanjis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character TEXT NOT NULL,
        onyomi TEXT NOT NULL,
        kunyomi TEXT NOT NULL,
        meaning TEXT NOT NULL,
        hanviet TEXT NOT NULL,
        level TEXT NOT NULL,
        easiness REAL NOT NULL DEFAULT 2.5,
        repetitions INTEGER NOT NULL DEFAULT 0,
        intervalDays INTEGER NOT NULL DEFAULT 0,
        lastReviewedAt INTEGER,
        dueAt INTEGER,
        favorite INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create kanji_review_logs table
    await db.execute('''
      CREATE TABLE kanji_review_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kanjiId INTEGER NOT NULL,
        reviewedAt INTEGER NOT NULL,
        grade INTEGER NOT NULL,
        intervalAfter INTEGER NOT NULL,
        FOREIGN KEY (kanjiId) REFERENCES kanjis (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_vocab_level ON vocabs (level)');
    await db.execute('CREATE INDEX idx_vocab_dueAt ON vocabs (dueAt)');
    await db.execute('CREATE INDEX idx_vocab_updatedAt ON vocabs (updatedAt)');
    await db.execute('CREATE INDEX idx_vocab_favorite ON vocabs (favorite)');

    await db.execute('CREATE INDEX idx_kanji_level ON kanjis (level)');
    await db.execute('CREATE INDEX idx_kanji_dueAt ON kanjis (dueAt)');
    await db.execute('CREATE INDEX idx_kanji_updatedAt ON kanjis (updatedAt)');
    await db.execute('CREATE INDEX idx_kanji_favorite ON kanjis (favorite)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here if needed
    if (kDebugMode) {
      print('Upgrading database from version $oldVersion to $newVersion');
    }
  }

  // CRUD Operations for Vocab

  /// Get all vocabs, optionally filtered by level
  Future<List<Vocab>> getAllVocabs({String? level}) async {
    final db = await database;
    
    String sql = 'SELECT * FROM vocabs';
    List<dynamic> args = [];

    if (level != null) {
      sql += ' WHERE level = ?';
      args.add(level);
    }

    sql += ' ORDER BY updatedAt DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((map) => Vocab.fromMap(map)).toList();
  }

  /// Get vocabs that are due for review
  Future<List<Vocab>> getDueVocabs({int limit = 50, String? level}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    String sql = 'SELECT * FROM vocabs WHERE (dueAt IS NULL OR dueAt <= ?)';
    List<dynamic> args = [now];

    if (level != null) {
      sql += ' AND level = ?';
      args.add(level);
    }

    sql += ' ORDER BY dueAt ASC LIMIT ?';
    args.add(limit);

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((map) => Vocab.fromMap(map)).toList();
  }

  /// Get favorite vocabs
  Future<List<Vocab>> getFavoriteVocabs({String? level}) async {
    final db = await database;
    
    String sql = 'SELECT * FROM vocabs WHERE favorite = 1';
    List<dynamic> args = [];

    if (level != null) {
      sql += ' AND level = ?';
      args.add(level);
    }

    sql += ' ORDER BY updatedAt DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((map) => Vocab.fromMap(map)).toList();
  }

  /// Add a new vocab
  Future<Vocab> addVocab({
    required String term,
    required String meaning,
    required String level,
    String? note,
    bool favorite = false,
  }) async {
    final db = await database;
    final now = DateTime.now();
    
    final vocab = Vocab(
      term: term,
      meaning: meaning,
      level: level,
      note: note,
      favorite: favorite,
      createdAt: now,
      updatedAt: now,
    );

    final id = await db.insert('vocabs', vocab.toMap());
    vocab.id = id;
    return vocab;
  }

  /// Update an existing vocab
  Future<void> updateVocab(
    Vocab vocab, {
    String? term,
    String? meaning,
    String? level,
    String? note,
    bool? favorite,
  }) async {
    if (vocab.id == null) {
      throw ArgumentError('Cannot update vocab without an ID');
    }

    final db = await database;

    // Update only provided fields
    if (term != null) vocab.term = term;
    if (meaning != null) vocab.meaning = meaning;
    if (level != null) vocab.level = level;
    if (note != null) vocab.note = note;
    if (favorite != null) vocab.favorite = favorite;
    vocab.updatedAt = DateTime.now();

    await db.update(
      'vocabs',
      vocab.toMap(),
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  /// Update vocab SRS data (used by SrsService)
  Future<void> updateVocabSrsData(Vocab vocab) async {
    if (vocab.id == null) {
      throw ArgumentError('Cannot update vocab without an ID');
    }

    final db = await database;
    vocab.updatedAt = DateTime.now();

    await db.update(
      'vocabs',
      vocab.toMap(),
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  /// Delete a vocab
  Future<void> deleteVocab(Vocab vocab) async {
    if (vocab.id == null) {
      throw ArgumentError('Cannot delete vocab without an ID');
    }

    final db = await database;
    await db.delete(
      'vocabs',
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  /// Get vocab by ID
  Future<Vocab?> getVocabById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Vocab.fromMap(maps.first);
  }

  /// Search vocabs by term or meaning
  Future<List<Vocab>> searchVocabs(String query, {String? level}) async {
    final db = await database;
    
    String sql = '''
      SELECT * FROM vocabs 
      WHERE (term LIKE ? OR meaning LIKE ?)
    ''';
    List<dynamic> args = ['%$query%', '%$query%'];

    if (level != null) {
      sql += ' AND level = ?';
      args.add(level);
    }

    sql += ' ORDER BY updatedAt DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((map) => Vocab.fromMap(map)).toList();
  }

  // CRUD Operations for Kanji

  /// Get all kanji, optionally filtered by level
  Future<List<Kanji>> getAllKanjis({String? level}) async {
    final db = await database;

    String sql = 'SELECT * FROM kanjis';
    List<dynamic> args = [];

    if (level != null) {
      sql += ' WHERE level = ?';
      args.add(level);
    }

    sql += ' ORDER BY updatedAt DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((map) => Kanji.fromMap(map)).toList();
  }

  /// Get kanji that are due for review
  Future<List<Kanji>> getDueKanjis({int limit = 50, String? level}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    String sql = 'SELECT * FROM kanjis WHERE (dueAt IS NULL OR dueAt <= ?)';
    List<dynamic> args = [now];

    if (level != null) {
      sql += ' AND level = ?';
      args.add(level);
    }

    sql += ' ORDER BY dueAt ASC LIMIT ?';
    args.add(limit);

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return maps.map((map) => Kanji.fromMap(map)).toList();
  }

  /// Add a new kanji
  Future<Kanji> addKanji({
    required String character,
    required String onyomi,
    required String kunyomi,
    required String meaning,
    required String hanviet,
    required String level,
    bool favorite = false,
  }) async {
    final db = await database;
    final now = DateTime.now();

    final kanji = Kanji(
      character: character,
      onyomi: onyomi,
      kunyomi: kunyomi,
      meaning: meaning,
      hanviet: hanviet,
      level: level,
      favorite: favorite,
      createdAt: now,
      updatedAt: now,
    );

    final id = await db.insert('kanjis', kanji.toMap());
    kanji.id = id;
    return kanji;
  }

  /// Update an existing kanji
  Future<void> updateKanji(
    Kanji kanji, {
    String? character,
    String? onyomi,
    String? kunyomi,
    String? meaning,
    String? hanviet,
    String? level,
    bool? favorite,
  }) async {
    if (kanji.id == null) {
      throw ArgumentError('Cannot update kanji without an ID');
    }

    final db = await database;
    kanji
      ..character = character ?? kanji.character
      ..onyomi = onyomi ?? kanji.onyomi
      ..kunyomi = kunyomi ?? kanji.kunyomi
      ..meaning = meaning ?? kanji.meaning
      ..hanviet = hanviet ?? kanji.hanviet
      ..level = level ?? kanji.level
      ..favorite = favorite ?? kanji.favorite
      ..updatedAt = DateTime.now();

    await db.update(
      'kanjis',
      kanji.toMap(),
      where: 'id = ?',
      whereArgs: [kanji.id],
    );
  }

  /// Update kanji SRS data (used by SrsService)
  Future<void> updateKanjiSrsData(Kanji kanji) async {
    if (kanji.id == null) {
      throw ArgumentError('Cannot update kanji without an ID');
    }

    final db = await database;
    kanji.updatedAt = DateTime.now();

    await db.update(
      'kanjis',
      kanji.toMap(),
      where: 'id = ?',
      whereArgs: [kanji.id],
    );
  }

  /// Delete a kanji
  Future<void> deleteKanji(Kanji kanji) async {
    if (kanji.id == null) {
      throw ArgumentError('Cannot delete kanji without an ID');
    }

    final db = await database;
    await db.delete(
      'kanjis',
      where: 'id = ?',
      whereArgs: [kanji.id],
    );
  }

  /// Add a review log entry for kanji
  Future<void> addKanjiReviewLog({
    required Kanji kanji,
    required int grade,
    required int nextInterval,
    DateTime? reviewedAt,
  }) async {
    if (kanji.id == null) {
      throw ArgumentError('Cannot add review log for kanji without an ID');
    }

    final db = await database;
    final log = KanjiReviewLog(
      kanjiId: kanji.id!,
      reviewedAt: reviewedAt ?? DateTime.now(),
      grade: grade,
      intervalAfter: nextInterval,
    );

    await db.insert('kanji_review_logs', log.toMap());
  }

  // Review Log Operations

  /// Add a review log entry
  Future<void> addReviewLog({
    required Vocab vocab,
    required int grade,
    required int nextInterval,
    DateTime? reviewedAt,
  }) async {
    if (vocab.id == null) {
      throw ArgumentError('Cannot add review log for vocab without an ID');
    }

    final db = await database;
    final log = ReviewLog(
      vocabId: vocab.id!,
      reviewedAt: reviewedAt ?? DateTime.now(),
      grade: grade,
      intervalAfter: nextInterval,
    );

    await db.insert('review_logs', log.toMap());
  }

  /// Get review logs for a specific vocab
  Future<List<ReviewLog>> getReviewLogs(int vocabId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'review_logs',
      where: 'vocabId = ?',
      whereArgs: [vocabId],
      orderBy: 'reviewedAt DESC',
    );

    return maps.map((map) => ReviewLog.fromMap(map)).toList();
  }

  // Statistics and Analytics

  /// Get total count of vocabs
  Future<int> getTotalVocabCount({String? level}) async {
    final db = await database;
    
    String sql = 'SELECT COUNT(*) as count FROM vocabs';
    List<dynamic> args = [];

    if (level != null) {
      sql += ' WHERE level = ?';
      args.add(level);
    }

    final result = await db.rawQuery(sql, args);
    return result.first['count'] as int;
  }

  /// Get count of due vocabs
  Future<int> getDueVocabCount({String? level}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    String sql = 'SELECT COUNT(*) as count FROM vocabs WHERE (dueAt IS NULL OR dueAt <= ?)';
    List<dynamic> args = [now];

    if (level != null) {
      sql += ' AND level = ?';
      args.add(level);
    }

    final result = await db.rawQuery(sql, args);
    return result.first['count'] as int;
  }

  /// Get count of favorite vocabs
  Future<int> getFavoriteVocabCount({String? level}) async {
    final db = await database;
    
    String sql = 'SELECT COUNT(*) as count FROM vocabs WHERE favorite = 1';
    List<dynamic> args = [];

    if (level != null) {
      sql += ' AND level = ?';
      args.add(level);
    }

    final result = await db.rawQuery(sql, args);
    return result.first['count'] as int;
  }

  // Reactive Streams (simplified polling approach)

  /// Watch all vocabs with periodic updates
  Stream<List<Vocab>> watchAllVocabs({String? level}) async* {
    while (_initialized) {
      try {
        yield await getAllVocabs(level: level);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        if (kDebugMode) {
          print('Error in watchAllVocabs: $e');
        }
        await Future.delayed(const Duration(seconds: 5)); // Wait longer on error
      }
    }
  }

  /// Watch due vocabs with periodic updates
  Stream<List<Vocab>> watchDueVocabs({int limit = 50, String? level}) async* {
    while (_initialized) {
      try {
        yield await getDueVocabs(limit: limit, level: level);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        if (kDebugMode) {
          print('Error in watchDueVocabs: $e');
        }
        await Future.delayed(const Duration(seconds: 5)); // Wait longer on error
      }
    }
  }

  // Utility Methods

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _initialized = false;
    }
  }

  /// Clear all data (useful for testing or reset functionality)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('review_logs');
    await db.delete('vocabs');
    await db.delete('kanji_review_logs');
    await db.delete('kanjis');
  }

  /// Export all data as JSON-compatible map
  Future<Map<String, dynamic>> exportData() async {
    final vocabs = await getAllVocabs();
    final kanjis = await getAllKanjis();
    return {
      'vocabs': vocabs.map((v) => v.toMap()).toList(),
      'kanjis': kanjis.map((k) => k.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
    };
  }

  /// Import data from JSON-compatible map
  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;
    
    // Start transaction
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('review_logs');
      await txn.delete('vocabs');
      await txn.delete('kanji_review_logs');
      await txn.delete('kanjis');
      
      // Import vocabs
      if (data['vocabs'] != null) {
        for (final vocabMap in data['vocabs']) {
          await txn.insert('vocabs', vocabMap);
        }
      }

      if (data['kanjis'] != null) {
        for (final kanjiMap in data['kanjis']) {
          await txn.insert('kanjis', kanjiMap);
        }
      }
    });
  }

  /// Backup database to a file path
  Future<File> backupToFile(String path) async {
    final data = await exportData();
    final file = File(path);
    return file.writeAsString(jsonEncode(data));
  }

  /// Restore database from a backup file
  Future<void> restoreFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Backup file not found');
    }
    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    await importData(data);
  }

  /// Simulate cloud sync by writing backup to a fixed file
  Future<void> syncToCloud() async {
    final dir = await getApplicationDocumentsDirectory();
    final cloudPath = join(dir.path, 'cloud_backup.json');
    await backupToFile(cloudPath);
  }

  /// Get review counts for recent days
  Future<Map<String, int>> getDailyReviewCounts({int days = 7}) async {
    final db = await database;
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final startMillis = startDay.millisecondsSinceEpoch;
    final endMillis =
        DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final rows = await db.rawQuery(
        'SELECT reviewedAt FROM review_logs WHERE reviewedAt BETWEEN ? AND ?',
        [startMillis, endMillis]);

    final Map<String, int> counts = {};
    for (final row in rows) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(row['reviewedAt'] as int);
      final key = _dateKey(date);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    for (int i = 0; i < days; i++) {
      final d = startDay.add(Duration(days: i));
      counts.putIfAbsent(_dateKey(d), () => 0);
    }
    return counts;
  }

  /// Calculate current review streak (consecutive days with reviews)
  Future<int> getReviewStreak() async {
    final db = await database;
    final rows = await db
        .rawQuery('SELECT reviewedAt FROM review_logs ORDER BY reviewedAt DESC');
    final Set<String> daysWithReviews = rows
        .map((e) => _dateKey(
            DateTime.fromMillisecondsSinceEpoch(e['reviewedAt'] as int)))
        .toSet();
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final key = _dateKey(day);
      if (daysWithReviews.contains(key)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
