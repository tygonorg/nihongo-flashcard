import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/vocab.dart';
import 'database_service.dart';

class MigrationService {
  static const String _oldDatabaseName = 'nihongo.db';
  static const String _backupSuffix = '_backup';
  
  /// Check if migration is needed by looking for old database structure
  static Future<bool> needsMigration() async {
    try {
      // Check if there's an existing database with the old structure
      final databasesPath = await getDatabasesPath();
      final oldPath = join(databasesPath, _oldDatabaseName);
      
      if (!await File(oldPath).exists()) {
        return false; // No old database exists
      }
      
      // Check if the database has old RealmService structure
      final db = await openDatabase(oldPath, readOnly: true);
      
      try {
        // Try to query tables to determine structure
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
        );
        
        // Check if we have the expected tables with correct structure
        bool hasVocabTable = tables.any((table) => table['name'] == 'vocabs');
        bool hasReviewLogsTable = tables.any((table) => table['name'] == 'review_logs');
        
        if (hasVocabTable && hasReviewLogsTable) {
          // Check if the structure matches our current schema
          final vocabColumns = await db.rawQuery('PRAGMA table_info(vocabs)');
          final expectedColumns = {
            'id', 'term', 'meaning', 'level', 'note', 'easiness', 
            'repetitions', 'intervalDays', 'lastReviewedAt', 'dueAt', 
            'favorite', 'createdAt', 'updatedAt'
          };
          
          final actualColumns = vocabColumns
              .map((col) => col['name'] as String)
              .toSet();
          
          // If we're missing expected columns or have extra ones, migration might be needed
          final missingColumns = expectedColumns.difference(actualColumns);
          if (missingColumns.isNotEmpty) {
            if (kDebugMode) {
              print('Migration needed: missing columns: $missingColumns');
            }
            return true;
          }
        }
        
        return false; // Database structure looks correct
      } finally {
        await db.close();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking migration need: $e');
      }
      return false; // Assume no migration needed if we can't check
    }
  }
  
  /// Perform migration from old database structure to new one
  static Future<MigrationResult> migrate() async {
    try {
      if (kDebugMode) {
        print('Starting database migration...');
      }
      
      final migrationNeeded = await needsMigration();
      if (!migrationNeeded) {
        return MigrationResult.success('No migration needed');
      }
      
      // Backup existing database
      final backupResult = await _backupDatabase();
      if (!backupResult.success) {
        return MigrationResult.error('Failed to backup database: ${backupResult.message}');
      }
      
      // Read data from old database structure
      final oldData = await _readOldDatabaseData();
      if (oldData.isEmpty) {
        return MigrationResult.success('No data to migrate');
      }
      
      // Initialize new database service
      final dbService = DatabaseService.instance;
      await dbService.initialize();
      
      // Clear existing data to ensure clean migration
      await dbService.clearAllData();
      
      // Migrate data
      int migratedCount = 0;
      for (final vocabData in oldData) {
        try {
          await _migrateVocabRecord(dbService, vocabData);
          migratedCount++;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to migrate vocab record: $e');
          }
          // Continue with other records
        }
      }
      
      if (kDebugMode) {
        print('Migration completed: $migratedCount records migrated');
      }
      
      return MigrationResult.success(
        'Successfully migrated $migratedCount vocabulary records'
      );
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Migration failed: $e');
        print('Stack trace: $stackTrace');
      }
      return MigrationResult.error('Migration failed: $e');
    }
  }
  
  /// Backup the existing database
  static Future<MigrationResult> _backupDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final oldPath = join(databasesPath, _oldDatabaseName);
      final backupPath = join(databasesPath, '$_oldDatabaseName$_backupSuffix');
      
      if (await File(oldPath).exists()) {
        await File(oldPath).copy(backupPath);
        if (kDebugMode) {
          print('Database backed up to: $backupPath');
        }
      }
      
      return MigrationResult.success('Database backed up successfully');
    } catch (e) {
      return MigrationResult.error('Failed to backup database: $e');
    }
  }
  
  /// Read data from old database structure
  static Future<List<Map<String, dynamic>>> _readOldDatabaseData() async {
    final databasesPath = await getDatabasesPath();
    final oldPath = join(databasesPath, _oldDatabaseName);
    
    if (!await File(oldPath).exists()) {
      return [];
    }
    
    final db = await openDatabase(oldPath, readOnly: true);
    
    try {
      // Read all vocab records
      final vocabs = await db.query('vocabs', orderBy: 'id ASC');
      
      if (kDebugMode) {
        print('Found ${vocabs.length} vocab records to migrate');
      }
      
      return vocabs;
    } finally {
      await db.close();
    }
  }
  
  /// Migrate a single vocab record to new structure
  static Future<void> _migrateVocabRecord(
    DatabaseService dbService, 
    Map<String, dynamic> oldData
  ) async {
    try {
      // Ensure required fields exist and have proper types
      final term = oldData['term']?.toString() ?? '';
      final meaning = oldData['meaning']?.toString() ?? '';
      final level = oldData['level']?.toString() ?? 'N5';
      
      if (term.isEmpty || meaning.isEmpty) {
        throw ArgumentError('Invalid vocab data: term or meaning is empty');
      }
      
      // Handle optional fields with proper defaults
      final note = oldData['note']?.toString();
      final easiness = _parseDouble(oldData['easiness']) ?? 2.5;
      final repetitions = _parseInt(oldData['repetitions']) ?? 0;
      final intervalDays = _parseInt(oldData['intervalDays']) ?? 0;
      final favorite = _parseBool(oldData['favorite']) ?? false;
      
      // Handle datetime fields
      final lastReviewedAt = _parseDateTime(oldData['lastReviewedAt']);
      final dueAt = _parseDateTime(oldData['dueAt']);
      final createdAt = _parseDateTime(oldData['createdAt']) ?? DateTime.now();
      final updatedAt = _parseDateTime(oldData['updatedAt']) ?? DateTime.now();
      
      // Create new vocab record
      final vocab = Vocab(
        term: term,
        meaning: meaning,
        level: level,
        note: note,
        easiness: easiness,
        repetitions: repetitions,
        intervalDays: intervalDays,
        lastReviewedAt: lastReviewedAt,
        dueAt: dueAt,
        favorite: favorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      
      // Insert using database service
      await dbService.addVocab(
        term: vocab.term,
        meaning: vocab.meaning,
        level: vocab.level,
        note: vocab.note,
        favorite: vocab.favorite,
      );
      
      if (kDebugMode) {
        print('Migrated vocab: ${vocab.term}');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Failed to migrate vocab record: $e');
        print('Record data: $oldData');
      }
      rethrow;
    }
  }
  
  /// Utility methods for parsing data with proper error handling
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
  
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return null;
  }
  
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is DateTime) return value;
    
    if (value is int) {
      // Assume milliseconds since epoch
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return null;
      }
    }
    
    if (value is String) {
      try {
        // Try to parse ISO 8601 format
        return DateTime.parse(value);
      } catch (e) {
        // Try to parse as int (milliseconds)
        final intValue = int.tryParse(value);
        if (intValue != null) {
          return DateTime.fromMillisecondsSinceEpoch(intValue);
        }
        return null;
      }
    }
    
    return null;
  }
  
  /// Clean up backup database files
  static Future<void> cleanupBackups() async {
    try {
      final databasesPath = await getDatabasesPath();
      final backupPath = join(databasesPath, '$_oldDatabaseName$_backupSuffix');
      
      if (await File(backupPath).exists()) {
        await File(backupPath).delete();
        if (kDebugMode) {
          print('Backup file cleaned up: $backupPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cleanup backup: $e');
      }
    }
  }
  
  /// Restore from backup in case of migration failure
  static Future<MigrationResult> restoreFromBackup() async {
    try {
      final databasesPath = await getDatabasesPath();
      final originalPath = join(databasesPath, _oldDatabaseName);
      final backupPath = join(databasesPath, '$_oldDatabaseName$_backupSuffix');
      
      if (!await File(backupPath).exists()) {
        return MigrationResult.error('No backup file found');
      }
      
      // Delete current database and restore from backup
      if (await File(originalPath).exists()) {
        await File(originalPath).delete();
      }
      
      await File(backupPath).copy(originalPath);
      
      if (kDebugMode) {
        print('Database restored from backup');
      }
      
      return MigrationResult.success('Database restored from backup');
    } catch (e) {
      return MigrationResult.error('Failed to restore from backup: $e');
    }
  }
}

/// Result class for migration operations
class MigrationResult {
  final bool success;
  final String message;
  
  const MigrationResult._(this.success, this.message);
  
  factory MigrationResult.success(String message) => 
      MigrationResult._(true, message);
  
  factory MigrationResult.error(String message) => 
      MigrationResult._(false, message);
  
  @override
  String toString() => success ? 'Success: $message' : 'Error: $message';
}
