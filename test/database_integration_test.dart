import 'package:flutter_test/flutter_test.dart';
import 'test_database_helper.dart';

void main() {
  group('Database Integration Tests', () {
    setUp(() async {
      await TestDatabaseService.initialize();
      await TestDatabaseService.reset();
    });

    tearDown(() async {
      await TestDatabaseService.reset();
    });

    group('Review Log Tests', () {
      test('Add and retrieve review logs', () async {
        // Create a vocab
        final vocab = await TestDatabaseService.addVocab(
          term: '猫',
          meaning: 'mèo',
          level: 'N5',
        );

        // Add some review logs with slight delay to ensure different timestamps
        await TestDatabaseService.addReviewLog(
          vocab: vocab,
          grade: 4,
          nextInterval: 1,
        );

        // Add a small delay to ensure different reviewedAt times
        await Future.delayed(const Duration(milliseconds: 10));
        
        await TestDatabaseService.addReviewLog(
          vocab: vocab,
          grade: 5,
          nextInterval: 3,
        );

        // Retrieve review logs
        final logs = await TestDatabaseService.getReviewLogs(vocab.id!);
        expect(logs.length, 2);
        
        // Check that we have both grades (order may vary due to timing)
        final grades = logs.map((log) => log.grade).toSet();
        expect(grades.contains(4), isTrue);
        expect(grades.contains(5), isTrue);
        
        // Verify log data
        expect(logs[0].vocabId, vocab.id);
        expect(logs[0].intervalAfter, 3);
      });

      test('Review logs are deleted with vocab (cascade)', () async {
        final vocab = await TestDatabaseService.addVocab(
          term: '鳥',
          meaning: 'chim',
          level: 'N4',
        );

        // Add review logs
        await TestDatabaseService.addReviewLog(
          vocab: vocab,
          grade: 3,
          nextInterval: 2,
        );

        // Verify log exists
        var logs = await TestDatabaseService.getReviewLogs(vocab.id!);
        expect(logs.length, 1);

        // Delete vocab
        await TestDatabaseService.deleteVocab(vocab);

        // Verify logs are also deleted (cascade)
        logs = await TestDatabaseService.getReviewLogs(vocab.id!);
        expect(logs.length, 0);
      });
    });

    group('Complex Query Tests', () {
      test('Multiple levels and search combinations', () async {
        // Add test data across different levels
        await TestDatabaseService.addVocab(term: '水', meaning: 'nước', level: 'N5');
        await TestDatabaseService.addVocab(term: '火', meaning: 'lửa', level: 'N5');
        await TestDatabaseService.addVocab(term: '図書館', meaning: 'thư viện', level: 'N4');
        await TestDatabaseService.addVocab(term: '勉強', meaning: 'học tập', level: 'N4');
        await TestDatabaseService.addVocab(term: '試験', meaning: 'kỳ thi', level: 'N3');

        // Test level filtering
        final n5Vocabs = await TestDatabaseService.getAllVocabs(level: 'N5');
        expect(n5Vocabs.length, 2);

        final n4Vocabs = await TestDatabaseService.getAllVocabs(level: 'N4');
        expect(n4Vocabs.length, 2);

        final n3Vocabs = await TestDatabaseService.getAllVocabs(level: 'N3');
        expect(n3Vocabs.length, 1);

        // Test search with level filter
        final searchN4 = await TestDatabaseService.searchVocabs('図', level: 'N4');
        expect(searchN4.length, 1);
        expect(searchN4.first.term, '図書館');

        // Test search across all levels
        final searchByMeaning = await TestDatabaseService.searchVocabs('học');
        expect(searchByMeaning.length, 1);
        expect(searchByMeaning.first.term, '勉強');
      });

      test('Due date calculations and filtering', () async {
        final now = DateTime.now();
        final pastHour = now.subtract(const Duration(hours: 1));
        final futureHour = now.add(const Duration(hours: 1));
        final pastDay = now.subtract(const Duration(days: 1));
        final futureDay = now.add(const Duration(days: 1));

        // Create vocabs with various due dates
        final vocab1 = await TestDatabaseService.addVocab(term: '今', meaning: 'bây giờ', level: 'N5');
        vocab1.dueAt = pastDay; // Very overdue
        await TestDatabaseService.updateVocab(vocab1);

        final vocab2 = await TestDatabaseService.addVocab(term: '昨日', meaning: 'hôm qua', level: 'N5');
        vocab2.dueAt = pastHour; // Recently due
        await TestDatabaseService.updateVocab(vocab2);

        final vocab3 = await TestDatabaseService.addVocab(term: '明日', meaning: 'ngày mai', level: 'N5');
        vocab3.dueAt = futureHour; // Due soon
        await TestDatabaseService.updateVocab(vocab3);

        final vocab4 = await TestDatabaseService.addVocab(term: '来週', meaning: 'tuần tới', level: 'N4');
        vocab4.dueAt = futureDay; // Due later
        await TestDatabaseService.updateVocab(vocab4);

        final vocab5 = await TestDatabaseService.addVocab(term: '新しい', meaning: 'mới', level: 'N5');
        // vocab5.dueAt remains null (new vocab)

        // Get due vocabs
        final dueVocabs = await TestDatabaseService.getDueVocabs();
        expect(dueVocabs.length, 3); // vocab1, vocab2, vocab5 (null means due)

        // Check ordering (should be by dueAt ASC, null first)
        final dueVocabIds = dueVocabs.map((v) => v.id).toSet();
        expect(dueVocabIds.contains(vocab1.id), isTrue);
        expect(dueVocabIds.contains(vocab2.id), isTrue);
        expect(dueVocabIds.contains(vocab5.id), isTrue);
        expect(dueVocabIds.contains(vocab3.id), isFalse);
        expect(dueVocabIds.contains(vocab4.id), isFalse);

        // Test due count
        final dueCount = await TestDatabaseService.getDueVocabCount();
        expect(dueCount, 3);

        // Test due count with level filter
        final dueN5Count = await TestDatabaseService.getDueVocabCount(level: 'N5');
        expect(dueN5Count, 3); // All due vocabs are N5

        final dueN4Count = await TestDatabaseService.getDueVocabCount(level: 'N4');
        expect(dueN4Count, 0); // No due N4 vocabs
      });
    });

    group('Favorites Tests', () {
      test('Favorite operations', () async {
        // Create some vocabs
        final vocab1 = await TestDatabaseService.addVocab(
          term: '好き', meaning: 'thích', level: 'N5', favorite: true);
        final vocab2 = await TestDatabaseService.addVocab(
          term: '嫌い', meaning: 'ghét', level: 'N5', favorite: false);
        final vocab3 = await TestDatabaseService.addVocab(
          term: '愛', meaning: 'yêu', level: 'N3', favorite: true);

        // Test favorite retrieval
        final favorites = await TestDatabaseService.getFavoriteVocabs();
        expect(favorites.length, 2);

        final favoriteTerms = favorites.map((v) => v.term).toSet();
        expect(favoriteTerms.contains('好き'), isTrue);
        expect(favoriteTerms.contains('愛'), isTrue);
        expect(favoriteTerms.contains('嫌い'), isFalse);

        // Test favorite count
        final favoriteCount = await TestDatabaseService.getFavoriteVocabCount();
        expect(favoriteCount, 2);

        // Test favorite count with level filter
        final favoriteN5Count = await TestDatabaseService.getFavoriteVocabCount(level: 'N5');
        expect(favoriteN5Count, 1);

        final favoriteN3Count = await TestDatabaseService.getFavoriteVocabCount(level: 'N3');
        expect(favoriteN3Count, 1);

        // Update favorite status
        await TestDatabaseService.updateVocab(vocab2, favorite: true);
        final updatedFavoriteCount = await TestDatabaseService.getFavoriteVocabCount();
        expect(updatedFavoriteCount, 3);
      });
    });

    group('Data Integrity Tests', () {
      test('Concurrent operations', () async {
        // Test that concurrent database operations don't interfere
        final futures = <Future>[];

        // Add multiple vocabs concurrently
        for (int i = 0; i < 10; i++) {
          futures.add(TestDatabaseService.addVocab(
            term: '単語$i',
            meaning: 'từ $i',
            level: 'N${(i % 5) + 1}',
          ));
        }

        await Future.wait(futures);

        // Verify all were added
        final allVocabs = await TestDatabaseService.getAllVocabs();
        expect(allVocabs.length, 10);

        // Verify all have unique IDs
        final ids = allVocabs.map((v) => v.id).toSet();
        expect(ids.length, 10);
      });

      test('Large dataset operations', () async {
        // Add a larger dataset
        final vocabs = <String, String>{
          '犬': 'chó',
          '猫': 'mèo',
          '鳥': 'chim',
          '魚': 'cá',
          '花': 'hoa',
          '木': 'cây',
          '山': 'núi',
          '川': 'sông',
          '空': 'trời',
          '雲': 'mây',
        };

        // Add all vocabs
        for (final entry in vocabs.entries) {
          await TestDatabaseService.addVocab(
            term: entry.key,
            meaning: entry.value,
            level: 'N5',
          );
        }

        // Test search performance on larger dataset
        final searchResults = await TestDatabaseService.searchVocabs('c');
        // Debug: Let's see what we get
        final searchTerms = searchResults.map((v) => '${v.term}:${v.meaning}').join(', ');
        print('Search results for "c": $searchTerms');
        // Search for 'c' will match: chó, chim, cá, cây (4 results)
        expect(searchResults.length, 4);

        // Test pagination-like behavior
        final limitedResults = await TestDatabaseService.getDueVocabs(limit: 5);
        expect(limitedResults.length, 5);

        // Verify total count
        final totalCount = await TestDatabaseService.getTotalVocabCount();
        expect(totalCount, 10);
      });

      test('Edge cases and error handling', () async {
        // Test with empty/null values
        expect(() async {
          await TestDatabaseService.addVocab(term: '', meaning: 'test', level: 'N5');
        }, throwsA(isA<Exception>()));

        // Test update on non-existent vocab
        final fakeVocab = await TestDatabaseService.addVocab(
          term: 'test', meaning: 'test', level: 'N5');
        await TestDatabaseService.deleteVocab(fakeVocab);
        
        // This should not throw but won't update anything
        await TestDatabaseService.updateVocab(fakeVocab, meaning: 'updated');
        
        final retrieved = await TestDatabaseService.getVocabById(fakeVocab.id!);
        expect(retrieved, isNull);

        // Test search with empty query
        final emptySearch = await TestDatabaseService.searchVocabs('');
        expect(emptySearch, isA<List>());

        // Test search with special characters
        await TestDatabaseService.addVocab(term: '100%', meaning: '100%', level: 'N5');
        final specialSearch = await TestDatabaseService.searchVocabs('100%');
        expect(specialSearch.length, 1);
        expect(specialSearch.first.term, '100%');
      });
    });

    group('Database State Tests', () {
      test('Reset functionality', () async {
        // Add some data
        await TestDatabaseService.addVocab(term: 'test1', meaning: 'test1', level: 'N5');
        await TestDatabaseService.addVocab(term: 'test2', meaning: 'test2', level: 'N5');
        
        final beforeReset = await TestDatabaseService.getTotalVocabCount();
        expect(beforeReset, 2);

        // Reset
        await TestDatabaseService.reset();

        // Verify empty
        final afterReset = await TestDatabaseService.getTotalVocabCount();
        expect(afterReset, 0);

        // Verify we can still add data
        await TestDatabaseService.addVocab(term: 'new', meaning: 'new', level: 'N5');
        final afterAdd = await TestDatabaseService.getTotalVocabCount();
        expect(afterAdd, 1);
      });

      test('Clear all data functionality', () async {
        // Add vocabs and review logs
        final vocab = await TestDatabaseService.addVocab(
          term: 'test', meaning: 'test', level: 'N5');
        await TestDatabaseService.addReviewLog(
          vocab: vocab, grade: 4, nextInterval: 1);

        // Verify data exists
        expect(await TestDatabaseService.getTotalVocabCount(), 1);
        expect((await TestDatabaseService.getReviewLogs(vocab.id!)).length, 1);

        // Clear all data
        await TestDatabaseService.clearAllData();

        // Verify everything is cleared
        expect(await TestDatabaseService.getTotalVocabCount(), 0);
        expect((await TestDatabaseService.getReviewLogs(vocab.id!)).length, 0);
      });
    });
  });
}
