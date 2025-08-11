import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_flashcard/models/kanji.dart';

void main() {
  group('Kanji Model Tests', () {
    late DateTime created;
    late DateTime updated;

    setUp(() {
      created = DateTime(2024, 1, 1);
      updated = DateTime(2024, 1, 2);
    });

    test('constructor and toMap/fromMap', () {
      final kanji = Kanji(
        character: '日',
        onyomi: 'ニチ',
        kunyomi: 'ひ',
        meaning: 'sun',
        hanviet: 'nhật',
        level: 'N5',
        createdAt: created,
        updatedAt: updated,
      );

      final map = kanji.toMap();
      final from = Kanji.fromMap(map);

      expect(from.character, '日');
      expect(from.onyomi, 'ニチ');
      expect(from.kunyomi, 'ひ');
      expect(from.meaning, 'sun');
      expect(from.hanviet, 'nhật');
      expect(from.level, 'N5');
      expect(from.createdAt, created);
      expect(from.updatedAt, updated);
    });

    test('copyWith updates fields', () {
      final kanji = Kanji(
        character: '日',
        onyomi: 'ニチ',
        kunyomi: 'ひ',
        meaning: 'sun',
        hanviet: 'nhật',
        level: 'N5',
        createdAt: created,
        updatedAt: updated,
      );

      final copy = kanji.copyWith(meaning: 'day');
      expect(copy.meaning, 'day');
      expect(copy.character, kanji.character);
    });
  });
}
