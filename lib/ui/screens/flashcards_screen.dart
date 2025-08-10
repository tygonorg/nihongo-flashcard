import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../models/vocab.dart';
import '../../services/database_service.dart';
import '../../services/srs_service.dart';
import '../../controllers/level_controller.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});
  @override
  State<FlashcardsScreen> createState() => _State();
}

class _State extends State<FlashcardsScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final SrsService srs = locator<SrsService>();
  final LevelController levelCtrl = Get.find();

  List<Vocab> deck = [];
  int index = 0;
  bool reveal = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDeck);
  }

  void _loadDeck() async {
    final vocabs = await db.getDueVocabs(
        limit: 50, level: levelCtrl.selectedLevel.value);
    deck = vocabs;
    deck.shuffle(Random());
    setState(() {
      index = 0;
      reveal = false;
    });
  }

  void _grade(int g) async {
    await srs.review(deck[index], g);
    if (index < deck.length - 1) {
      setState(() {
        index++;
        reveal = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Hoàn thành lượt ôn!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (deck.isEmpty) {
      return Scaffold(
            appBar: AppBar(title: const Text('Flashcards')),
            body: const Center(
                child: Text('Không có thẻ đến hạn. Hãy thêm từ hoặc đổi cấp.')));
    }

    final v = deck[index];

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${index + 1}/${deck.length} • ${v.level}'),
            const SizedBox(height: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => reveal = !reveal),
                child: Card(
                  child: Center(
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      firstChild: Text(v.term,
                          style: Theme.of(context).textTheme.displayMedium),
                      secondChild: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(v.meaning,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          if (v.note != null) ...[
                            const SizedBox(height: 8),
                            Text(v.note!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]
                        ],
                      ),
                      crossFadeState: reveal
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                      onPressed: () => _grade(0), child: const Text('Quên')),
                  OutlinedButton(
                      onPressed: () => _grade(2), child: const Text('Khó')),
                  FilledButton(
                      onPressed: () => _grade(4), child: const Text('Tốt')),
                  FilledButton.tonal(
                      onPressed: () => _grade(5), child: const Text('Rất tốt')),
                ])
          ],
        ),
      ),
    );
  }
}
