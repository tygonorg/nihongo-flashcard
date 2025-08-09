import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/review_log.dart';

void main() {
  group('ReviewLog Model Tests', () {
    late DateTime testReviewedAt;

    setUp(() {
      testReviewedAt = DateTime(2024, 1, 1, 15, 30, 45);
    });

    group('Constructor and Required Fields', () {
      test('creates ReviewLog with required fields', () {
        final reviewLog = ReviewLog(
          vocabId: 42,
          reviewedAt: testReviewedAt,
          grade: 4,
          intervalAfter: 7,
        );

        expect(reviewLog.id, isNull);
        expect(reviewLog.vocabId, 42);
        expect(reviewLog.reviewedAt, testReviewedAt);
        expect(reviewLog.grade, 4);
        expect(reviewLog.intervalAfter, 7);
      });

      test('creates ReviewLog with all fields including id', () {
        final reviewLog = ReviewLog(
          id: 100,
          vocabId: 25,
          reviewedAt: testReviewedAt,
          grade: 5,
          intervalAfter: 14,
        );

        expect(reviewLog.id, 100);
        expect(reviewLog.vocabId, 25);
        expect(reviewLog.reviewedAt, testReviewedAt);
        expect(reviewLog.grade, 5);
        expect(reviewLog.intervalAfter, 14);
      });
    });

    group('JSON Serialization - toMap()', () {
      test('converts ReviewLog to Map with all fields', () {
        final reviewLog = ReviewLog(
          id: 5,
          vocabId: 123,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 10,
        );

        final map = reviewLog.toMap();

        expect(map['id'], 5);
        expect(map['vocabId'], 123);
        expect(map['reviewedAt'], testReviewedAt.millisecondsSinceEpoch);
        expect(map['grade'], 3);
        expect(map['intervalAfter'], 10);
      });

      test('converts ReviewLog to Map without id', () {
        final reviewLog = ReviewLog(
          vocabId: 99,
          reviewedAt: testReviewedAt,
          grade: 2,
          intervalAfter: 3,
        );

        final map = reviewLog.toMap();

        expect(map['id'], isNull);
        expect(map['vocabId'], 99);
        expect(map['reviewedAt'], testReviewedAt.millisecondsSinceEpoch);
        expect(map['grade'], 2);
        expect(map['intervalAfter'], 3);
      });

      test('correctly converts DateTime to milliseconds', () {
        final specificDate = DateTime(2024, 6, 15, 9, 45, 30, 500);
        final reviewLog = ReviewLog(
          vocabId: 1,
          reviewedAt: specificDate,
          grade: 1,
          intervalAfter: 1,
        );

        final map = reviewLog.toMap();
        final expectedMillis = specificDate.millisecondsSinceEpoch;

        expect(map['reviewedAt'], expectedMillis);
      });
    });

    group('JSON Deserialization - fromMap()', () {
      test('creates ReviewLog from Map with all fields', () {
        final map = {
          'id': 50,
          'vocabId': 200,
          'reviewedAt': testReviewedAt.millisecondsSinceEpoch,
          'grade': 4,
          'intervalAfter': 21,
        };

        final reviewLog = ReviewLog.fromMap(map);

        expect(reviewLog.id, 50);
        expect(reviewLog.vocabId, 200);
        expect(reviewLog.reviewedAt, testReviewedAt);
        expect(reviewLog.grade, 4);
        expect(reviewLog.intervalAfter, 21);
      });

      test('creates ReviewLog from Map without id', () {
        final map = {
          'id': null,
          'vocabId': 75,
          'reviewedAt': testReviewedAt.millisecondsSinceEpoch,
          'grade': 0,
          'intervalAfter': 0,
        };

        final reviewLog = ReviewLog.fromMap(map);

        expect(reviewLog.id, isNull);
        expect(reviewLog.vocabId, 75);
        expect(reviewLog.reviewedAt, testReviewedAt);
        expect(reviewLog.grade, 0);
        expect(reviewLog.intervalAfter, 0);
      });

      test('correctly converts milliseconds to DateTime', () {
        final specificDate = DateTime(2023, 12, 25, 23, 59, 59, 999);
        final map = {
          'vocabId': 1,
          'reviewedAt': specificDate.millisecondsSinceEpoch,
          'grade': 5,
          'intervalAfter': 30,
        };

        final reviewLog = ReviewLog.fromMap(map);

        expect(reviewLog.reviewedAt, specificDate);
      });
    });

    group('Round-trip Serialization', () {
      test('toMap() and fromMap() are inverses with all fields', () {
        final original = ReviewLog(
          id: 77,
          vocabId: 333,
          reviewedAt: testReviewedAt,
          grade: 4,
          intervalAfter: 12,
        );

        final map = original.toMap();
        final restored = ReviewLog.fromMap(map);

        expect(restored, equals(original));
      });

      test('toMap() and fromMap() are inverses without id', () {
        final original = ReviewLog(
          vocabId: 555,
          reviewedAt: testReviewedAt,
          grade: 1,
          intervalAfter: 2,
        );

        final map = original.toMap();
        final restored = ReviewLog.fromMap(map);

        expect(restored, equals(original));
      });

      test('round-trip preserves millisecond precision', () {
        final preciseDate = DateTime(2024, 3, 14, 15, 9, 26, 535);
        final original = ReviewLog(
          vocabId: 1,
          reviewedAt: preciseDate,
          grade: 3,
          intervalAfter: 7,
        );

        final map = original.toMap();
        final restored = ReviewLog.fromMap(map);

        expect(restored.reviewedAt, preciseDate);
        expect(restored, equals(original));
      });
    });

    group('Equality Override', () {
      test('identical objects are equal', () {
        final reviewLog = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        expect(reviewLog, equals(reviewLog));
        expect(reviewLog.hashCode, equals(reviewLog.hashCode));
      });

      test('objects with same values are equal', () {
        final reviewLog1 = ReviewLog(
          id: 10,
          vocabId: 200,
          reviewedAt: testReviewedAt,
          grade: 4,
          intervalAfter: 8,
        );

        final reviewLog2 = ReviewLog(
          id: 10,
          vocabId: 200,
          reviewedAt: testReviewedAt,
          grade: 4,
          intervalAfter: 8,
        );

        expect(reviewLog1, equals(reviewLog2));
        expect(reviewLog1.hashCode, equals(reviewLog2.hashCode));
      });

      test('objects with different values are not equal', () {
        final reviewLog1 = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        final reviewLog2 = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 4, // different grade
          intervalAfter: 5,
        );

        expect(reviewLog1, isNot(equals(reviewLog2)));
      });

      test('objects with different types are not equal', () {
        final reviewLog = ReviewLog(
          vocabId: 1,
          reviewedAt: testReviewedAt,
          grade: 2,
          intervalAfter: 3,
        );

        expect(reviewLog, isNot(equals('not a review log')));
        expect(reviewLog, isNot(equals(42)));
        expect(reviewLog, isNot(equals(null)));
      });

      test('null id differences are detected', () {
        final reviewLog1 = ReviewLog(
          id: 1,
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        final reviewLog2 = ReviewLog(
          id: null,
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        expect(reviewLog1, isNot(equals(reviewLog2)));
      });

      test('DateTime differences are detected', () {
        final date1 = DateTime(2024, 1, 1, 10, 0, 0);
        final date2 = DateTime(2024, 1, 1, 10, 0, 1); // 1 second difference

        final reviewLog1 = ReviewLog(
          vocabId: 100,
          reviewedAt: date1,
          grade: 3,
          intervalAfter: 5,
        );

        final reviewLog2 = ReviewLog(
          vocabId: 100,
          reviewedAt: date2,
          grade: 3,
          intervalAfter: 5,
        );

        expect(reviewLog1, isNot(equals(reviewLog2)));
      });

      test('vocabId differences are detected', () {
        final reviewLog1 = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        final reviewLog2 = ReviewLog(
          vocabId: 101, // different vocabId
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        expect(reviewLog1, isNot(equals(reviewLog2)));
      });

      test('grade differences are detected', () {
        final reviewLog1 = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        final reviewLog2 = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 4, // different grade
          intervalAfter: 5,
        );

        expect(reviewLog1, isNot(equals(reviewLog2)));
      });

      test('intervalAfter differences are detected', () {
        final reviewLog1 = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 5,
        );

        final reviewLog2 = ReviewLog(
          vocabId: 100,
          reviewedAt: testReviewedAt,
          grade: 3,
          intervalAfter: 6, // different interval
        );

        expect(reviewLog1, isNot(equals(reviewLog2)));
      });
    });

    group('copyWith Method', () {
      late ReviewLog originalReviewLog;

      setUp(() {
        originalReviewLog = ReviewLog(
          id: 25,
          vocabId: 150,
          reviewedAt: testReviewedAt,
          grade: 4,
          intervalAfter: 10,
        );
      });

      test('copyWith no changes returns equal object', () {
        final copy = originalReviewLog.copyWith();
        expect(copy, equals(originalReviewLog));
        expect(identical(copy, originalReviewLog), false); // different instances
      });

      test('copyWith single field change', () {
        final copy = originalReviewLog.copyWith(grade: 5);

        expect(copy.id, originalReviewLog.id);
        expect(copy.vocabId, originalReviewLog.vocabId);
        expect(copy.reviewedAt, originalReviewLog.reviewedAt);
        expect(copy.grade, 5); // changed
        expect(copy.intervalAfter, originalReviewLog.intervalAfter);
      });

      test('copyWith multiple field changes', () {
        final newDate = DateTime(2024, 2, 15, 12, 0, 0);
        final copy = originalReviewLog.copyWith(
          vocabId: 999,
          reviewedAt: newDate,
          grade: 0,
        );

        expect(copy.id, originalReviewLog.id);
        expect(copy.vocabId, 999); // changed
        expect(copy.reviewedAt, newDate); // changed
        expect(copy.grade, 0); // changed
        expect(copy.intervalAfter, originalReviewLog.intervalAfter); // unchanged
      });

      test('copyWith with null params preserves original values', () {
        // Note: The current copyWith implementation uses ?? operator,
        // so passing null doesn't override fields to null, it preserves original values
        final copy = originalReviewLog.copyWith(id: null);

        expect(copy.id, originalReviewLog.id); // preserved, not set to null
        expect(copy.vocabId, originalReviewLog.vocabId);
        expect(copy.reviewedAt, originalReviewLog.reviewedAt);
        expect(copy.grade, originalReviewLog.grade);
        expect(copy.intervalAfter, originalReviewLog.intervalAfter);
      });

      test('copyWith can set id from null to value', () {
        final logWithoutId = ReviewLog(
          vocabId: 200,
          reviewedAt: testReviewedAt,
          grade: 2,
          intervalAfter: 3,
        );

        final copy = logWithoutId.copyWith(id: 50);

        expect(copy.id, 50);
        expect(copy.vocabId, logWithoutId.vocabId);
        expect(copy.reviewedAt, logWithoutId.reviewedAt);
        expect(copy.grade, logWithoutId.grade);
        expect(copy.intervalAfter, logWithoutId.intervalAfter);
      });

      test('copyWith preserves original object', () {
        final originalGrade = originalReviewLog.grade;
        final originalInterval = originalReviewLog.intervalAfter;

        originalReviewLog.copyWith(
          grade: 0,
          intervalAfter: 999,
        );

        expect(originalReviewLog.grade, originalGrade); // unchanged
        expect(originalReviewLog.intervalAfter, originalInterval); // unchanged
      });

      test('copyWith all fields', () {
        final newDate = DateTime(2025, 12, 31, 23, 59, 59);
        final copy = originalReviewLog.copyWith(
          id: 999,
          vocabId: 888,
          reviewedAt: newDate,
          grade: 1,
          intervalAfter: 100,
        );

        expect(copy.id, 999);
        expect(copy.vocabId, 888);
        expect(copy.reviewedAt, newDate);
        expect(copy.grade, 1);
        expect(copy.intervalAfter, 100);
      });
    });

    group('toString Method', () {
      test('toString includes all fields', () {
        final reviewLog = ReviewLog(
          id: 42,
          vocabId: 123,
          reviewedAt: testReviewedAt,
          grade: 4,
          intervalAfter: 7,
        );

        final string = reviewLog.toString();

        expect(string, contains('ReviewLog{'));
        expect(string, contains('id: 42'));
        expect(string, contains('vocabId: 123'));
        expect(string, contains('grade: 4'));
        expect(string, contains('intervalAfter: 7'));
        expect(string, contains(testReviewedAt.toString()));
      });

      test('toString handles null id', () {
        final reviewLog = ReviewLog(
          vocabId: 456,
          reviewedAt: testReviewedAt,
          grade: 2,
          intervalAfter: 3,
        );

        final string = reviewLog.toString();

        expect(string, contains('id: null'));
        expect(string, contains('vocabId: 456'));
        expect(string, contains('grade: 2'));
        expect(string, contains('intervalAfter: 3'));
      });
    });

    group('Error Cases', () {
      test('fromMap handles missing required fields', () {
        final incompleteMap = {
          'id': 1,
          // missing vocabId, reviewedAt, grade, intervalAfter
        };

        expect(
          () => ReviewLog.fromMap(incompleteMap),
          throwsA(isA<TypeError>()),
        );
      });

      test('fromMap handles invalid date timestamp', () {
        final invalidMap = {
          'vocabId': 1,
          'reviewedAt': 'not_a_timestamp',
          'grade': 3,
          'intervalAfter': 5,
        };

        expect(
          () => ReviewLog.fromMap(invalidMap),
          throwsA(isA<TypeError>()),
        );
      });

      test('fromMap handles null required fields', () {
        final invalidMap = {
          'vocabId': null, // required field is null
          'reviewedAt': testReviewedAt.millisecondsSinceEpoch,
          'grade': 3,
          'intervalAfter': 5,
        };

        expect(
          () => ReviewLog.fromMap(invalidMap),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('Edge Cases', () {
      test('handles extreme grade values', () {
        final reviewLogMin = ReviewLog(
          vocabId: 1,
          reviewedAt: testReviewedAt,
          grade: 0, // minimum SM-2 grade
          intervalAfter: 1,
        );

        final reviewLogMax = ReviewLog(
          vocabId: 1,
          reviewedAt: testReviewedAt,
          grade: 5, // maximum SM-2 grade
          intervalAfter: 1000,
        );

        final mapMin = reviewLogMin.toMap();
        final mapMax = reviewLogMax.toMap();
        final restoredMin = ReviewLog.fromMap(mapMin);
        final restoredMax = ReviewLog.fromMap(mapMax);

        expect(restoredMin.grade, 0);
        expect(restoredMax.grade, 5);
        expect(restoredMin, equals(reviewLogMin));
        expect(restoredMax, equals(reviewLogMax));
      });

      test('handles negative and zero interval values', () {
        final reviewLog = ReviewLog(
          vocabId: 1,
          reviewedAt: testReviewedAt,
          grade: 0,
          intervalAfter: -1, // negative interval
        );

        final map = reviewLog.toMap();
        final restored = ReviewLog.fromMap(map);

        expect(restored.intervalAfter, -1);
        expect(restored, equals(reviewLog));
      });

      test('handles extremely large interval values', () {
        final reviewLog = ReviewLog(
          vocabId: 1,
          reviewedAt: testReviewedAt,
          grade: 5,
          intervalAfter: 999999999, // very large interval
        );

        final map = reviewLog.toMap();
        final restored = ReviewLog.fromMap(map);

        expect(restored.intervalAfter, 999999999);
        expect(restored, equals(reviewLog));
      });

      test('handles extreme DateTime values', () {
        final extremeDate = DateTime(1970, 1, 1); // Unix epoch
        final reviewLog = ReviewLog(
          vocabId: 1,
          reviewedAt: extremeDate,
          grade: 3,
          intervalAfter: 5,
        );

        final map = reviewLog.toMap();
        final restored = ReviewLog.fromMap(map);

        expect(restored.reviewedAt, extremeDate);
        expect(restored, equals(reviewLog));
      });

      test('handles future DateTime values', () {
        final futureDate = DateTime(2100, 12, 31, 23, 59, 59);
        final reviewLog = ReviewLog(
          vocabId: 1,
          reviewedAt: futureDate,
          grade: 3,
          intervalAfter: 5,
        );

        final map = reviewLog.toMap();
        final restored = ReviewLog.fromMap(map);

        expect(restored.reviewedAt, futureDate);
        expect(restored, equals(reviewLog));
      });
    });

    group('Grade Validation Context', () {
      test('SM-2 grade range validation tests', () {
        // Test all valid SM-2 grades (0-5)
        for (int grade = 0; grade <= 5; grade++) {
          final reviewLog = ReviewLog(
            vocabId: 1,
            reviewedAt: testReviewedAt,
            grade: grade,
            intervalAfter: 1,
          );

          final map = reviewLog.toMap();
          final restored = ReviewLog.fromMap(map);

          expect(restored.grade, grade);
          expect(restored, equals(reviewLog));
        }
      });

      test('handles invalid SM-2 grades (out of range)', () {
        // Note: The model itself doesn't validate grades, but we can test
        // that it handles out-of-range values without crashing
        final invalidGrades = [-1, 6, 10, -100];

        for (final grade in invalidGrades) {
          final reviewLog = ReviewLog(
            vocabId: 1,
            reviewedAt: testReviewedAt,
            grade: grade,
            intervalAfter: 1,
          );

          final map = reviewLog.toMap();
          final restored = ReviewLog.fromMap(map);

          expect(restored.grade, grade);
          expect(restored, equals(reviewLog));
        }
      });
    });
  });
}
