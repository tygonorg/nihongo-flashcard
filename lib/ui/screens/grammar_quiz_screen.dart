import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../models/grammar.dart';

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  List<Grammar> pool = [];
  int qIndex = 0;
  int correct = 0;
  List<Grammar> options = [];
  Grammar? current;
  String _level = 'n5';
  static const _levels = ['n5', 'n4', 'n3', 'n2', 'n1'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw =
          await rootBundle.loadString('assets/presets/grammar_$_level.json');
      final list = jsonDecode(raw) as List;
      pool =
          list.map((e) => Grammar.fromMap(e as Map<String, dynamic>)).toList();
      _nextQ();
      setState(() {});
    } catch (e) {
      // ignore: avoid_print
      print('Error loading grammar: $e');
      setState(() {});
    }
  }

  void _nextQ() {
    if (pool.isEmpty) return;
    pool.shuffle();
    current = pool.first;
    final rng = Random();
    final distractors = List<Grammar>.from(pool)..remove(current);
    distractors.shuffle(rng);
    final optionCount = min(4, pool.length);
    options = ([current!] + distractors.take(optionCount - 1).toList())
      ..shuffle(rng);
  }

  void _changeLevel(String? level) {
    if (level == null || level == _level) return;
    setState(() {
      _level = level;
      pool = [];
      options = [];
      current = null;
      qIndex = 0;
      correct = 0;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (current == null || options.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Trắc nghiệm Ngữ pháp ${_level.toUpperCase()}'),
            actions: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  key: const Key('levelDropdownQuiz'),
                  value: _level,
                  onChanged: _changeLevel,
                  items: _levels
                      .map((l) => DropdownMenuItem(
                          value: l, child: Text(l.toUpperCase())))
                      .toList(),
                ),
              )
            ],
          ),
          body: const Center(child: Text('Chưa đủ dữ liệu.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trắc nghiệm Ngữ pháp ${_level.toUpperCase()}'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('levelDropdownQuiz'),
              value: _level,
              onChanged: _changeLevel,
              items: _levels
                  .map((l) =>
                      DropdownMenuItem(value: l, child: Text(l.toUpperCase())))
                  .toList(),
            ),
          )
        ],
      ),
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
              child: Text(current!.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall),
            )),
            const SizedBox(height: 16),
            for (final o in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    final ok = o.title == current!.title;
                    if (ok) correct++;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(ok ? 'Đúng!' : 'Sai: ${current!.meaning}'),
                      ),
                    );
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
