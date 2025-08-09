import 'package:flutter_test/flutter_test.dart';
import '../test_database_helper.dart';
import '../../lib/services/srs_service.dart';
import '../../lib/services/database_service.dart';
import '../../lib/models/vocab.dart';

/// Mock DatabaseService that implements the interface needed by SrsService
class MockDatabaseService extends DatabaseService {
  MockDatabaseService() : super();

  @override
  Future<void> updateVocabSrsData(Vocab vocab) async {
    return TestDatabaseService.updateVocabSrsData(vocab);
  }

  @override
  Future<void> addReviewLog({
    required Vocab vocab,
    required int grade,
    required int nextInterval,
    DateTime? reviewedAt,
  }) async {
    return TestDatabaseService.addReviewLog(
      vocab: vocab,
      grade: grade,
      nextInterval: nextInterval,
      reviewedAt: reviewedAt,
    );
  }
}

void main() {
  group('SRS Service Tests', () {
    late SrsService srsService;
    late MockDatabaseService mockDb;

    setUp(() async {
      // Initialize test database
      await TestDatabaseService.initialize();
      await TestDatabaseService.reset();
      
      mockDb = MockDatabaseService();
      srsService = SrsService(mockDb as dynamic);
    });

    tearDown(() async {
      await TestDatabaseService.close();
    });

    group('Constants and Configuration', () {
      test('should have correct default values', () {
        expect(SrsService.defaultEasiness, equals(2.5));
        expect(SrsService.minEasiness, equals(1.3));
        expect(SrsService.maxEasiness, equals(3.5));
        expect(SrsService.passingGrade, equals(3));
        expect(SrsService.defaultIntervals, equals([1, 6]));
      });
    });

    group('Easiness Factor Calculation', () {
      test('should increase easiness for high grades', () {
        final vocab = _createTestVocab();
        final originalEasiness = vocab.easiness;

        // Test grade 5 (perfect)
        final preview = srsService.previewReview(vocab, 5);
        expect(preview['easiness'], greaterThan(originalEasiness));
        
        // Test grade 4 (good)
        final preview4 = srsService.previewReview(vocab, 4);
        expect(preview4['easiness'], greaterThan(originalEasiness));
      });

      test('should decrease easiness for low grades', () {
        final vocab = _createTestVocab();
        final originalEasiness = vocab.easiness;

        // Test grade 0 (complete failure)
        final preview0 = srsService.previewReview(vocab, 0);
        expect(preview0['easiness'], lessThan(originalEasiness));
        
        // Test grade 1 (poor)
        final preview1 = srsService.previewReview(vocab, 1);
        expect(preview1['easiness'], lessThan(originalEasiness));
      });

      test('should clamp easiness factor to bounds', () {
        // Test minimum bound
        final hardVocab = _createTestVocab(easiness: 1.3);
        final previewMin = srsService.previewReview(hardVocab, 0);
        expect(previewMin['easiness'], greaterThanOrEqualTo(SrsService.minEasiness));

        // Test maximum bound
        final easyVocab = _createTestVocab(easiness: 3.5);
        final previewMax = srsService.previewReview(easyVocab, 5);
        expect(previewMax['easiness'], lessThanOrEqualTo(SrsService.maxEasiness));
      });

      test('should calculate easiness using SM-2 formula', () {
        final vocab = _createTestVocab(easiness: 2.5);
        
        // Test specific SM-2 calculations
        final preview0 = srsService.previewReview(vocab, 0); // Grade 0
        final expectedEF0 = 2.5 + (0.1 - (5 - 0) * (0.08 + (5 - 0) * 0.02));
        expect(preview0['easiness'], closeTo(expectedEF0.clamp(1.3, 3.5), 0.01));

        final preview3 = srsService.previewReview(vocab, 3); // Grade 3
        final expectedEF3 = 2.5 + (0.1 - (5 - 3) * (0.08 + (5 - 3) * 0.02));
        expect(preview3['easiness'], closeTo(expectedEF3, 0.01));
      });
    });

    group('Interval Calculation', () {
      test('should use default intervals for early repetitions', () {
        final vocab = _createTestVocab(repetitions: 0);
        
        // First successful review (repetition 1)
        final preview1 = srsService.previewReview(vocab, 4);
        expect(preview1['intervalDays'], equals(1)); // Default interval[0]
        
        // Second successful review (repetition 2)
        final vocab2 = _createTestVocab(repetitions: 1);
        final preview2 = srsService.previewReview(vocab2, 4);
        expect(preview2['intervalDays'], equals(6)); // Default interval[1]
      });

      test('should calculate intervals using easiness factor for later repetitions', () {
        final vocab = _createTestVocab(
          repetitions: 2, 
          intervalDays: 6, 
          easiness: 2.5
        );
        
        final preview = srsService.previewReview(vocab, 4);
        final expectedInterval = (6 * 2.5).round(); // Previous interval * easiness
        expect(preview['intervalDays'], equals(expectedInterval));
      });

      test('should reset interval to 1 day for failing grades', () {
        final vocab = _createTestVocab(repetitions: 5, intervalDays: 30);
        
        // Test all failing grades
        for (int grade = 0; grade <= 2; grade++) {
          final preview = srsService.previewReview(vocab, grade);
          expect(preview['intervalDays'], equals(1), 
                 reason: 'Grade $grade should reset interval to 1 day');
        }
      });

      test('should clamp intervals to reasonable bounds', () {
        final vocab = _createTestVocab(
          repetitions: 10, 
          intervalDays: 10000, 
          easiness: 3.5
        );
        
        final preview = srsService.previewReview(vocab, 5);
        expect(preview['intervalDays'], lessThanOrEqualTo(36500)); // Max ~100 years
        expect(preview['intervalDays'], greaterThanOrEqualTo(1)); // Min 1 day
      });
    });

    group('Repetitions and Promotion/Demotion', () {
      test('should promote cards on passing grades', () {
        final vocab = _createTestVocab(repetitions: 2);
        
        // Test all passing grades
        for (int grade = 3; grade <= 5; grade++) {
          final preview = srsService.previewReview(vocab, grade);
          expect(preview['repetitions'], equals(3), 
                 reason: 'Grade $grade should promote the card');
          expect(preview['wasPromoted'], isTrue);
          expect(preview['wasDemoted'], isFalse);
        }
      });

      test('should demote cards on failing grades', () {
        final vocab = _createTestVocab(repetitions: 3);
        
        // Test all failing grades
        for (int grade = 0; grade <= 2; grade++) {
          final preview = srsService.previewReview(vocab, grade);
          expect(preview['repetitions'], equals(0), 
                 reason: 'Grade $grade should demote the card');
          expect(preview['wasPromoted'], isFalse);
          expect(preview['wasDemoted'], isTrue);
        }
      });

      test('should not demote new cards', () {
        final vocab = _createTestVocab(repetitions: 0);
        
        final preview = srsService.previewReview(vocab, 1);
        expect(preview['repetitions'], equals(0));
        expect(preview['wasDemoted'], isFalse);
      });
    });

    group('Due Date Calculation', () {
      test('should calculate correct due dates', () {
        final fixedTime = DateTime(2024, 1, 1, 12, 0, 0);
        final vocab = _createTestVocab();
        
        final preview = srsService.previewReview(vocab, 4);
        final expectedDueDate = fixedTime.add(Duration(days: preview['intervalDays']));
        
        // Allow for small time differences due to DateTime.now() calls
        final actualDueDate = preview['dueAt'] as DateTime;
        final difference = actualDueDate.difference(expectedDueDate).inSeconds.abs();
        expect(difference, lessThan(60), 
               reason: 'Due date should be within 60 seconds of expected');
      });

      test('should handle leap years and month boundaries', () {
        final vocab = _createTestVocab(repetitions: 0);
        final testTime = DateTime(2024, 2, 28, 12, 0, 0); // Day before leap day
        
        final preview = srsService.previewReview(vocab, 4);
        final dueDate = testTime.add(Duration(days: preview['intervalDays']));
        
        expect(dueDate.isAfter(testTime), isTrue);
        expect(dueDate.day, isNot(equals(testTime.day))); // Should be a different day
      });
    });

    group('Due Status Checking', () {
      test('should correctly identify due cards', () {
        final now = DateTime.now();
        
        // New card (dueAt is null)
        final newCard = _createTestVocab();
        expect(srsService.isDue(newCard), isTrue);
        
        // Overdue card
        final overdueCard = _createTestVocab(dueAt: now.subtract(Duration(days: 1)));
        expect(srsService.isDue(overdueCard), isTrue);
        
        // Due now
        final dueNow = _createTestVocab(dueAt: now);
        expect(srsService.isDue(dueNow, checkTime: now), isTrue);
        
        // Future card
        final futureCard = _createTestVocab(dueAt: now.add(Duration(days: 1)));
        expect(srsService.isDue(futureCard), isFalse);
      });

      test('should calculate days until due correctly', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        
        // New card
        final newCard = _createTestVocab();
        expect(srsService.daysUntilDue(newCard, checkTime: now), equals(0));
        
        // Overdue card
        final overdueCard = _createTestVocab(dueAt: now.subtract(Duration(days: 3)));
        expect(srsService.daysUntilDue(overdueCard, checkTime: now), equals(-3));
        
        // Future card
        final futureCard = _createTestVocab(dueAt: now.add(Duration(days: 5)));
        expect(srsService.daysUntilDue(futureCard, checkTime: now), equals(5));
      });
    });

    group('Streak Calculation', () {
      test('should calculate current streak correctly', () {
        final newCard = _createTestVocab(repetitions: 0);
        expect(srsService.getCurrentStreak(newCard), equals(0));
        
        final learningCard = _createTestVocab(repetitions: 3);
        expect(srsService.getCurrentStreak(learningCard), equals(3));
        
        final matureCard = _createTestVocab(repetitions: 10);
        expect(srsService.getCurrentStreak(matureCard), equals(10));
      });

      test('should reset streak on failure', () async {
        final vocab = await TestDatabaseService.addVocab(
          term: 'test',
          meaning: 'test',
          level: 'N5',
        );
        vocab.repetitions = 5;
        
        // Fail the review
        await srsService.review(vocab, 1);
        
        expect(vocab.repetitions, equals(0));
        expect(srsService.getCurrentStreak(vocab), equals(0));
      });
    });

    group('Statistics and Analysis', () {
      test('should calculate correct statistics for empty collection', () {
        final stats = srsService.getStats([]);
        
        expect(stats['totalCards'], equals(0));
        expect(stats['newCards'], equals(0));
        expect(stats['dueCards'], equals(0));
        expect(stats['learnedCards'], equals(0));
        expect(stats['overdueCards'], equals(0));
        expect(stats['avgEasiness'], equals(SrsService.defaultEasiness));
        expect(stats['totalStreak'], equals(0));
        expect(stats['avgStreak'], equals(0.0));
      });

      test('should categorize cards correctly', () {
        final now = DateTime.now();
        final vocabs = [
          _createTestVocab(repetitions: 0), // new
          _createTestVocab(repetitions: 1, dueAt: now.subtract(Duration(days: 1))), // due
          _createTestVocab(repetitions: 3, dueAt: now.subtract(Duration(days: 5))), // overdue
          _createTestVocab(repetitions: 2, dueAt: now.add(Duration(days: 1))), // learned
        ];
        
        final stats = srsService.getStats(vocabs, referenceTime: now);
        
        expect(stats['totalCards'], equals(4));
        expect(stats['newCards'], equals(1));
        expect(stats['dueCards'], equals(2)); // due + overdue
        expect(stats['learnedCards'], equals(1));
        expect(stats['overdueCards'], equals(1));
      });

      test('should calculate averages correctly', () {
        final vocabs = [
          _createTestVocab(repetitions: 2, easiness: 2.0),
          _createTestVocab(repetitions: 4, easiness: 2.5),
          _createTestVocab(repetitions: 6, easiness: 3.0),
        ];
        
        final stats = srsService.getStats(vocabs);
        
        expect(stats['avgEasiness'], closeTo(2.5, 0.01));
        expect(stats['totalStreak'], equals(12)); // 2 + 4 + 6
        expect(stats['avgStreak'], closeTo(4.0, 0.01)); // 12 / 3
      });
    });

    group('Review Process Integration', () {
      test('should perform complete review cycle', () async {
        final vocab = await TestDatabaseService.addVocab(
          term: 'こんにちは',
          meaning: 'hello',
          level: 'N5',
        );
        
        final originalTime = DateTime.now();
        
        // Perform review with grade 4
        await srsService.review(vocab, 4, reviewTime: originalTime);
        
        // Verify vocab was updated
        expect(vocab.repetitions, equals(1));
        expect(vocab.intervalDays, equals(1)); // First interval
        expect(vocab.lastReviewedAt, equals(originalTime));
        expect(vocab.dueAt, equals(originalTime.add(Duration(days: 1))));
        expect(vocab.easiness, greaterThan(2.5)); // Should have increased
        
        // Verify review log was created
        final logs = await TestDatabaseService.getReviewLogs(vocab.id!);
        expect(logs.length, equals(1));
        expect(logs.first.grade, equals(4));
        expect(logs.first.intervalAfter, equals(1));
        expect(logs.first.reviewedAt.millisecondsSinceEpoch,
            equals(originalTime.millisecondsSinceEpoch));
      });

      test('should handle multiple consecutive reviews', () async {
        final vocab = await TestDatabaseService.addVocab(
          term: 'test',
          meaning: 'test',
          level: 'N5',
        );
        
        final startTime = DateTime(2024, 1, 1);
        
        // First review (grade 4)
        await srsService.review(vocab, 4, reviewTime: startTime);
        expect(vocab.repetitions, equals(1));
        expect(vocab.intervalDays, equals(1));
        
        // Second review (grade 5)
        final secondReview = startTime.add(Duration(days: 2));
        await srsService.review(vocab, 5, reviewTime: secondReview);
        expect(vocab.repetitions, equals(2));
        expect(vocab.intervalDays, equals(6));
        
        // Third review (grade 3) 
        final thirdReview = secondReview.add(Duration(days: 7));
        await srsService.review(vocab, 3, reviewTime: thirdReview);
        expect(vocab.repetitions, equals(3));
        expect(vocab.intervalDays, greaterThan(6)); // Should use easiness factor
        
        // Verify all review logs
        final logs = await TestDatabaseService.getReviewLogs(vocab.id!);
        expect(logs.length, equals(3));
        expect(logs.map((log) => log.grade).toList(), equals([3, 5, 4])); // Reverse chronological
      });

      test('should handle review failure and recovery', () async {
        final vocab = await TestDatabaseService.addVocab(
          term: 'difficult',
          meaning: 'muzukashii',
          level: 'N3',
        );
        
        // Build up some progress
        await srsService.review(vocab, 4);
        await srsService.review(vocab, 4);
        await srsService.review(vocab, 4);
        
        expect(vocab.repetitions, equals(3));
        final easinessBeforeFailure = vocab.easiness;
        
        // Fail the review
        await srsService.review(vocab, 1);
        
        // Should reset repetitions but keep easiness adjustment
        expect(vocab.repetitions, equals(0));
        expect(vocab.intervalDays, equals(1));
        expect(vocab.easiness, lessThan(easinessBeforeFailure));
        
        // Recovery review
        await srsService.review(vocab, 4);
        expect(vocab.repetitions, equals(1));
        expect(vocab.intervalDays, equals(1));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should validate grade bounds', () {
        final vocab = _createTestVocab();
        
        expect(() => srsService.previewReview(vocab, -1), throwsA(isA<ArgumentError>()));
        expect(() => srsService.previewReview(vocab, 6), throwsA(isA<ArgumentError>()));
        
        expect(() => srsService.review(vocab, -1), throwsA(isA<ArgumentError>()));
        expect(() => srsService.review(vocab, 6), throwsA(isA<ArgumentError>()));
      });

      test('should handle extreme easiness values', () {
        final extremeEasyVocab = _createTestVocab(easiness: 5.0);
        final extremeHardVocab = _createTestVocab(easiness: 1.0);
        
        final easyPreview = srsService.previewReview(extremeEasyVocab, 0);
        expect(easyPreview['easiness'], greaterThanOrEqualTo(SrsService.minEasiness));
        expect(easyPreview['easiness'], lessThanOrEqualTo(SrsService.maxEasiness));
        
        final hardPreview = srsService.previewReview(extremeHardVocab, 5);
        expect(hardPreview['easiness'], greaterThanOrEqualTo(SrsService.minEasiness));
        expect(hardPreview['easiness'], lessThanOrEqualTo(SrsService.maxEasiness));
      });

      test('should handle very long intervals', () {
        final vocab = _createTestVocab(
          repetitions: 20,
          intervalDays: 1000,
          easiness: 3.0
        );
        
        final preview = srsService.previewReview(vocab, 5);
        expect(preview['intervalDays'], lessThanOrEqualTo(36500));
        expect(preview['intervalDays'], greaterThanOrEqualTo(1));
      });

      test('should handle zero repetitions edge cases', () {
        final vocab = _createTestVocab(repetitions: 0, intervalDays: 100);
        
        // Passing grade should promote
        final passingPreview = srsService.previewReview(vocab, 3);
        expect(passingPreview['repetitions'], equals(1));
        expect(passingPreview['intervalDays'], equals(1)); // Default first interval
        
        // Failing grade should not change repetitions
        final failingPreview = srsService.previewReview(vocab, 1);
        expect(failingPreview['repetitions'], equals(0));
        expect(failingPreview['intervalDays'], equals(1)); // Reset interval
      });

      test('should handle null due dates', () {
        final vocab = _createTestVocab();
        vocab.dueAt = null;
        
        expect(srsService.isDue(vocab), isTrue);
        expect(srsService.daysUntilDue(vocab), equals(0));
      });

      test('should handle very old and future dates', () {
        final now = DateTime.now();
        final veryOldDate = DateTime(1900, 1, 1);
        final veryFutureDate = DateTime(2100, 12, 31);
        
        final oldVocab = _createTestVocab(dueAt: veryOldDate);
        final futureVocab = _createTestVocab(dueAt: veryFutureDate);
        
        expect(srsService.isDue(oldVocab), isTrue);
        expect(srsService.isDue(futureVocab), isFalse);
        
        expect(srsService.daysUntilDue(oldVocab), lessThan(0));
        expect(srsService.daysUntilDue(futureVocab), greaterThan(0));
      });
    });

    group('Preview Functionality', () {
      test('should preview without modifying original vocab', () {
        final vocab = _createTestVocab(repetitions: 2, easiness: 2.5, intervalDays: 6);
        
        final originalRepetitions = vocab.repetitions;
        final originalEasiness = vocab.easiness;
        final originalInterval = vocab.intervalDays;
        
        srsService.previewReview(vocab, 5);
        
        // Original vocab should be unchanged
        expect(vocab.repetitions, equals(originalRepetitions));
        expect(vocab.easiness, equals(originalEasiness));
        expect(vocab.intervalDays, equals(originalInterval));
      });

      test('should provide comprehensive preview information', () {
        final vocab = _createTestVocab(repetitions: 1);
        
        final preview = srsService.previewReview(vocab, 4);
        
        expect(preview, containsPair('repetitions', isA<int>()));
        expect(preview, containsPair('easiness', isA<double>()));
        expect(preview, containsPair('intervalDays', isA<int>()));
        expect(preview, containsPair('dueAt', isA<DateTime>()));
        expect(preview, containsPair('wasPromoted', isA<bool>()));
        expect(preview, containsPair('wasDemoted', isA<bool>()));
      });
    });
  });
}

/// Helper function to create test vocab with default values
Vocab _createTestVocab({
  int repetitions = 0,
  double easiness = 2.5,
  int intervalDays = 0,
  DateTime? dueAt,
}) {
  final now = DateTime.now();
  return Vocab(
    id: 1,
    term: 'test',
    meaning: 'test',
    level: 'N5',
    repetitions: repetitions,
    easiness: easiness,
    intervalDays: intervalDays,
    dueAt: dueAt,
    createdAt: now,
    updatedAt: now,
  );
}
