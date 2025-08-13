import 'package:flutter_test/flutter_test.dart';
import 'test_database_helper.dart';

void main() {
  group('Tạo từ vựng N5', () {
    setUp(() async {
      await TestDatabaseService.initialize();
      await TestDatabaseService.reset(); // Clear data before each test
    });

    tearDown(() async {
      await TestDatabaseService.reset(); // Clear data after each test
    });

    test('Thêm một số từ N5', () async {
      final words = [
        {'term': '水', 'hiragana': 'みず', 'meaning': 'nước', 'level': 'N5'},
        {'term': '火', 'hiragana': 'ひ', 'meaning': 'lửa', 'level': 'N5'},
        {'term': '山', 'hiragana': 'やま', 'meaning': 'núi', 'level': 'N5'},
        {'term': '川', 'hiragana': 'かわ', 'meaning': 'sông', 'level': 'N5'},
        {'term': '空', 'hiragana': 'そら', 'meaning': 'bầu trời', 'level': 'N5'},
      ];
      for (final w in words) {
        final v = await TestDatabaseService.addVocab(
            term: w['term']!,
            hiragana: w['hiragana']!,
            meaning: w['meaning']!,
            level: w['level']!);
        expect(v.term, w['term']);
        expect(v.meaning, w['meaning']);
        expect(v.level, w['level']);
        expect(v.id, isNotNull); // Verify ID is assigned
      }
      
      // Verify all words were added
      final allVocabs = await TestDatabaseService.getAllVocabs(level: 'N5');
      expect(allVocabs.length, 5);
      
      // Verify we can retrieve them by level
      expect(allVocabs.every((v) => v.level == 'N5'), isTrue);
    });

    test('Tìm kiếm từ vựng', () async {
      // Add some test data
      await TestDatabaseService.addVocab(
          term: '本', hiragana: 'ほん', meaning: 'sách', level: 'N5');
      await TestDatabaseService.addVocab(
          term: '水', hiragana: 'みず', meaning: 'nước', level: 'N5');
      await TestDatabaseService.addVocab(
          term: '図書館', hiragana: 'としょかん', meaning: 'thư viện', level: 'N4');
      
      // Search by term
      final searchByTerm = await TestDatabaseService.searchVocabs('本');
      expect(searchByTerm.length, 1);
      expect(searchByTerm.first.term, '本');
      
      // Search by meaning
      final searchByMeaning = await TestDatabaseService.searchVocabs('nước');
      expect(searchByMeaning.length, 1);
      expect(searchByMeaning.first.meaning, 'nước');
      
      // Search with level filter
      final searchN5 = await TestDatabaseService.searchVocabs('', level: 'N5');
      expect(searchN5.length, 2);
    });

    test('Cập nhật và xóa từ vựng', () async {
      // Add a vocab
      final vocab = await TestDatabaseService.addVocab(
          term: '犬', hiragana: 'いぬ', meaning: 'chó', level: 'N5');
      
      // Update it
      await TestDatabaseService.updateVocab(
        vocab,
        meaning: 'con chó',
        favorite: true,
      );
      
      // Verify update
      final updated = await TestDatabaseService.getVocabById(vocab.id!);
      expect(updated?.meaning, 'con chó');
      expect(updated?.favorite, isTrue);
      expect(updated?.term, '犬'); // Should remain unchanged
      
      // Test count operations
      final totalCount = await TestDatabaseService.getTotalVocabCount();
      expect(totalCount, 1);
      
      final favoriteCount = await TestDatabaseService.getFavoriteVocabCount();
      expect(favoriteCount, 1);
      
      // Delete the vocab
      await TestDatabaseService.deleteVocab(vocab);
      
      // Verify deletion
      final deleted = await TestDatabaseService.getVocabById(vocab.id!);
      expect(deleted, isNull);
      
      final finalCount = await TestDatabaseService.getTotalVocabCount();
      expect(finalCount, 0);
    });
    
    test('Kiểm tra từ vựng đến hạn ôn tập', () async {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 1));
      final future = now.add(const Duration(days: 1));
      
      // Add vocabs with different due dates
      final vocab1 = await TestDatabaseService.addVocab(
          term: '水', hiragana: 'みず', meaning: 'nước', level: 'N5');
      final vocab2 = await TestDatabaseService.addVocab(
          term: '火', hiragana: 'ひ', meaning: 'lửa', level: 'N5');
      final vocab3 = await TestDatabaseService.addVocab(
          term: '山', hiragana: 'やま', meaning: 'núi', level: 'N5');
      
      // Manually set due dates
      vocab1.dueAt = past; // Past due
      vocab2.dueAt = null; // Never reviewed (should be due)
      vocab3.dueAt = future; // Future due
      
      // Update vocabs with new due dates
      await TestDatabaseService.updateVocab(vocab1);
      await TestDatabaseService.updateVocab(vocab2);
      await TestDatabaseService.updateVocab(vocab3);
      
      // Get due vocabs
      final dueVocabs = await TestDatabaseService.getDueVocabs();
      expect(dueVocabs.length, 2); // vocab1 (past due) and vocab2 (never reviewed)
      
      final dueCount = await TestDatabaseService.getDueVocabCount();
      expect(dueCount, 2);
    });
  });
}
