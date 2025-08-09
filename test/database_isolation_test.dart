import 'package:flutter_test/flutter_test.dart';
import 'test_database_helper.dart';

void main() {
  group('Database Isolation Tests', () {
    setUp(() async {
      await TestDatabaseService.initialize();
      await TestDatabaseService.reset();
    });

    tearDown(() async {
      await TestDatabaseService.reset();
    });

    test('Tests are isolated from each other - Test 1', () async {
      // Add some data
      await TestDatabaseService.addVocab(
        term: 'テスト1', 
        meaning: 'test 1', 
        level: 'N5'
      );
      
      final count = await TestDatabaseService.getTotalVocabCount();
      expect(count, 1);
    });

    test('Tests are isolated from each other - Test 2', () async {
      // This test should start with a clean database
      // even though the previous test added data
      final count = await TestDatabaseService.getTotalVocabCount();
      expect(count, 0); // Should be empty due to isolation
      
      // Add different data
      await TestDatabaseService.addVocab(
        term: 'テスト2', 
        meaning: 'test 2', 
        level: 'N4'
      );
      
      final newCount = await TestDatabaseService.getTotalVocabCount();
      expect(newCount, 1);
    });

    test('Tests are isolated from each other - Test 3', () async {
      // This test should also start with a clean database
      final count = await TestDatabaseService.getTotalVocabCount();
      expect(count, 0); // Should be empty due to isolation
      
      // Verify we can still use the database normally
      await TestDatabaseService.addVocab(
        term: 'テスト3', 
        meaning: 'test 3', 
        level: 'N3'
      );
      
      final vocabs = await TestDatabaseService.getAllVocabs();
      expect(vocabs.length, 1);
      expect(vocabs.first.term, 'テスト3');
      expect(vocabs.first.meaning, 'test 3');
      expect(vocabs.first.level, 'N3');
    });

    test('In-memory database is truly independent', () async {
      // Create and populate database
      await TestDatabaseService.addVocab(
        term: '独立', 
        meaning: 'độc lập', 
        level: 'N2'
      );
      
      // Even after closing and recreating, we should get the same data
      // within the same test (because we're not resetting mid-test)
      final vocabs1 = await TestDatabaseService.getAllVocabs();
      expect(vocabs1.length, 1);
      
      // Add more data
      await TestDatabaseService.addVocab(
        term: 'データベース', 
        meaning: 'database', 
        level: 'N1'
      );
      
      final vocabs2 = await TestDatabaseService.getAllVocabs();
      expect(vocabs2.length, 2);
      
      // Verify both are there
      final terms = vocabs2.map((v) => v.term).toSet();
      expect(terms.contains('独立'), isTrue);
      expect(terms.contains('データベース'), isTrue);
    });

    test('Database can handle complex operations in isolation', () async {
      // Add vocab with review logs
      final vocab = await TestDatabaseService.addVocab(
        term: '複雑', 
        meaning: 'phức tạp', 
        level: 'N2'
      );
      
      // Add review logs
      await TestDatabaseService.addReviewLog(
        vocab: vocab,
        grade: 4,
        nextInterval: 2,
      );
      
      await TestDatabaseService.addReviewLog(
        vocab: vocab,
        grade: 5,
        nextInterval: 4,
      );
      
      // Verify everything is working
      final logs = await TestDatabaseService.getReviewLogs(vocab.id!);
      expect(logs.length, 2);
      
      final vocabCount = await TestDatabaseService.getTotalVocabCount();
      expect(vocabCount, 1);
      
      // Update the vocab
      await TestDatabaseService.updateVocab(vocab, favorite: true);
      
      final favoriteCount = await TestDatabaseService.getFavoriteVocabCount();
      expect(favoriteCount, 1);
      
      // All of this should be isolated and not affect other tests
    });
  });
}
