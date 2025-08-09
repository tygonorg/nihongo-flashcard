import '../models/vocab.dart';
import 'database_service.dart';

/// Spaced Repetition System (SRS) Service implementing a modified SM-2 algorithm
/// 
/// Grade scale:
/// - 0: Complete failure (forgot completely) 
/// - 1: Incorrect response but remembered upon seeing correct answer
/// - 2: Incorrect response but correct answer seemed familiar
/// - 3: Correct response with serious difficulty
/// - 4: Correct response with hesitation
/// - 5: Perfect response
class SrsService {
  final DatabaseService db;
  
  /// Default easiness factor for new cards
  static const double defaultEasiness = 2.5;
  
  /// Minimum allowed easiness factor
  static const double minEasiness = 1.3;
  
  /// Maximum allowed easiness factor
  static const double maxEasiness = 3.5;
  
  /// Passing grade threshold (3 or higher = successful review)
  static const int passingGrade = 3;
  
  /// Default intervals for the first few repetitions
  static const List<int> defaultIntervals = [1, 6];
  
  SrsService(this.db);

  /// Process a review and update the vocab's SRS data
  /// 
  /// [vocab] - The vocabulary item being reviewed
  /// [grade] - User's performance grade (0-5)
  /// [reviewTime] - Optional custom review time (defaults to now)
  Future<void> review(Vocab vocab, int grade, {DateTime? reviewTime}) async {
    if (grade < 0 || grade > 5) {
      throw ArgumentError('Grade must be between 0 and 5, got: $grade');
    }
    
    final now = reviewTime ?? DateTime.now();
    final isPassing = grade >= passingGrade;
    
    // Calculate new repetitions count
    final newRepetitions = _calculateRepetitions(vocab.repetitions, isPassing);
    
    // Calculate new easiness factor
    final newEasiness = _calculateEasiness(vocab.easiness, grade);
    
    // Calculate next interval
    final newInterval = _calculateInterval(newRepetitions, newEasiness, vocab.intervalDays, isPassing);
    
    // Update vocab with new SRS data
    vocab.repetitions = newRepetitions;
    vocab.easiness = newEasiness;
    vocab.intervalDays = newInterval;
    vocab.lastReviewedAt = now;
    vocab.dueAt = _calculateDueDate(now, newInterval);
    vocab.updatedAt = now;

    await db.updateVocabSrsData(vocab);

    await db.addReviewLog(
      vocab: vocab,
      grade: grade,
      nextInterval: newInterval,
      reviewedAt: now,
    );
  }
  
  /// Calculate new repetitions count based on performance
  int _calculateRepetitions(int currentRepetitions, bool isPassing) {
    if (isPassing) {
      return currentRepetitions + 1;
    } else {
      // Reset repetitions to 0 for failing grades (demotion)
      return 0;
    }
  }
  
  /// Calculate new easiness factor using modified SM-2 algorithm
  double _calculateEasiness(double currentEasiness, int grade) {
    // SM-2 formula: EF' = EF + (0.1 - (5-q)*(0.08+(5-q)*0.02))
    // where q is the grade (0-5) and EF is the current easiness factor
    final newEasiness = currentEasiness + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    
    // Clamp the easiness factor to reasonable bounds
    return newEasiness.clamp(minEasiness, maxEasiness);
  }
  
  /// Calculate next review interval based on repetitions and easiness
  int _calculateInterval(int repetitions, double easiness, int previousInterval, bool isPassing) {
    if (!isPassing) {
      // For failing grades, use a short interval (typically 1 day)
      return 1;
    }
    
    // Use predefined intervals for first few repetitions
    if (repetitions <= defaultIntervals.length) {
      return defaultIntervals[repetitions - 1];
    }
    
    // For subsequent repetitions, multiply previous interval by easiness factor
    return (previousInterval * easiness).round().clamp(1, 36500); // Max ~100 years
  }
  
  /// Calculate the due date for next review
  DateTime _calculateDueDate(DateTime reviewTime, int intervalDays) {
    return reviewTime.add(Duration(days: intervalDays));
  }
  
  /// Get the next suggested review interval without updating the vocab
  /// Useful for previewing what would happen with different grades
    Map<String, dynamic> previewReview(Vocab vocab, int grade, {DateTime? reviewTime}) {
      if (grade < 0 || grade > 5) {
        throw ArgumentError('Grade must be between 0 and 5, got: $grade');
      }

      final isPassing = grade >= passingGrade;
      final newRepetitions = _calculateRepetitions(vocab.repetitions, isPassing);
      final newEasiness = _calculateEasiness(vocab.easiness, grade);
      final newInterval = _calculateInterval(newRepetitions, newEasiness, vocab.intervalDays, isPassing);
      final newDueDate = _calculateDueDate(reviewTime ?? DateTime.now(), newInterval);

      return {
        'repetitions': newRepetitions,
        'easiness': newEasiness,
        'intervalDays': newInterval,
        'dueAt': newDueDate,
        'wasPromoted': isPassing && vocab.repetitions < newRepetitions,
        'wasDemoted': !isPassing && vocab.repetitions > 0,
      };
    }
  
  /// Check if a vocab is due for review
  bool isDue(Vocab vocab, {DateTime? checkTime}) {
    final now = checkTime ?? DateTime.now();
    return vocab.dueAt == null || vocab.dueAt!.isBefore(now) || vocab.dueAt!.isAtSameMomentAs(now);
  }
  
  /// Get the number of days until next review (negative if overdue)
  int daysUntilDue(Vocab vocab, {DateTime? checkTime}) {
    final now = checkTime ?? DateTime.now();
    if (vocab.dueAt == null) {
      return 0; // Consider new cards as due now
    }
    return vocab.dueAt!.difference(now).inDays;
  }
  
  /// Calculate streak information for a vocabulary item
  /// Returns current streak of successful reviews
  int getCurrentStreak(Vocab vocab) {
    // In the simplified model, current repetitions represent the streak
    return vocab.repetitions;
  }
  
  /// Get SRS statistics for analysis
  Map<String, dynamic> getStats(List<Vocab> vocabs, {DateTime? referenceTime}) {
    final now = referenceTime ?? DateTime.now();
    
    int newCards = 0;
    int dueCards = 0;
    int learnedCards = 0;
    int overdueCards = 0;
    double avgEasiness = 0;
    int totalStreak = 0;
    
    for (final vocab in vocabs) {
      if (vocab.repetitions == 0) {
        newCards++;
      } else if (isDue(vocab, checkTime: now)) {
        dueCards++;
        final daysOverdue = daysUntilDue(vocab, checkTime: now);
        if (daysOverdue < -1) { // More than 1 day overdue
          overdueCards++;
        }
      } else {
        learnedCards++;
      }
      
      avgEasiness += vocab.easiness;
      totalStreak += getCurrentStreak(vocab);
    }
    
    final totalCards = vocabs.length;
    avgEasiness = totalCards > 0 ? avgEasiness / totalCards : defaultEasiness;
    
    return {
      'totalCards': totalCards,
      'newCards': newCards,
      'dueCards': dueCards,
      'learnedCards': learnedCards,
      'overdueCards': overdueCards,
      'avgEasiness': avgEasiness,
      'totalStreak': totalStreak,
      'avgStreak': totalCards > 0 ? totalStreak / totalCards : 0.0,
    };
  }
}
