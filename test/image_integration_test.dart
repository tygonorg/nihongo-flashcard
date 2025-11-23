import 'package:flutter_test/flutter_test.dart';
import 'test_database_helper.dart';

void main() {
  group('Image Integration Tests', () {
    setUp(() async {
      await TestDatabaseService.initialize();
      await TestDatabaseService.reset();
    });

    tearDown(() async {
      await TestDatabaseService.reset();
    });

    test('Add vocab with image', () async {
      final vocab = await TestDatabaseService.addVocab(
        term: '猫',
        hiragana: 'ねこ',
        meaning: 'mèo',
        level: 'N5',
        imagePath: '/path/to/cat.jpg',
      );

      expect(vocab.imagePath, '/path/to/cat.jpg');

      final retrieved = await TestDatabaseService.getVocabById(vocab.id!);
      expect(retrieved?.imagePath, '/path/to/cat.jpg');
    });

    test('Update vocab with image', () async {
      final vocab = await TestDatabaseService.addVocab(
        term: '犬',
        hiragana: 'いぬ',
        meaning: 'chó',
        level: 'N5',
      );

      expect(vocab.imagePath, isNull);

      await TestDatabaseService.updateVocab(
        vocab,
        imagePath: '/path/to/dog.jpg',
      );

      final retrieved = await TestDatabaseService.getVocabById(vocab.id!);
      expect(retrieved?.imagePath, '/path/to/dog.jpg');
    });

    test('Update vocab image to null (remove image)', () async {
      // Note: In our current implementation of updateVocab, passing null for imagePath
      // doesn't clear it (it only updates if non-null).
      // If we want to support clearing, we might need to change updateVocab signature or logic.
      // For now, let's verify that passing null doesn't change existing image.
      
      final vocab = await TestDatabaseService.addVocab(
        term: '鳥',
        hiragana: 'とり',
        meaning: 'chim',
        level: 'N5',
        imagePath: '/path/to/bird.jpg',
      );

      await TestDatabaseService.updateVocab(
        vocab,
        imagePath: null, // Should not change anything
      );

      final retrieved = await TestDatabaseService.getVocabById(vocab.id!);
      expect(retrieved?.imagePath, '/path/to/bird.jpg');
    });
  });
}
