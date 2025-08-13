import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/vocab.dart';
import 'victory_screen.dart';

class MatchingQuizScreen extends StatefulWidget {
  const MatchingQuizScreen({super.key});
  @override
  State<MatchingQuizScreen> createState() => _State();
}

class _State extends State<MatchingQuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  final SettingsController settings = Get.find();
  late List<Vocab> pool;
  List<Vocab> terms = [];
  List<Vocab> meanings = [];
  Vocab? selectedTerm;
  Vocab? selectedMeaning;
  int correctSets = 0;
  late int maxSets;

  @override
  void initState() {
    super.initState();
    Future.microtask(_newQuiz);
  }

  void _newQuiz() async {
    final result =
        await db.getAllVocabs(level: levelCtrl.selectedLevel.value);
    result.shuffle();
    maxSets = min(settings.quizLength.value, result.length ~/ 3);
    pool = result.take(maxSets * 3).toList();
    correctSets = 0;
    _nextSet();
    setState(() {});
  }

  void _nextSet() {
    final start = correctSets * 3;
    if (start >= pool.length) {
      _finishQuiz();
      return;
    }
    final currentSet = pool.sublist(start, start + 3);
    terms = List<Vocab>.from(currentSet);
    meanings = List<Vocab>.from(currentSet)..shuffle(Random());
    selectedTerm = null;
    selectedMeaning = null;
  }

  void _checkMatch() {
    if (selectedTerm != null && selectedMeaning != null) {
      final ok = selectedTerm!.id == selectedMeaning!.id;
      if (ok) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đúng!')));
        terms.remove(selectedTerm);
        meanings.remove(selectedMeaning);
        selectedTerm = null;
        selectedMeaning = null;
        if (terms.isEmpty) {
          correctSets++;
          if (correctSets >= maxSets) {
            _finishQuiz();
          } else {
            _nextSet();
          }
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Sai')));
        selectedTerm = null;
        selectedMeaning = null;
      }
      setState(() {});
    }
  }

  void _finishQuiz() {
    final wrong = maxSets - correctSets;
    final percent = correctSets / maxSets * 100;
    if (percent >= 70) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                VictoryScreen(correct: correctSets, total: maxSets)),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kết quả'),
          content: Text(
              'Điểm: $correctSets/$maxSets\nĐúng: $correctSets\nSai: $wrong\nTỉ lệ: ${percent.toStringAsFixed(1)}%'),
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
    if (terms.isEmpty || meanings.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: const Text('Matching')),
          body: const Center(child: Text('Chưa đủ dữ liệu.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Matching')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (final t in terms)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: t == selectedTerm
                                      ? Colors.blueAccent
                                      : null),
                              onPressed: () {
                                setState(() => selectedTerm = t);
                                _checkMatch();
                              },
                              child: Text(t.term),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        for (final m in meanings)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: m == selectedMeaning
                                      ? Colors.green
                                      : null),
                              onPressed: () {
                                setState(() => selectedMeaning = m);
                                _checkMatch();
                              },
                              child: Text(m.meaning),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Hoàn thành: $correctSets',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

