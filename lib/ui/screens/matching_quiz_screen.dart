import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../models/vocab.dart';

class MatchingQuizScreen extends StatefulWidget {
  const MatchingQuizScreen({super.key});
  @override
  State<MatchingQuizScreen> createState() => _State();
}

class _State extends State<MatchingQuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  late List<Vocab> pool;
  List<Vocab> terms = [];
  List<Vocab> meanings = [];
  Vocab? selectedTerm;
  Vocab? selectedMeaning;
  int correctSets = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_newQuiz);
  }

  void _newQuiz() async {
    pool = await db.getAllVocabs(level: levelCtrl.selectedLevel.value);
    correctSets = 0;
    _nextSet();
    setState(() {});
  }

  void _nextSet() {
    if (pool.length < 3) return;
    pool.shuffle();
    final currentSet = pool.take(3).toList();
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
          _nextSet();
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

