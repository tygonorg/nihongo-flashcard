import '../models/vocab.dart';
import 'database_service.dart';

class SrsService {
  final DatabaseService db;
  SrsService(this.db);

  /// grade: 0..5 (0 = quên sạch, 5 = nhớ rất tốt)
  Future<void> review(Vocab vocab, int grade) async {
    final now = DateTime.now();

    final repetitions = grade >= 3 ? vocab.repetitions + 1 : 0;
    double ef = vocab.easiness + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
    if (ef < 1.3) ef = 1.3;

    int interval;
    if (repetitions <= 1) {
      interval = 1; // ngày
    } else if (repetitions == 2) {
      interval = 6;
    } else {
      interval = (vocab.intervalDays * ef).round();
    }

    // Cập nhật vocab
    vocab.repetitions = repetitions;
    vocab.easiness = ef;
    vocab.intervalDays = interval;
    vocab.lastReviewedAt = now;
    vocab.dueAt = now.add(Duration(days: interval));
    vocab.updatedAt = now;
    
    await db.updateVocabSrsData(vocab);

    await db.addReviewLog(
      vocab: vocab, 
      grade: grade, 
      nextInterval: vocab.intervalDays
    );
  }
}
