import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../test_database_helper.dart';

void main() {
  setUp(() async {
    await TestDatabaseService.reset();
  });

  test('daily counts and streak', () async {
    final v = await TestDatabaseService.addVocab(
        term: '猫', hiragana: 'ねこ', meaning: 'mèo', level: 'N5');
    final now = DateTime.now();
    await TestDatabaseService.addReviewLog(
        vocab: v, grade: 5, nextInterval: 1, reviewedAt: now);
    await TestDatabaseService.addReviewLog(
        vocab: v,
        grade: 5,
        nextInterval: 1,
        reviewedAt: now.subtract(const Duration(days: 1)));
    await TestDatabaseService.addReviewLog(
        vocab: v,
        grade: 5,
        nextInterval: 1,
        reviewedAt: now.subtract(const Duration(days: 3)));

    final daily = await TestDatabaseService.getDailyReviewCounts(days: 4);
    expect(daily.length, 4);
    final streak = await TestDatabaseService.getReviewStreak();
    expect(streak, 2);
  });

  test('backup and restore', () async {
    await TestDatabaseService.addVocab(
        term: '犬', hiragana: 'いぬ', meaning: 'chó', level: 'N5');
    final tempDir = await Directory.systemTemp.createTemp();
    final path = '${tempDir.path}/backup.json';
    await TestDatabaseService.backupToFile(path);
    await TestDatabaseService.clearAllData();
    expect((await TestDatabaseService.getAllVocabs()).length, 0);
    await TestDatabaseService.restoreFromFile(path);
    expect((await TestDatabaseService.getAllVocabs()).length, 1);
    await tempDir.delete(recursive: true);
  });
}

