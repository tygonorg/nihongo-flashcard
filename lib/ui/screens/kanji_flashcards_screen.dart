import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/kanji.dart';

class KanjiFlashcardsScreen extends ConsumerStatefulWidget {
  const KanjiFlashcardsScreen({super.key});
  @override
  ConsumerState<KanjiFlashcardsScreen> createState() => _State();
}

class _State extends ConsumerState<KanjiFlashcardsScreen> {
  List<Kanji> deck = [];
  int index = 0;
  bool reveal = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDeck);
  }

  void _loadDeck() async {
    final db = ref.read(databaseServiceProvider);
    final kanjis = await db.getDueKanjis(
        limit: 50, level: ref.read(selectedLevelProvider));
    deck = kanjis;
    deck.shuffle(Random());
    setState(() {
      index = 0;
      reveal = false;
    });
  }

  void _grade(int g) async {
    final srs = ref.read(kanjiSrsProvider);
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
          appBar: AppBar(title: const Text('Kanji Flashcards')),
          body: const Center(
              child: Text('Không có thẻ đến hạn. Hãy thêm kanji hoặc đổi cấp.')));
    }

    final k = deck[index];

    return Scaffold(
      appBar: AppBar(title: const Text('Kanji Flashcards')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${index + 1}/${deck.length} • ${k.level}'),
            const SizedBox(height: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => reveal = !reveal),
                child: Card(
                  child: Center(
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      firstChild: Text(k.character,
                          style: Theme.of(context).textTheme.displayMedium),
                      secondChild: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(k.meaning,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text('On: ${k.onyomi}'),
                          Text('Kun: ${k.kunyomi}'),
                          Text('Âm Hán: ${k.hanviet}'),
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
