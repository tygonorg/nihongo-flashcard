import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/vocab.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../widgets/level_chip.dart';
import '../widgets/vocab_tile.dart';

class VocabListScreen extends StatelessWidget {
  VocabListScreen({super.key});

  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    final levels = const ['N5', 'N4', 'N3', 'N2', 'N1'];

    if (!db.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Từ vựng')),
      body: Obx(() {
        final level = levelCtrl.selectedLevel.value;
        return Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  const SizedBox(width: 8),
                  LevelChip(
                      level: 'ALL',
                      selected: level == null,
                      onTap: () => levelCtrl.setLevel(null)),
                  for (final lv in levels)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: LevelChip(
                        level: lv,
                        selected: level == lv,
                        onTap: () => levelCtrl.setLevel(lv),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Vocab>>(
                future: db.getAllVocabs(level: level),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Lỗi: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  final vocabs = snapshot.data ?? [];

                  if (vocabs.isEmpty) {
                    return const Center(
                      child: Text('Chưa có từ vựng nào. Hãy thêm từ mới!'),
                    );
                  }

                  return ListView.builder(
                    itemCount: vocabs.length,
                    itemBuilder: (_, i) => VocabTile(
                      vocabs[i],
                      onTap: () => context.push('/add', extra: vocabs[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'vocabListFab',
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
