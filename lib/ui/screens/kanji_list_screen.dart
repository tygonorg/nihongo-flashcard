import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/kanji.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../widgets/level_chip.dart';
import '../widgets/kanji_tile.dart';

class KanjiListScreen extends StatelessWidget {
  KanjiListScreen({super.key});

  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

    if (!db.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kanji')),
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
              child: FutureBuilder<List<Kanji>>(
                future: db.getAllKanjis(level: level),
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
                  final kanjis = snapshot.data ?? [];
                  if (kanjis.isEmpty) {
                    return const Center(
                      child: Text('Chưa có kanji nào. Hãy thêm mới!'),
                    );
                  }
                  return ListView.builder(
                    itemCount: kanjis.length,
                    itemBuilder: (_, i) => KanjiTile(
                      kanjis[i],
                      onTap: () =>
                          context.push('/kanji-add', extra: kanjis[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/kanji-add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
