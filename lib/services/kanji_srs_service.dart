import '../models/kanji.dart';
import 'database_service.dart';

class KanjiSrsService {
  final DatabaseService db;

  static const double defaultEasiness = 2.5;
  static const double minEasiness = 1.3;
  static const double maxEasiness = 3.5;
  static const int passingGrade = 3;
  static const List<int> defaultIntervals = [1, 6];

  KanjiSrsService(this.db);

  Future<void> review(Kanji kanji, int grade, {DateTime? reviewTime}) async {
    if (grade < 0 || grade > 5) {
      throw ArgumentError('Grade must be between 0 and 5, got: $grade');
    }

    final now = reviewTime ?? DateTime.now();
    final isPassing = grade >= passingGrade;

    final newRepetitions = _calculateRepetitions(kanji.repetitions, isPassing);
    final newEasiness = _calculateEasiness(kanji.easiness, grade);
    final newInterval =
        _calculateInterval(newRepetitions, newEasiness, kanji.intervalDays, isPassing);

    kanji.repetitions = newRepetitions;
    kanji.easiness = newEasiness;
    kanji.intervalDays = newInterval;
    kanji.lastReviewedAt = now;
    kanji.dueAt = _calculateDueDate(now, newInterval);
    kanji.updatedAt = now;

    await db.updateKanjiSrsData(kanji);
    await db.addKanjiReviewLog(
      kanji: kanji,
      grade: grade,
      nextInterval: newInterval,
      reviewedAt: now,
    );
  }

  int _calculateRepetitions(int currentRepetitions, bool isPassing) {
    if (isPassing) {
      return currentRepetitions + 1;
    } else {
      return 0;
    }
  }

  double _calculateEasiness(double currentEasiness, int grade) {
    final newEasiness =
        currentEasiness + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    return newEasiness.clamp(minEasiness, maxEasiness);
  }

  int _calculateInterval(
      int repetitions, double easiness, int previousInterval, bool isPassing) {
    if (!isPassing) {
      return 1;
    }
    if (repetitions <= defaultIntervals.length) {
      return defaultIntervals[repetitions - 1];
    }
    return (previousInterval * easiness).round().clamp(1, 36500);
  }

  DateTime _calculateDueDate(DateTime reviewTime, int intervalDays) {
    return reviewTime.add(Duration(days: intervalDays));
  }

  bool isDue(Kanji kanji, {DateTime? checkTime}) {
    final now = checkTime ?? DateTime.now();
    return kanji.dueAt == null || kanji.dueAt!.isBefore(now) || kanji.dueAt!.isAtSameMomentAs(now);
  }
}
