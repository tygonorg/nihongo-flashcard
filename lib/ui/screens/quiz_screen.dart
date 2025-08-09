import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/vocab.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});
  @override
  ConsumerState<QuizScreen> createState() => _State();
}

class _State extends ConsumerState<QuizScreen> {
  late List<Vocab> pool;
  int qIndex = 0;
  int correct = 0;
  List<Vocab> options = [];
  Vocab? current;

  @override
  void initState() {
    super.initState();
    Future.microtask(_newQuiz);
  }

  void _newQuiz() async {
    final db = ref.read(realmServiceProvider);
    final result = await db.allVocabs(level: ref.read(selectedLevelProvider));
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
    final distractors = List<Vocab>.from(pool)..remove(current);
    distractors.shuffle();
    options = ([current!] + distractors.take(3).toList())..shuffle(rng);
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
