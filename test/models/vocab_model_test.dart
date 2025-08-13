import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_flashcard/models/vocab.dart';

void main() {
  group('Vocab Model Tests', () {
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;
    late DateTime testLastReviewedAt;
    late DateTime testDueAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 1, 10, 0, 0);
      testUpdatedAt = DateTime(2024, 1, 2, 10, 0, 0);
      testLastReviewedAt = DateTime(2024, 1, 3, 10, 0, 0);
      testDueAt = DateTime(2024, 1, 4, 10, 0, 0);
    });

    group('Constructor and Default Values', () {
      test('creates Vocab with required fields', () {
        final vocab = Vocab(
          term: '水',
          hiragana: '水',
          meaning: 'water',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab.id, isNull);
        expect(vocab.term, '水');
        expect(vocab.meaning, 'water');
        expect(vocab.level, 'N5');
        expect(vocab.note, isNull);
        expect(vocab.easiness, 2.5); // default value
        expect(vocab.repetitions, 0); // default value
        expect(vocab.intervalDays, 0); // default value
        expect(vocab.lastReviewedAt, isNull);
        expect(vocab.dueAt, isNull);
        expect(vocab.favorite, false); // default value
        expect(vocab.createdAt, testCreatedAt);
        expect(vocab.updatedAt, testUpdatedAt);
      });

      test('creates Vocab with all fields', () {
        final vocab = Vocab(
          id: 1,
          term: '火',
          hiragana: '火',
          meaning: 'fire',
          level: 'N4',
          note: 'test note',
          easiness: 3.0,
          repetitions: 5,
          intervalDays: 10,
          lastReviewedAt: testLastReviewedAt,
          dueAt: testDueAt,
          favorite: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab.id, 1);
        expect(vocab.term, '火');
        expect(vocab.meaning, 'fire');
        expect(vocab.level, 'N4');
        expect(vocab.note, 'test note');
        expect(vocab.easiness, 3.0);
        expect(vocab.repetitions, 5);
        expect(vocab.intervalDays, 10);
        expect(vocab.lastReviewedAt, testLastReviewedAt);
        expect(vocab.dueAt, testDueAt);
        expect(vocab.favorite, true);
        expect(vocab.createdAt, testCreatedAt);
        expect(vocab.updatedAt, testUpdatedAt);
      });
    });

    group('JSON Serialization - toMap()', () {
      test('converts Vocab to Map with all fields', () {
        final vocab = Vocab(
          id: 1,
          term: '山',
          hiragana: '山',
          meaning: 'mountain',
          level: 'N5',
          note: 'test note',
          easiness: 2.8,
          repetitions: 3,
          intervalDays: 7,
          lastReviewedAt: testLastReviewedAt,
          dueAt: testDueAt,
          favorite: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final map = vocab.toMap();

        expect(map['id'], 1);
        expect(map['term'], '山');
        expect(map['meaning'], 'mountain');
        expect(map['level'], 'N5');
        expect(map['note'], 'test note');
        expect(map['easiness'], 2.8);
        expect(map['repetitions'], 3);
        expect(map['intervalDays'], 7);
        expect(map['lastReviewedAt'], testLastReviewedAt.millisecondsSinceEpoch);
        expect(map['dueAt'], testDueAt.millisecondsSinceEpoch);
        expect(map['favorite'], 1); // boolean converted to int
        expect(map['createdAt'], testCreatedAt.millisecondsSinceEpoch);
        expect(map['updatedAt'], testUpdatedAt.millisecondsSinceEpoch);
      });

      test('converts Vocab to Map with null optional fields', () {
        final vocab = Vocab(
          term: '川',
          hiragana: '川',
          meaning: 'river',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final map = vocab.toMap();

        expect(map['id'], isNull);
        expect(map['note'], isNull);
        expect(map['lastReviewedAt'], isNull);
        expect(map['dueAt'], isNull);
        expect(map['favorite'], 0); // false converted to 0
        expect(map['easiness'], 2.5);
        expect(map['repetitions'], 0);
        expect(map['intervalDays'], 0);
      });

      test('handles boolean to int conversion correctly', () {
        final vocabTrue = Vocab(
          term: 'test',
          hiragana: 'test',
          meaning: 'test',
          level: 'N5',
          favorite: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final vocabFalse = Vocab(
          term: 'test',
          hiragana: 'test',
          meaning: 'test',
          level: 'N5',
          favorite: false,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocabTrue.toMap()['favorite'], 1);
        expect(vocabFalse.toMap()['favorite'], 0);
      });
    });

    group('JSON Deserialization - fromMap()', () {
      test('creates Vocab from Map with all fields', () {
        final map = {
          'id': 1,
          'term': '空',
          'meaning': 'sky',
          'level': 'N5',
          'note': 'blue sky',
          'easiness': 3.2,
          'repetitions': 4,
          'intervalDays': 15,
          'lastReviewedAt': testLastReviewedAt.millisecondsSinceEpoch,
          'dueAt': testDueAt.millisecondsSinceEpoch,
          'favorite': 1,
          'createdAt': testCreatedAt.millisecondsSinceEpoch,
          'updatedAt': testUpdatedAt.millisecondsSinceEpoch,
        };

        final vocab = Vocab.fromMap(map);

        expect(vocab.id, 1);
        expect(vocab.term, '空');
        expect(vocab.meaning, 'sky');
        expect(vocab.level, 'N5');
        expect(vocab.note, 'blue sky');
        expect(vocab.easiness, 3.2);
        expect(vocab.repetitions, 4);
        expect(vocab.intervalDays, 15);
        expect(vocab.lastReviewedAt, testLastReviewedAt);
        expect(vocab.dueAt, testDueAt);
        expect(vocab.favorite, true);
        expect(vocab.createdAt, testCreatedAt);
        expect(vocab.updatedAt, testUpdatedAt);
      });

      test('creates Vocab from Map with null optional fields', () {
        final map = {
          'id': null,
          'term': '木',
          'meaning': 'tree',
          'level': 'N5',
          'note': null,
          'easiness': null, // should use default
          'repetitions': null, // should use default
          'intervalDays': null, // should use default
          'lastReviewedAt': null,
          'dueAt': null,
          'favorite': 0,
          'createdAt': testCreatedAt.millisecondsSinceEpoch,
          'updatedAt': testUpdatedAt.millisecondsSinceEpoch,
        };

        final vocab = Vocab.fromMap(map);

        expect(vocab.id, isNull);
        expect(vocab.term, '木');
        expect(vocab.meaning, 'tree');
        expect(vocab.level, 'N5');
        expect(vocab.note, isNull);
        expect(vocab.easiness, 2.5); // default value
        expect(vocab.repetitions, 0); // default value
        expect(vocab.intervalDays, 0); // default value
        expect(vocab.lastReviewedAt, isNull);
        expect(vocab.dueAt, isNull);
        expect(vocab.favorite, false); // 0 converted to false
        expect(vocab.createdAt, testCreatedAt);
        expect(vocab.updatedAt, testUpdatedAt);
      });

      test('handles int to boolean conversion correctly', () {
        final mapTrue = {
          'term': 'test',
          'meaning': 'test',
          'level': 'N5',
          'favorite': 1,
          'createdAt': testCreatedAt.millisecondsSinceEpoch,
          'updatedAt': testUpdatedAt.millisecondsSinceEpoch,
        };

        final mapFalse = {
          'term': 'test',
          'meaning': 'test',
          'level': 'N5',
          'favorite': 0,
          'createdAt': testCreatedAt.millisecondsSinceEpoch,
          'updatedAt': testUpdatedAt.millisecondsSinceEpoch,
        };

        final vocabTrue = Vocab.fromMap(mapTrue);
        final vocabFalse = Vocab.fromMap(mapFalse);

        expect(vocabTrue.favorite, true);
        expect(vocabFalse.favorite, false);
      });
    });

    group('Round-trip Serialization', () {
      test('toMap() and fromMap() are inverses', () {
        final original = Vocab(
          id: 42,
          term: '本',
          hiragana: '本',
          meaning: 'book',
          level: 'N5',
          note: 'reading material',
          easiness: 2.7,
          repetitions: 2,
          intervalDays: 5,
          lastReviewedAt: testLastReviewedAt,
          dueAt: testDueAt,
          favorite: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final map = original.toMap();
        final restored = Vocab.fromMap(map);

        expect(restored, equals(original));
      });

      test('round-trip with minimal fields', () {
        final original = Vocab(
          term: '人',
          hiragana: '人',
          meaning: 'person',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final map = original.toMap();
        final restored = Vocab.fromMap(map);

        expect(restored, equals(original));
      });
    });

    group('Equality Override', () {
      test('identical objects are equal', () {
        final vocab = Vocab(
          term: '犬',
          hiragana: '犬',
          meaning: 'dog',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab, equals(vocab));
        expect(vocab.hashCode, equals(vocab.hashCode));
      });

      test('objects with same values are equal', () {
        final vocab1 = Vocab(
          id: 1,
          term: '猫',
          hiragana: '猫',
          meaning: 'cat',
          level: 'N5',
          note: 'pet',
          easiness: 2.8,
          repetitions: 3,
          intervalDays: 7,
          lastReviewedAt: testLastReviewedAt,
          dueAt: testDueAt,
          favorite: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final vocab2 = Vocab(
          id: 1,
          term: '猫',
          hiragana: '猫',
          meaning: 'cat',
          level: 'N5',
          note: 'pet',
          easiness: 2.8,
          repetitions: 3,
          intervalDays: 7,
          lastReviewedAt: testLastReviewedAt,
          dueAt: testDueAt,
          favorite: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab1, equals(vocab2));
        expect(vocab1.hashCode, equals(vocab2.hashCode));
      });

      test('objects with different values are not equal', () {
        final vocab1 = Vocab(
          term: '鳥',
          hiragana: '鳥',
          meaning: 'bird',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final vocab2 = Vocab(
          term: '鳥',
          hiragana: '鳥',
          meaning: 'bird',
          level: 'N4', // different level
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab1, isNot(equals(vocab2)));
      });

      test('objects with different types are not equal', () {
        final vocab = Vocab(
          term: '魚',
          hiragana: '魚',
          meaning: 'fish',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab, isNot(equals('not a vocab')));
        expect(vocab, isNot(equals(42)));
        expect(vocab, isNot(equals(null)));
      });

      test('null field differences are detected', () {
        final vocab1 = Vocab(
          term: '車',
          hiragana: '車',
          meaning: 'car',
          level: 'N5',
          note: 'vehicle',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final vocab2 = Vocab(
          term: '車',
          hiragana: '車',
          meaning: 'car',
          level: 'N5',
          note: null,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab1, isNot(equals(vocab2)));
      });

      test('DateTime field differences are detected', () {
        final vocab1 = Vocab(
          term: '家',
          hiragana: '家',
          meaning: 'house',
          level: 'N5',
          dueAt: testDueAt,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final vocab2 = Vocab(
          term: '家',
          hiragana: '家',
          meaning: 'house',
          level: 'N5',
          dueAt: testDueAt.add(const Duration(minutes: 1)), // slightly different
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(vocab1, isNot(equals(vocab2)));
      });
    });

    group('copyWith Method', () {
      late Vocab originalVocab;

      setUp(() {
        originalVocab = Vocab(
          id: 1,
          term: '学校',
          hiragana: '学校',
          meaning: 'school',
          level: 'N5',
          note: 'education',
          easiness: 2.6,
          repetitions: 2,
          intervalDays: 4,
          lastReviewedAt: testLastReviewedAt,
          dueAt: testDueAt,
          favorite: false,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );
      });

      test('copyWith no changes returns equal object', () {
        final copy = originalVocab.copyWith();
        expect(copy, equals(originalVocab));
        expect(identical(copy, originalVocab), false); // different instances
      });

      test('copyWith single field change', () {
        final copy = originalVocab.copyWith(meaning: 'educational institution');
        
        expect(copy.id, originalVocab.id);
        expect(copy.term, originalVocab.term);
        expect(copy.meaning, 'educational institution'); // changed
        expect(copy.level, originalVocab.level);
        expect(copy.note, originalVocab.note);
        expect(copy.easiness, originalVocab.easiness);
        expect(copy.repetitions, originalVocab.repetitions);
        expect(copy.intervalDays, originalVocab.intervalDays);
        expect(copy.lastReviewedAt, originalVocab.lastReviewedAt);
        expect(copy.dueAt, originalVocab.dueAt);
        expect(copy.favorite, originalVocab.favorite);
        expect(copy.createdAt, originalVocab.createdAt);
        expect(copy.updatedAt, originalVocab.updatedAt);
      });

      test('copyWith multiple field changes', () {
        final newDueAt = DateTime(2024, 2, 1);
        final newUpdatedAt = DateTime(2024, 1, 15);
        
        final copy = originalVocab.copyWith(
          level: 'N4',
          favorite: true,
          easiness: 3.0,
          dueAt: newDueAt,
          updatedAt: newUpdatedAt,
        );

        expect(copy.level, 'N4');
        expect(copy.favorite, true);
        expect(copy.easiness, 3.0);
        expect(copy.dueAt, newDueAt);
        expect(copy.updatedAt, newUpdatedAt);
        
        // Unchanged fields
        expect(copy.id, originalVocab.id);
        expect(copy.term, originalVocab.term);
        expect(copy.meaning, originalVocab.meaning);
        expect(copy.note, originalVocab.note);
        expect(copy.repetitions, originalVocab.repetitions);
        expect(copy.intervalDays, originalVocab.intervalDays);
        expect(copy.lastReviewedAt, originalVocab.lastReviewedAt);
        expect(copy.createdAt, originalVocab.createdAt);
      });

      test('copyWith with null params preserves original values', () {
        // Note: The current copyWith implementation uses ?? operator,
        // so passing null doesn't override fields to null, it preserves original values
        final copy = originalVocab.copyWith(
          id: null, // This won't set id to null, it will keep originalVocab.id
          note: null, // This won't set note to null, it will keep originalVocab.note
          lastReviewedAt: null,
          dueAt: null,
        );

        // Fields remain unchanged when null is passed
        expect(copy.id, originalVocab.id);
        expect(copy.note, originalVocab.note);
        expect(copy.lastReviewedAt, originalVocab.lastReviewedAt);
        expect(copy.dueAt, originalVocab.dueAt);
      });
      
      test('copyWith can override non-null fields to different values', () {
        // Start with a vocab that has some null fields
        final vocabWithNulls = Vocab(
          term: 'test',
          hiragana: 'test',
          meaning: 'test',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
          // id, note, lastReviewedAt, dueAt are null by default
        );
        
        final copy = vocabWithNulls.copyWith(
          id: 42,
          note: 'new note',
        );
        
        expect(copy.id, 42);
        expect(copy.note, 'new note');
        expect(copy.lastReviewedAt, isNull); // still null
        expect(copy.dueAt, isNull); // still null
      });

      test('copyWith preserves original object', () {
        final originalTerm = originalVocab.term;
        final originalMeaning = originalVocab.meaning;
        
        originalVocab.copyWith(
          term: 'modified',
          hiragana: 'modified',
          meaning: 'modified meaning',
        );

        expect(originalVocab.term, originalTerm); // unchanged
        expect(originalVocab.meaning, originalMeaning); // unchanged
      });
    });

    group('toString Method', () {
      test('toString includes all fields', () {
        final vocab = Vocab(
          id: 5,
          term: '時間',
          hiragana: '時間',
          meaning: 'time',
          level: 'N5',
          note: 'temporal concept',
          easiness: 2.9,
          repetitions: 1,
          intervalDays: 2,
          lastReviewedAt: testLastReviewedAt,
          dueAt: testDueAt,
          favorite: true,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final string = vocab.toString();

        expect(string, contains('Vocab{'));
        expect(string, contains('id: 5'));
        expect(string, contains('term: 時間'));
        expect(string, contains('meaning: time'));
        expect(string, contains('level: N5'));
        expect(string, contains('note: temporal concept'));
        expect(string, contains('easiness: 2.9'));
        expect(string, contains('repetitions: 1'));
        expect(string, contains('intervalDays: 2'));
        expect(string, contains('favorite: true'));
        expect(string, contains(testCreatedAt.toString()));
        expect(string, contains(testUpdatedAt.toString()));
      });

      test('toString handles null fields', () {
        final vocab = Vocab(
          term: '名前',
          hiragana: '名前',
          meaning: 'name',
          level: 'N5',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final string = vocab.toString();

        expect(string, contains('id: null'));
        expect(string, contains('note: null'));
        expect(string, contains('lastReviewedAt: null'));
        expect(string, contains('dueAt: null'));
      });
    });

    group('Error Cases', () {
      test('fromMap handles missing required fields gracefully', () {
        // This would typically throw in production, but let's test what happens
        // when required fields are missing from the map
        final incompleteMap = {
          'id': 1,
          // missing term, meaning, level
          'createdAt': testCreatedAt.millisecondsSinceEpoch,
          'updatedAt': testUpdatedAt.millisecondsSinceEpoch,
        };

        expect(
          () => Vocab.fromMap(incompleteMap),
          throwsA(isA<TypeError>()),
        );
      });

      test('fromMap handles invalid date timestamps', () {
        final invalidMap = {
          'term': 'test',
          'meaning': 'test',
          'level': 'N5',
          'createdAt': 'not_a_timestamp', // invalid
          'updatedAt': testUpdatedAt.millisecondsSinceEpoch,
        };

        expect(
          () => Vocab.fromMap(invalidMap),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('Edge Cases', () {
      test('handles extremely large timestamps', () {
        final futureDate = DateTime(2100, 12, 31);
        final vocab = Vocab(
          term: 'future',
          hiragana: 'future',
          meaning: 'test',
          level: 'N5',
          createdAt: futureDate,
          updatedAt: futureDate,
          dueAt: futureDate,
        );

        final map = vocab.toMap();
        final restored = Vocab.fromMap(map);

        expect(restored.createdAt, futureDate);
        expect(restored.updatedAt, futureDate);
        expect(restored.dueAt, futureDate);
      });

      test('handles edge values for numeric fields', () {
        final vocab = Vocab(
          term: 'edge',
          hiragana: 'edge',
          meaning: 'test',
          level: 'N5',
          easiness: 0.0,
          repetitions: -1,
          intervalDays: 999999,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final map = vocab.toMap();
        final restored = Vocab.fromMap(map);

        expect(restored.easiness, 0.0);
        expect(restored.repetitions, -1);
        expect(restored.intervalDays, 999999);
      });

      test('handles empty and special strings', () {
        final vocab = Vocab(
          term: '', // empty string
          meaning: '   ', // whitespace
          level: '🎌', // emoji
          note: 'Line 1\nLine 2\tTab', // special characters
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final map = vocab.toMap();
        final restored = Vocab.fromMap(map);

        expect(restored.term, '');
        expect(restored.meaning, '   ');
        expect(restored.level, '🎌');
        expect(restored.note, 'Line 1\nLine 2\tTab');
      });
    });
  });
}
