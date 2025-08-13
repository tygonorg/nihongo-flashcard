import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/vocab.dart';
import 'victory_screen.dart';

class TrueFalseQuizScreen extends StatefulWidget {
  const TrueFalseQuizScreen({super.key});
  @override
  State<TrueFalseQuizScreen> createState() => _State();
}

class _State extends State<TrueFalseQuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  final SettingsController settings = Get.find();
  late List<Vocab> pool;
  late int maxQuestions;
  int qIndex = 0;
  int correct = 0;
  Vocab? current;
  String displayedMeaning = '';
  bool answerIsTrue = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_newQuiz);
  }

  void _newQuiz() async {
    final result =
        await db.getAllVocabs(level: levelCtrl.selectedLevel.value);
    result.shuffle();
    maxQuestions = min(settings.quizLength.value, result.length);
    pool = result.take(maxQuestions).toList();
    qIndex = 0;
    correct = 0;
    _nextQ();
    setState(() {});
  }

  void _nextQ() {
    if (qIndex >= maxQuestions) {
      _finishQuiz();
      return;
    }
    final rng = Random();
    current = pool[qIndex];
    final distractors = List<Vocab>.from(pool)..remove(current);
    distractors.shuffle();
    final showCorrect = rng.nextBool();
    displayedMeaning = showCorrect
        ? current!.meaning
        : distractors.isNotEmpty
            ? distractors.first.meaning
            : current!.meaning;
    answerIsTrue = displayedMeaning == current!.meaning;
  }

  void _finishQuiz() {
    final wrong = maxQuestions - correct;
    final percent = correct / maxQuestions * 100;
    if (percent >= 70) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => VictoryScreen(correct: correct, total: maxQuestions)),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kết quả'),
          content: Text(
              'Điểm: $correct/$maxQuestions\nĐúng: $correct\nSai: $wrong\nTỉ lệ: ${percent.toStringAsFixed(1)}%'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (current == null || displayedMeaning.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: const Text('Đúng/Sai')),
          body: const Center(child: Text('Chưa đủ dữ liệu.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Đúng/Sai')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Câu ${qIndex + 1}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
                child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(current!.term,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 12),
                  Text(displayedMeaning,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final ok = answerIsTrue;
                if (ok) correct++;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Đúng!' : 'Sai')));
                setState(() {
                  qIndex++;
                  _nextQ();
                });
              },
              child: const Text('Đúng'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final ok = !answerIsTrue;
                if (ok) correct++;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Đúng!' : 'Sai')));
                setState(() {
                  qIndex++;
                  _nextQ();
                });
              },
              child: const Text('Sai'),
            ),
            const Spacer(),
            Text('Đúng: $correct', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

