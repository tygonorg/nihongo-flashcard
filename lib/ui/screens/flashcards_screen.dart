import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/vocab.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});
  @override
  ConsumerState<FlashcardsScreen> createState() => _State();
}

class _State extends ConsumerState<FlashcardsScreen> {
  List<Vocab> deck = [];
  int index = 0;
  bool reveal = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDeck);
  }

  void _loadDeck() async {
    final db = ref.read(databaseServiceProvider);
    final vocabs = await db.getDueVocabs(limit: 50, level: ref.read(selectedLevelProvider));
    deck = vocabs;
    deck.shuffle(Random());
    setState(() {
      index = 0;
      reveal = false;
    });
  }

  void _grade(int g) async {
    final srs = ref.read(srsProvider);
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
