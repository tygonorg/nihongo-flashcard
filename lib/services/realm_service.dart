import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/vocab.dart';
import '../models/review_log.dart';

class RealmService {
  Database? _db;
  bool _initialized = false;
  String? _initError;

  String? get initializationError => _initError;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _initError = null;

      // Tạo đường dẫn database
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'nihongo.db');

      // Khởi tạo SQLite database
      _db = await openDatabase(
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
    } catch (e, stackTrace) {
      _initError = e.toString();
      if (kDebugMode) {
        print('Failed to initialize SQLite: $e');
        print('Stack trace: $stackTrace');
      }
      _db = null;
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // Tạo bảng vocab
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

    // Tạo bảng review_logs
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

    // Tạo index
    await db.execute('CREATE INDEX idx_vocab_level ON vocabs (level)');
    await db.execute('CREATE INDEX idx_vocab_dueAt ON vocabs (dueAt)');
    await db.execute('CREATE INDEX idx_vocab_updatedAt ON vocabs (updatedAt)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
  }

  bool get isInitialized => _initialized;

  Future<List<Vocab>> allVocabs({String? level}) async {
    if (_db == null) return [];

    final List<Map<String, dynamic>> maps = await _db!.query(
      'vocabs',
      where: level != null ? 'level = ?' : null,
      whereArgs: level != null ? [level] : null,
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Vocab.fromMap(maps[i]);
    });
  }

  Future<Vocab?> addVocab({
    required String term,
    required String meaning,
    required String level,
    String? note,
  }) async {
    if (_db == null) return null;

    final now = DateTime.now();
    final vocab = Vocab(
      term: term,
      meaning: meaning,
      level: level,
      note: note,
      createdAt: now,
      updatedAt: now,
    );

    final id = await _db!.insert('vocabs', vocab.toMap());
    vocab.id = id;
    return vocab;
  }

  Future<void> updateVocab(
    Vocab vocab, {
    String? term,
    String? meaning,
    String? level,
    String? note,
    bool? favorite,
  }) async {
    if (_db == null || vocab.id == null) return;

    if (term != null) vocab.term = term;
    if (meaning != null) vocab.meaning = meaning;
    if (level != null) vocab.level = level;
    if (note != null) vocab.note = note;
    if (favorite != null) vocab.favorite = favorite;
    vocab.updatedAt = DateTime.now();

    await _db!.update(
      'vocabs',
      vocab.toMap(),
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  Future<void> deleteVocab(Vocab vocab) async {
    if (_db == null || vocab.id == null) return;

    await _db!.delete(
      'vocabs',
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  Future<void> upsertReviewLog({
    required Vocab vocab,
    required int grade,
    required int nextInterval,
  }) async {
    if (_db == null || vocab.id == null) return;

    final log = ReviewLog(
      vocabId: vocab.id!,
      reviewedAt: DateTime.now(),
      grade: grade,
      intervalAfter: nextInterval,
    );

    await _db!.insert('review_logs', log.toMap());
  }

  Future<List<Vocab>> dueVocabs({int limit = 50, String? level}) async {
    if (_db == null) return [];

    final now = DateTime.now().millisecondsSinceEpoch;
    String sql = 'SELECT * FROM vocabs WHERE (dueAt IS NULL OR dueAt <= ?)';
    List args = [now];

    if (level != null) {
      sql += ' AND level = ?';
      args.add(level);
    }

    sql += ' ORDER BY dueAt ASC LIMIT ?';
    args.add(limit);

    final List<Map<String, dynamic>> maps = await _db!.rawQuery(sql, args);

    return List.generate(maps.length, (i) {
      return Vocab.fromMap(maps[i]);
    });
  }

  // Stream methods for reactive UI (simplified)
  Stream<List<Vocab>> watchVocabs({String? level}) async* {
    while (_initialized) {
      yield await allVocabs(level: level);
      await Future.delayed(const Duration(seconds: 1)); // Simple polling
    }
  }
}
