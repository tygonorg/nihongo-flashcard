import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/vocab.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;
  bool _initialized = false;
  String? _initError;

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

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_vocab_level ON vocabs (level)');
    await db.execute('CREATE INDEX idx_vocab_dueAt ON vocabs (dueAt)');
    await db.execute('CREATE INDEX idx_vocab_updatedAt ON vocabs (updatedAt)');
    await db.execute('CREATE INDEX idx_vocab_favorite ON vocabs (favorite)');
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

  // Review Log Operations

  /// Add a review log entry
  Future<void> addReviewLog({
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
  }

  /// Export all data as JSON-compatible map
  Future<Map<String, dynamic>> exportData() async {
    final vocabs = await getAllVocabs();
    return {
      'vocabs': vocabs.map((v) => v.toMap()).toList(),
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
      
      // Import vocabs
      if (data['vocabs'] != null) {
        for (final vocabMap in data['vocabs']) {
          await txn.insert('vocabs', vocabMap);
        }
      }
    });
  }
}
