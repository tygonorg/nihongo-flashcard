import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../models/vocab.dart';
import 'package:go_router/go_router.dart';

class TimeAttackQuizScreen extends StatefulWidget {
  const TimeAttackQuizScreen({super.key});
  @override
  State<TimeAttackQuizScreen> createState() => _State();
}

class _State extends State<TimeAttackQuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  List<Vocab> pool = [];
  Vocab? current;
  List<Vocab> options = [];
  int correct = 0;
  int total = 0;
  int remaining = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_start);
  }

  Future<void> _start() async {
    final result = await db.getAllVocabs(level: levelCtrl.selectedLevel.value);
    if (result.isEmpty) return;
    pool = result..shuffle();
    _nextQ();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remaining <= 1) {
        t.cancel();
        _finishQuiz();
      } else {
        setState(() => remaining--);
      }
    });
    setState(() {});
  }

  void _nextQ() {
    if (pool.isEmpty) return;
    if (total >= pool.length) {
      pool.shuffle();
      total = 0;
    }
    current = pool[total];
    final rng = Random();
    final distractors = List<Vocab>.from(pool)..remove(current);
    distractors.shuffle();
    options = ([current!] + distractors.take(3).toList())..shuffle(rng);
  }

  void _answer(Vocab selected) {
    if (selected.id == current!.id) correct++;
    total++;
    _nextQ();
    setState(() {});
  }

  void _finishQuiz() {
    timer?.cancel();
    context.go('/victory', extra: {'correct': correct, 'total': total});
  }

  @override
  Widget build(BuildContext context) {
    if (current == null || options.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: const Text('Time Attack')),
          body: const Center(child: Text('Chưa đủ dữ liệu.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Time Attack')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Thời gian: $remaining',
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
                  onPressed: () => _answer(o),
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

