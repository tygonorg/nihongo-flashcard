import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../models/vocab.dart';

class TrueFalseQuizScreen extends StatefulWidget {
  const TrueFalseQuizScreen({super.key});
  @override
  State<TrueFalseQuizScreen> createState() => _State();
}

class _State extends State<TrueFalseQuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  late List<Vocab> pool;
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
    pool = await db.getAllVocabs(level: levelCtrl.selectedLevel.value);
    qIndex = 0;
    correct = 0;
    _nextQ();
    setState(() {});
  }

  void _nextQ() {
    if (pool.isEmpty) return;
    pool.shuffle();
    current = pool.first;
    final rng = Random();
    final distractors = List<Vocab>.from(pool)..remove(current);
    distractors.shuffle();
    final showCorrect = rng.nextBool();
    displayedMeaning = showCorrect && current != null
        ? current!.meaning
        : distractors.isNotEmpty
            ? distractors.first.meaning
            : current!.meaning;
    answerIsTrue = showCorrect || displayedMeaning == current!.meaning;
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

