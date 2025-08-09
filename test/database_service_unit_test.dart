import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import '../lib/models/vocab.dart';
import '../lib/models/review_log.dart';

/// Unit test version of DatabaseService for testing CRUD operations
class DatabaseServiceTest {
  static Database? _database;
  
  /// Initialize sqflite_common_ffi for testing (avoiding file I/O)
  static void initializeFfi() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Get in-memory database instance for unit tests
  static Future<Database> get database async {
    if (_database != null) return _database!;
    
    initializeFfi();
    
    _database = await openDatabase(
      ':memory:', // In-memory database to avoid file I/O
      version: 1,
      onCreate: _createTables,
      onOpen: (Database db) async {
        // Enable foreign key constraints for cascade testing
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    
    return _database!;
  }

  /// Create database tables matching production schema
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

    // Create review_logs table with cascade delete
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

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_vocab_level ON vocabs (level)');
    await db.execute('CREATE INDEX idx_vocab_dueAt ON vocabs (dueAt)');
    await db.execute('CREATE INDEX idx_vocab_updatedAt ON vocabs (updatedAt)');
    await db.execute('CREATE INDEX idx_vocab_favorite ON vocabs (favorite)');
  }

  /// Reset database for clean test state
  static Future<void> reset() async {
    final db = await database;
    await db.delete('review_logs');
    await db.delete('vocabs');
  }

  /// Close database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // CRUD Operations

  /// Insert a new vocab
  static Future<Vocab> insertVocab({
    required String term,
    required String meaning,
    required String level,
    String? note,
    bool favorite = false,
    double easiness = 2.5,
    int repetitions = 0,
    int intervalDays = 0,
    DateTime? lastReviewedAt,
    DateTime? dueAt,
  }) async {
    final db = await database;
    final now = DateTime.now();
    
    final vocab = Vocab(
      term: term,
      meaning: meaning,
      level: level,
      note: note,
      favorite: favorite,
      easiness: easiness,
      repetitions: repetitions,
      intervalDays: intervalDays,
      lastReviewedAt: lastReviewedAt,
      dueAt: dueAt,
      createdAt: now,
      updatedAt: now,
    );

    final id = await db.insert('vocabs', vocab.toMap());
    vocab.id = id;
    return vocab;
  }

  /// Read vocab by ID
  static Future<Vocab?> readVocabById(int id) async {
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

  /// Read all vocabs
  static Future<List<Vocab>> readAllVocabs({String? level}) async {
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

  /// Update vocab
  static Future<int> updateVocab(Vocab vocab) async {
    if (vocab.id == null) {
      throw ArgumentError('Cannot update vocab without an ID');
    }

    final db = await database;
    vocab.updatedAt = DateTime.now();

    return await db.update(
      'vocabs',
      vocab.toMap(),
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  /// Delete vocab
  static Future<int> deleteVocab(int id) async {
    final db = await database;
    return await db.delete(
      'vocabs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Insert review log
  static Future<ReviewLog> insertReviewLog({
    required int vocabId,
    required int grade,
    required int intervalAfter,
    DateTime? reviewedAt,
  }) async {
    final db = await database;
    
    final log = ReviewLog(
      vocabId: vocabId,
      reviewedAt: reviewedAt ?? DateTime.now(),
      grade: grade,
      intervalAfter: intervalAfter,
    );

    final id = await db.insert('review_logs', log.toMap());
    log.id = id;
    return log;
  }

  /// Read review logs for a vocab
  static Future<List<ReviewLog>> readReviewLogs(int vocabId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'review_logs',
      where: 'vocabId = ?',
      whereArgs: [vocabId],
      orderBy: 'reviewedAt DESC',
    );

    return maps.map((map) => ReviewLog.fromMap(map)).toList();
  }

  /// Count vocabs
  static Future<int> countVocabs({String? level}) async {
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

  /// Count review logs
  static Future<int> countReviewLogs({int? vocabId}) async {
    final db = await database;
    
    String sql = 'SELECT COUNT(*) as count FROM review_logs';
    List<dynamic> args = [];

    if (vocabId != null) {
      sql += ' WHERE vocabId = ?';
      args.add(vocabId);
    }

    final result = await db.rawQuery(sql, args);
    return result.first['count'] as int;
  }
}

void main() {
  group('Database Service CRUD Unit Tests', () {
    setUp(() async {
      await DatabaseServiceTest.reset();
    });

    tearDown(() async {
      await DatabaseServiceTest.reset();
    });

    tearDownAll(() async {
      await DatabaseServiceTest.close();
    });

    group('Vocab Insert Operations', () {
      test('Should insert vocab with required fields only', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '犬',
          meaning: 'dog',
          level: 'N5',
        );

        expect(vocab.id, isNotNull);
        expect(vocab.term, '犬');
        expect(vocab.meaning, 'dog');
        expect(vocab.level, 'N5');
        expect(vocab.note, isNull);
        expect(vocab.favorite, false);
        expect(vocab.easiness, 2.5);
        expect(vocab.repetitions, 0);
        expect(vocab.intervalDays, 0);
        expect(vocab.createdAt, isA<DateTime>());
        expect(vocab.updatedAt, isA<DateTime>());
      });

      test('Should insert vocab with all fields', () async {
        final now = DateTime.now();
        final dueDate = now.add(const Duration(days: 1));
        
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '猫',
          meaning: 'cat',
          level: 'N5',
          note: 'Animal',
          favorite: true,
          easiness: 3.0,
          repetitions: 2,
          intervalDays: 3,
          lastReviewedAt: now,
          dueAt: dueDate,
        );

        expect(vocab.id, isNotNull);
        expect(vocab.term, '猫');
        expect(vocab.meaning, 'cat');
        expect(vocab.level, 'N5');
        expect(vocab.note, 'Animal');
        expect(vocab.favorite, true);
        expect(vocab.easiness, 3.0);
        expect(vocab.repetitions, 2);
        expect(vocab.intervalDays, 3);
        expect(vocab.lastReviewedAt, isNotNull);
        expect(vocab.dueAt, isNotNull);
      });

      test('Should auto-increment IDs correctly', () async {
        final vocab1 = await DatabaseServiceTest.insertVocab(
          term: 'first',
          meaning: 'first',
          level: 'N5',
        );

        final vocab2 = await DatabaseServiceTest.insertVocab(
          term: 'second',
          meaning: 'second',
          level: 'N5',
        );

        expect(vocab1.id, isA<int>());
        expect(vocab2.id, isA<int>());
        expect(vocab2.id! > vocab1.id!, true);
      });
    });

    group('Vocab Read Operations', () {
      test('Should read vocab by ID', () async {
        final insertedVocab = await DatabaseServiceTest.insertVocab(
          term: '水',
          meaning: 'water',
          level: 'N5',
        );

        final readVocab = await DatabaseServiceTest.readVocabById(insertedVocab.id!);

        expect(readVocab, isNotNull);
        expect(readVocab!.id, insertedVocab.id);
        expect(readVocab.term, '水');
        expect(readVocab.meaning, 'water');
        expect(readVocab.level, 'N5');
      });

      test('Should return null for non-existent vocab ID', () async {
        final readVocab = await DatabaseServiceTest.readVocabById(999);
        expect(readVocab, isNull);
      });

      test('Should read all vocabs', () async {
        await DatabaseServiceTest.insertVocab(term: '犬', meaning: 'dog', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '猫', meaning: 'cat', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '鳥', meaning: 'bird', level: 'N4');

        final allVocabs = await DatabaseServiceTest.readAllVocabs();

        expect(allVocabs.length, 3);
        final terms = allVocabs.map((v) => v.term).toSet();
        expect(terms.contains('犬'), true);
        expect(terms.contains('猫'), true);
        expect(terms.contains('鳥'), true);
      });

      test('Should read vocabs filtered by level', () async {
        await DatabaseServiceTest.insertVocab(term: '犬', meaning: 'dog', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '猫', meaning: 'cat', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '図書館', meaning: 'library', level: 'N4');

        final n5Vocabs = await DatabaseServiceTest.readAllVocabs(level: 'N5');
        final n4Vocabs = await DatabaseServiceTest.readAllVocabs(level: 'N4');

        expect(n5Vocabs.length, 2);
        expect(n4Vocabs.length, 1);
        expect(n4Vocabs.first.term, '図書館');
      });

      test('Should order vocabs by updatedAt DESC', () async {
        final vocab1 = await DatabaseServiceTest.insertVocab(
          term: 'first', meaning: 'first', level: 'N5');
        
        // Small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 10));
        
        final vocab2 = await DatabaseServiceTest.insertVocab(
          term: 'second', meaning: 'second', level: 'N5');

        final allVocabs = await DatabaseServiceTest.readAllVocabs();

        expect(allVocabs.length, 2);
        expect(allVocabs.first.id, vocab2.id); // Most recently updated first
        expect(allVocabs.last.id, vocab1.id);
      });
    });

    group('Vocab Search Operations', () {
      test('Should search by term', () async {
        await DatabaseServiceTest.insertVocab(term: '犬', meaning: 'dog', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '猫', meaning: 'cat', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '鳥', meaning: 'bird', level: 'N4');

        final results = await DatabaseServiceTest.searchVocabs('犬');

        expect(results.length, 1);
        expect(results.first.term, '犬');
      });

      test('Should search by meaning', () async {
        await DatabaseServiceTest.insertVocab(term: '犬', meaning: 'dog', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '猫', meaning: 'cat', level: 'N5');

        final results = await DatabaseServiceTest.searchVocabs('cat');

        expect(results.length, 1);
        expect(results.first.term, '猫');
      });

      test('Should search with partial matches', () async {
        await DatabaseServiceTest.insertVocab(term: '図書館', meaning: 'library', level: 'N4');
        await DatabaseServiceTest.insertVocab(term: '図書', meaning: 'book', level: 'N5');

        final results = await DatabaseServiceTest.searchVocabs('図');

        expect(results.length, 2);
        final terms = results.map((v) => v.term).toSet();
        expect(terms.contains('図書館'), true);
        expect(terms.contains('図書'), true);
      });

      test('Should search with level filter', () async {
        await DatabaseServiceTest.insertVocab(term: '水', meaning: 'water', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '海水', meaning: 'seawater', level: 'N3');

        final results = await DatabaseServiceTest.searchVocabs('水', level: 'N5');

        expect(results.length, 1);
        expect(results.first.term, '水');
      });

      test('Should return empty list for no matches', () async {
        await DatabaseServiceTest.insertVocab(term: '犬', meaning: 'dog', level: 'N5');

        final results = await DatabaseServiceTest.searchVocabs('xyz');

        expect(results.isEmpty, true);
      });

      test('Should handle special characters in search', () async {
        await DatabaseServiceTest.insertVocab(term: '100%', meaning: '100 percent', level: 'N5');

        final results = await DatabaseServiceTest.searchVocabs('100%');

        expect(results.length, 1);
        expect(results.first.term, '100%');
      });
    });

    group('Vocab Update Operations', () {
      test('Should update vocab successfully', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '犬',
          meaning: 'dog',
          level: 'N5',
        );

        final originalUpdatedAt = vocab.updatedAt;
        
        // Small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));

        vocab.meaning = 'puppy';
        vocab.note = 'Updated meaning';
        vocab.favorite = true;
        
        final updateCount = await DatabaseServiceTest.updateVocab(vocab);
        expect(updateCount, 1);

        final updatedVocab = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(updatedVocab, isNotNull);
        expect(updatedVocab!.meaning, 'puppy');
        expect(updatedVocab.note, 'Updated meaning');
        expect(updatedVocab.favorite, true);
        expect(updatedVocab.updatedAt.isAfter(originalUpdatedAt), true);
      });

      test('Should update SRS data', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '猫',
          meaning: 'cat',
          level: 'N5',
        );

        vocab.easiness = 2.8;
        vocab.repetitions = 3;
        vocab.intervalDays = 7;
        vocab.lastReviewedAt = DateTime.now();
        vocab.dueAt = DateTime.now().add(const Duration(days: 7));

        final updateCount = await DatabaseServiceTest.updateVocab(vocab);
        expect(updateCount, 1);

        final updatedVocab = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(updatedVocab!.easiness, 2.8);
        expect(updatedVocab.repetitions, 3);
        expect(updatedVocab.intervalDays, 7);
        expect(updatedVocab.lastReviewedAt, isNotNull);
        expect(updatedVocab.dueAt, isNotNull);
      });

      test('Should throw error when updating vocab without ID', () async {
        final vocab = Vocab(
          term: 'test',
          meaning: 'test',
          level: 'N5',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () => DatabaseServiceTest.updateVocab(vocab),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Should return 0 when updating non-existent vocab', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: 'test',
          meaning: 'test',
          level: 'N5',
        );

        // Delete the vocab first
        await DatabaseServiceTest.deleteVocab(vocab.id!);

        // Try to update the deleted vocab
        vocab.meaning = 'updated';
        final updateCount = await DatabaseServiceTest.updateVocab(vocab);
        expect(updateCount, 0);
      });
    });

    group('Vocab Delete Operations', () {
      test('Should delete vocab successfully', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '犬',
          meaning: 'dog',
          level: 'N5',
        );

        final deleteCount = await DatabaseServiceTest.deleteVocab(vocab.id!);
        expect(deleteCount, 1);

        final deletedVocab = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(deletedVocab, isNull);
      });

      test('Should return 0 when deleting non-existent vocab', () async {
        final deleteCount = await DatabaseServiceTest.deleteVocab(999);
        expect(deleteCount, 0);
      });
    });

    group('Review Log CRUD Operations', () {
      test('Should insert and read review log', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '犬',
          meaning: 'dog',
          level: 'N5',
        );

        final reviewLog = await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab.id!,
          grade: 4,
          intervalAfter: 3,
        );

        expect(reviewLog.id, isNotNull);
        expect(reviewLog.vocabId, vocab.id);
        expect(reviewLog.grade, 4);
        expect(reviewLog.intervalAfter, 3);
        expect(reviewLog.reviewedAt, isA<DateTime>());

        final logs = await DatabaseServiceTest.readReviewLogs(vocab.id!);
        expect(logs.length, 1);
        expect(logs.first.id, reviewLog.id);
      });

      test('Should insert multiple review logs for same vocab', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '猫',
          meaning: 'cat',
          level: 'N5',
        );

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab.id!,
          grade: 3,
          intervalAfter: 1,
        );

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab.id!,
          grade: 4,
          intervalAfter: 2,
        );

        final logs = await DatabaseServiceTest.readReviewLogs(vocab.id!);
        expect(logs.length, 2);

        final grades = logs.map((log) => log.grade).toSet();
        expect(grades.contains(3), true);
        expect(grades.contains(4), true);
      });

      test('Should order review logs by reviewedAt DESC', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '鳥',
          meaning: 'bird',
          level: 'N4',
        );

        final firstTime = DateTime.now().subtract(const Duration(hours: 1));
        final secondTime = DateTime.now();

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab.id!,
          grade: 3,
          intervalAfter: 1,
          reviewedAt: firstTime,
        );

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab.id!,
          grade: 4,
          intervalAfter: 2,
          reviewedAt: secondTime,
        );

        final logs = await DatabaseServiceTest.readReviewLogs(vocab.id!);
        expect(logs.length, 2);
        expect(logs.first.grade, 4); // Most recent first
        expect(logs.last.grade, 3);
      });
    });

    group('Cascade Delete Operations', () {
      test('Should delete review logs when vocab is deleted (cascade)', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '魚',
          meaning: 'fish',
          level: 'N5',
        );

        // Add review logs
        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab.id!,
          grade: 4,
          intervalAfter: 2,
        );

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab.id!,
          grade: 5,
          intervalAfter: 4,
        );

        // Verify logs exist
        var logs = await DatabaseServiceTest.readReviewLogs(vocab.id!);
        expect(logs.length, 2);

        // Delete vocab
        await DatabaseServiceTest.deleteVocab(vocab.id!);

        // Verify vocab is deleted
        final deletedVocab = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(deletedVocab, isNull);

        // Verify review logs are also deleted (cascade)
        logs = await DatabaseServiceTest.readReviewLogs(vocab.id!);
        expect(logs.length, 0);

        // Verify using count as well
        final logCount = await DatabaseServiceTest.countReviewLogs(vocabId: vocab.id!);
        expect(logCount, 0);
      });

      test('Should cascade delete multiple vocabs with their review logs', () async {
        final vocab1 = await DatabaseServiceTest.insertVocab(
          term: '山',
          meaning: 'mountain',
          level: 'N5',
        );

        final vocab2 = await DatabaseServiceTest.insertVocab(
          term: '川',
          meaning: 'river',
          level: 'N5',
        );

        // Add review logs for both vocabs
        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab1.id!,
          grade: 3,
          intervalAfter: 1,
        );

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab2.id!,
          grade: 4,
          intervalAfter: 2,
        );

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab2.id!,
          grade: 5,
          intervalAfter: 4,
        );

        // Verify initial state
        expect(await DatabaseServiceTest.countVocabs(), 2);
        expect(await DatabaseServiceTest.countReviewLogs(), 3);

        // Delete both vocabs
        await DatabaseServiceTest.deleteVocab(vocab1.id!);
        await DatabaseServiceTest.deleteVocab(vocab2.id!);

        // Verify all data is deleted
        expect(await DatabaseServiceTest.countVocabs(), 0);
        expect(await DatabaseServiceTest.countReviewLogs(), 0);
      });
    });

    group('Count Operations', () {
      test('Should count vocabs correctly', () async {
        expect(await DatabaseServiceTest.countVocabs(), 0);

        await DatabaseServiceTest.insertVocab(term: '犬', meaning: 'dog', level: 'N5');
        expect(await DatabaseServiceTest.countVocabs(), 1);

        await DatabaseServiceTest.insertVocab(term: '猫', meaning: 'cat', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '図書館', meaning: 'library', level: 'N4');
        expect(await DatabaseServiceTest.countVocabs(), 3);
      });

      test('Should count vocabs by level', () async {
        await DatabaseServiceTest.insertVocab(term: '犬', meaning: 'dog', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '猫', meaning: 'cat', level: 'N5');
        await DatabaseServiceTest.insertVocab(term: '図書館', meaning: 'library', level: 'N4');

        expect(await DatabaseServiceTest.countVocabs(level: 'N5'), 2);
        expect(await DatabaseServiceTest.countVocabs(level: 'N4'), 1);
        expect(await DatabaseServiceTest.countVocabs(level: 'N3'), 0);
      });

      test('Should count review logs correctly', () async {
        final vocab1 = await DatabaseServiceTest.insertVocab(
          term: '犬', meaning: 'dog', level: 'N5');
        final vocab2 = await DatabaseServiceTest.insertVocab(
          term: '猫', meaning: 'cat', level: 'N5');

        expect(await DatabaseServiceTest.countReviewLogs(), 0);

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab1.id!, grade: 3, intervalAfter: 1);
        expect(await DatabaseServiceTest.countReviewLogs(), 1);

        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab1.id!, grade: 4, intervalAfter: 2);
        await DatabaseServiceTest.insertReviewLog(
          vocabId: vocab2.id!, grade: 5, intervalAfter: 3);
        expect(await DatabaseServiceTest.countReviewLogs(), 3);

        expect(await DatabaseServiceTest.countReviewLogs(vocabId: vocab1.id!), 2);
        expect(await DatabaseServiceTest.countReviewLogs(vocabId: vocab2.id!), 1);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('Should handle empty strings properly', () async {
        // Empty strings should be allowed as they might be filtered at service layer
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '',
          meaning: '',
          level: 'N5',
        );

        expect(vocab.id, isNotNull);
        expect(vocab.term, '');
        expect(vocab.meaning, '');
      });

      test('Should handle special characters in data', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '100%の人',
          meaning: 'Güter & Bäder',
          level: 'N5',
          note: "It's a test with 'quotes' and \"double quotes\"",
        );

        final retrieved = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(retrieved!.term, '100%の人');
        expect(retrieved.meaning, 'Güter & Bäder');
        expect(retrieved.note, "It's a test with 'quotes' and \"double quotes\"");
      });

      test('Should handle large text data', () async {
        final largeTerm = 'A' * 1000;
        final largeMeaning = 'B' * 1000;
        final largeNote = 'C' * 5000;

        final vocab = await DatabaseServiceTest.insertVocab(
          term: largeTerm,
          meaning: largeMeaning,
          level: 'N5',
          note: largeNote,
        );

        final retrieved = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(retrieved!.term, largeTerm);
        expect(retrieved.meaning, largeMeaning);
        expect(retrieved.note, largeNote);
      });

      test('Should handle extreme date values', () async {
        final minDate = DateTime.fromMillisecondsSinceEpoch(0);
        final maxDate = DateTime.fromMillisecondsSinceEpoch(8640000000000000); // Max JS date

        final vocab = await DatabaseServiceTest.insertVocab(
          term: 'test',
          meaning: 'test',
          level: 'N5',
          lastReviewedAt: minDate,
          dueAt: maxDate,
        );

        final retrieved = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(retrieved!.lastReviewedAt!.millisecondsSinceEpoch, 0);
        expect(retrieved.dueAt!.millisecondsSinceEpoch, 8640000000000000);
      });

      test('Should handle null optional fields correctly', () async {
        final vocab = await DatabaseServiceTest.insertVocab(
          term: '水',
          meaning: 'water',
          level: 'N5',
          note: null, // Explicitly null
          lastReviewedAt: null,
          dueAt: null,
        );

        final retrieved = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(retrieved!.note, isNull);
        expect(retrieved.lastReviewedAt, isNull);
        expect(retrieved.dueAt, isNull);
      });
    });

    group('Concurrent Operations', () {
      test('Should handle concurrent inserts', () async {
        final futures = <Future<Vocab>>[];

        // Create 10 concurrent insert operations
        for (int i = 0; i < 10; i++) {
          futures.add(DatabaseServiceTest.insertVocab(
            term: '単語$i',
            meaning: 'word$i',
            level: 'N${(i % 5) + 1}',
          ));
        }

        final vocabs = await Future.wait(futures);

        // Verify all vocabs were inserted
        expect(vocabs.length, 10);
        final ids = vocabs.map((v) => v.id).toSet();
        expect(ids.length, 10); // All should have unique IDs

        // Verify total count
        expect(await DatabaseServiceTest.countVocabs(), 10);
      });

      test('Should handle concurrent updates', () async {
        // Create a vocab first
        final vocab = await DatabaseServiceTest.insertVocab(
          term: 'test',
          meaning: 'test',
          level: 'N5',
        );

        final futures = <Future<int>>[];

        // Create 5 concurrent update operations
        for (int i = 0; i < 5; i++) {
          final vocabCopy = Vocab(
            id: vocab.id,
            term: vocab.term,
            meaning: 'updated$i',
            level: vocab.level,
            note: vocab.note,
            favorite: vocab.favorite,
            easiness: vocab.easiness,
            repetitions: vocab.repetitions,
            intervalDays: vocab.intervalDays,
            lastReviewedAt: vocab.lastReviewedAt,
            dueAt: vocab.dueAt,
            createdAt: vocab.createdAt,
            updatedAt: vocab.updatedAt,
          );
          futures.add(DatabaseServiceTest.updateVocab(vocabCopy));
        }

        final updateCounts = await Future.wait(futures);

        // All updates should succeed (return 1)
        expect(updateCounts.every((count) => count == 1), true);

        // Verify the vocab still exists and has been updated
        final finalVocab = await DatabaseServiceTest.readVocabById(vocab.id!);
        expect(finalVocab, isNotNull);
        expect(finalVocab!.meaning.startsWith('updated'), true);
      });
    });
  });
}
