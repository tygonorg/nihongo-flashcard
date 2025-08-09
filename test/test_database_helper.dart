import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import '../lib/models/vocab.dart';

class TestDatabaseHelper {
  static Database? _database;

  /// Initialize sqflite_common_ffi for testing
  static void initializeFfiDb() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Get an in-memory database instance for testing
  static Future<Database> getInMemoryDatabase() async {
    initializeFfiDb();
    
    final db = await openDatabase(
      ':memory:',
      version: 1,
      onCreate: _createTables,
      onOpen: (Database db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    
    return db;
  }

  /// Create database tables (matching the production schema)
  static Future<void> _createTables(Database db, int version) async {
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

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_vocab_level ON vocabs (level)');
    await db.execute('CREATE INDEX idx_vocab_dueAt ON vocabs (dueAt)');
    await db.execute('CREATE INDEX idx_vocab_updatedAt ON vocabs (updatedAt)');
    await db.execute('CREATE INDEX idx_vocab_favorite ON vocabs (favorite)');
  }

  /// Reset database (clear all data)
  static Future<void> resetDatabase(Database db) async {
    await db.delete('review_logs');
    await db.delete('vocabs');
  }
}

/// Test version of DatabaseService that uses in-memory SQLite
class TestDatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await TestDatabaseHelper.getInMemoryDatabase();
    return _database!;
  }

  /// Initialize for testing (no-op since we use in-memory)
  static Future<void> initialize() async {
    await database; // Just ensure database is created
  }

  /// Reset test data
  static Future<void> reset() async {
    final db = await database;
    await TestDatabaseHelper.resetDatabase(db);
  }

  /// Close test database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // CRUD Operations for Vocab (matching production DatabaseService)

  /// Add a new vocab
  static Future<Vocab> addVocab({
    required String term,
    required String meaning,
    required String level,
    String? note,
    bool favorite = false,
  }) async {
    // Validate required fields
    if (term.trim().isEmpty || meaning.trim().isEmpty) {
      throw Exception('Term and meaning cannot be empty');
    }

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

  /// Get all vocabs, optionally filtered by level
  static Future<List<Vocab>> getAllVocabs({String? level}) async {
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
  static Future<List<Vocab>> getDueVocabs({int limit = 50, String? level}) async {
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
  static Future<List<Vocab>> getFavoriteVocabs({String? level}) async {
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

  /// Update an existing vocab
  static Future<void> updateVocab(
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

  /// Delete a vocab
  static Future<void> deleteVocab(Vocab vocab) async {
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
  static Future<Vocab?> getVocabById(int id) async {
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
  static Future<List<Vocab>> searchVocabs(String query, {String? level}) async {
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

  /// Get total count of vocabs
  static Future<int> getTotalVocabCount({String? level}) async {
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
  static Future<int> getDueVocabCount({String? level}) async {
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
  static Future<int> getFavoriteVocabCount({String? level}) async {
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

  /// Update vocab SRS data (used by SrsService)
  static Future<void> updateVocabSrsData(Vocab vocab) async {
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

  /// Add a review log entry
  static Future<void> addReviewLog({
    required Vocab vocab,
    required int grade,
    required int nextInterval,
  }) async {
    if (vocab.id == null) {
      throw ArgumentError('Cannot add review log for vocab without an ID');
    }

    final db = await database;
    final log = ReviewLog(
      vocabId: vocab.id!,
      reviewedAt: DateTime.now(),
      grade: grade,
      intervalAfter: nextInterval,
    );

    await db.insert('review_logs', log.toMap());
  }

  /// Get review logs for a specific vocab
  static Future<List<ReviewLog>> getReviewLogs(int vocabId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'review_logs',
      where: 'vocabId = ?',
      whereArgs: [vocabId],
      orderBy: 'reviewedAt DESC',
    );

    return maps.map((map) => ReviewLog.fromMap(map)).toList();
  }

  /// Clear all data
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('review_logs');
    await db.delete('vocabs');
  }
}
