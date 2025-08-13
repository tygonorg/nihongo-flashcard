import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/vocab.dart';
import 'package:go_router/go_router.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _State();
}

class _State extends State<QuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  final SettingsController settings = Get.find();
  late List<Vocab> pool;
  late int maxQuestions;
  int qIndex = 0;
  int correct = 0;
  List<Vocab> options = [];
  Vocab? current;
  bool? answerCorrect;

  @override
  void initState() {
    super.initState();
    Future.microtask(_newQuiz);
  }

  void _newQuiz() async {
    final result = await db.getAllVocabs(level: levelCtrl.selectedLevel.value);
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
    current = pool[qIndex];
    final rng = Random();
    final distractors = List<Vocab>.from(pool)..remove(current);
    distractors.shuffle();
    options = ([current!] + distractors.take(3).toList())..shuffle(rng);
  }

  void _finishQuiz() {
    final wrong = maxQuestions - correct;
    final percent = correct / maxQuestions * 100;
      if (percent >= 70) {
        context.go('/victory',
            extra: {'correct': correct, 'total': maxQuestions});
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
                  context.go('/');
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
    if (current == null || options.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: const Text('Trắc nghiệm')),
          body: const Center(child: Text('Chưa đủ dữ liệu.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trắc nghiệm')),
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
              child: Text(current!.term,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall),
            )),
            const SizedBox(height: 16),
            for (final o in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: answerCorrect == null
                      ? () {
                          final ok = o.id == current!.id;
                          if (ok) correct++;
                          setState(() => answerCorrect = ok);
                          Future.delayed(const Duration(seconds: 2), () {
                            final isLast = qIndex + 1 >= maxQuestions;
                            if (isLast) {
                              _finishQuiz();
                            } else {
                              setState(() {
                                qIndex++;
                                answerCorrect = null;
                                _nextQ();
                              });
                            }
                          });
                        }
                      : null,
                  child: Text(o.meaning),
                ),
              ),
            const SizedBox(height: 24),
            if (answerCorrect != null)
              Icon(
                answerCorrect! ? Icons.check_circle : Icons.close,
                color: answerCorrect! ? Colors.green : Colors.red,
                size: 64,
              ),
            const Spacer(),
            Text('Đúng: $correct', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
