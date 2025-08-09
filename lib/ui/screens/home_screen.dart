import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/vocab.dart';
import '../../models/kanji.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseServiceProvider);
    if (!db.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: FutureBuilder<_HomeData>(
        future: _load(db),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Tổng số từ vựng'),
                  trailing: Text('${data.vocabCount}'),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Tổng số kanji'),
                  trailing: Text('${data.kanjiCount}'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Từ vựng mới thêm'),
              const SizedBox(height: 8),
              for (final v in data.recentVocabs)
                ListTile(title: Text(v.term), subtitle: Text(v.meaning)),
              const SizedBox(height: 16),
              const Text('Kanji gần đây'),
              const SizedBox(height: 8),
              for (final k in data.recentKanjis)
                ListTile(title: Text(k.character), subtitle: Text(k.meaning)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/stats'),
                child: const Text('Xem thống kê chi tiết'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_HomeData> _load(db) async {
    final vocabs = await db.getAllVocabs();
    final kanjis = await db.getAllKanjis();
    return _HomeData(
      vocabs.length,
      kanjis.length,
      vocabs.take(5).toList(),
      kanjis.take(5).toList(),
    );
  }
}

class _HomeData {
  final int vocabCount;
  final int kanjiCount;
  final List<Vocab> recentVocabs;
  final List<Kanji> recentKanjis;
  _HomeData(
      this.vocabCount, this.kanjiCount, this.recentVocabs, this.recentKanjis);
}
