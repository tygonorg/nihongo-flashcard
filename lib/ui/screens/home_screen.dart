import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../models/vocab.dart';
import '../../models/kanji.dart';
import '../../controllers/level_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
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
          final cs = Theme.of(context).colorScheme;
          final text = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero banner with streak & daily XP goal
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('🔥 ', style: text.headlineMedium),
                        Text('Giữ chuỗi học hôm nay!',
                            style: text.titleLarge?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Tiến độ: mục tiêu 20 XP',
                        style: text.bodyMedium?.copyWith(color: cs.onPrimary)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (data.vocabCount + data.kanjiCount) == 0
                            ? 0
                            : (data.vocabCount % 20) / 20.0,
                        minHeight: 10,
                        backgroundColor:
                            cs.onPrimary.withOpacity(0.25),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(cs.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick stats chips
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Từ vựng', style: text.labelMedium),
                            const SizedBox(height: 6),
                            Text('${data.vocabCount}',
                                style: text.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kanji', style: text.labelMedium),
                            const SizedBox(height: 6),
                            Text('${data.kanjiCount}',
                                style: text.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text('Bắt đầu học nhanh', style: text.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  _QuickBtn(
                      icon: Icons.quiz,
                      label: '4 lựa chọn',
                      onTap: () => _selectLevel(context, '/quiz')),
                  _QuickBtn(
                      icon: Icons.check_circle,
                      label: 'Đúng / Sai',
                      onTap: () => _selectLevel(context, '/quiz-tf')),
                  _QuickBtn(
                      icon: Icons.border_color,
                      label: 'Điền khuyết',
                      onTap: () => _selectLevel(context, '/quiz-fill')),
                  _QuickBtn(
                      icon: Icons.link,
                      label: 'Matching',
                      onTap: () => _selectLevel(context, '/quiz-match')),
                  _QuickBtn(
                      icon: Icons.timer,
                      label: 'Time Attack',
                      onTap: () => _selectLevel(context, '/quiz-time')),
                ],
              ),

              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/stats'),
                child: const Text('Xem thống kê chi tiết'),
              ),

              const SizedBox(height: 16),
              Text('Từ vựng mới thêm', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final v in data.recentVocabs)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Text(v.term.isNotEmpty ? v.term[0] : '?'),
                    ),
                    title: Text(v.term),
                    subtitle: Text(v.meaning),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Kanji gần đây', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final k in data.recentKanjis)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.secondaryContainer,
                      child: Text(k.character),
                    ),
                    title: Text(k.character),
                    subtitle: Text(k.meaning),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<_HomeData> _load(DatabaseService db) async {
    final vocabs = await db.getAllVocabs();
    final kanjis = await db.getAllKanjis();
    return _HomeData(
      vocabs.length,
      kanjis.length,
      vocabs.take(5).toList(),
      kanjis.take(5).toList(),
    );
  }

  void _selectLevel(BuildContext context, String route) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chọn cấp độ',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final lv in levels)
                    ChoiceChip(
                      label: Text(lv),
                      selected: false,
                      onSelected: (_) {
                        levelCtrl.setLevel(lv);
                        Navigator.pop(context);
                        context.push(route);
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.onPrimaryContainer),
            const SizedBox(width: 8),
            Text(label,
                style: text.labelLarge?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
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
