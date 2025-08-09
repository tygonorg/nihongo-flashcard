import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vocab.dart';
import '../../providers/providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(realmServiceProvider);
    
    if (!db.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê & Kế hoạch ôn')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadStats(db),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }
          
          final stats = snapshot.data!;
          final total = stats['total'] as int;
          final due = stats['due'] as int;
          final byLevel = stats['byLevel'] as Map<String, int>;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                  child: ListTile(
                      title: const Text('Tổng số từ'), trailing: Text('$total'))),
              Card(
                  child: ListTile(
                      title: const Text('Đến hạn ôn hôm nay'),
                      trailing: Text('$due'))),
              const SizedBox(height: 12),
              const Text('Theo cấp độ:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in byLevel.entries.toList())
                    Chip(label: Text('${e.key}: ${e.value}')),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Mẹo học thông minh:'),
              const SizedBox(height: 8),
              const Text('''• Ôn ít nhất 10–20 thẻ đến hạn mỗi ngày.
• Đánh giá trung thực (Quên/Khó/Tốt/Rất tốt).
• Thêm ghi chú gợi nhớ cá nhân.
• Giữ mức độ tập trung theo level.'''),
            ],
          );
        },
      ),
    );
  }
  
  Future<Map<String, dynamic>> _loadStats(db) async {
    final allVocabs = await db.allVocabs();
    final dueVocabs = await db.dueVocabs(limit: 100000);
    
    final Map<String, int> byLevel = {};
    for (final lv in ['N5', 'N4', 'N3', 'N2', 'N1']) {
      final levelVocabs = await db.allVocabs(level: lv);
      byLevel[lv] = levelVocabs.length;
    }
    
    return {
      'total': allVocabs.length,
      'due': dueVocabs.length,
      'byLevel': byLevel,
    };
  }
}
