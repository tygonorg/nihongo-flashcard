import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../models/kanji.dart';

class KanjiQuizScreen extends StatefulWidget {
  const KanjiQuizScreen({super.key});
  @override
  State<KanjiQuizScreen> createState() => _State();
}

class _State extends State<KanjiQuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  late List<Kanji> pool;
  int qIndex = 0;
  int correct = 0;
  List<Kanji> options = [];
  Kanji? current;

  @override
  void initState() {
    super.initState();
    Future.microtask(_newQuiz);
  }

    void _newQuiz() async {
      final result =
          await db.getAllKanjis(level: levelCtrl.selectedLevel.value);
      pool = result;
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
    final distractors = List<Kanji>.from(pool)..remove(current);
    distractors.shuffle();
    options = ([current!] + distractors.take(3).toList())..shuffle(rng);
  }

  @override
  Widget build(BuildContext context) {
    if (current == null || options.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: const Text('Trắc nghiệm Kanji')),
          body: const Center(child: Text('Chưa đủ dữ liệu.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trắc nghiệm Kanji')),
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
              child: Text(current!.character,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall),
            )),
            const SizedBox(height: 16),
            for (final o in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    final ok = o.id == current!.id;
                    if (ok) correct++;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(ok ? 'Đúng!' : 'Sai: ${current!.meaning}')));
                    setState(() {
                      qIndex++;
                      _nextQ();
                    });
                  },
                  child: Text(o.meaning),
                ),
              ),
            const Spacer(),
            Text('Đúng: $correct', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
