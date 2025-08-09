import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Cỡ chữ'),
            subtitle: Text(settings.fontSize.toStringAsFixed(0)),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                min: 12,
                max: 30,
                value: settings.fontSize,
                onChanged: (v) => ref.read(settingsProvider.notifier).setFontSize(v),
              ),
            ),
          ),
          ListTile(
            title: const Text('Màu chủ đạo'),
            trailing: DropdownButton<MaterialColor>(
              value: settings.primaryColor,
              items: const [
                DropdownMenuItem(value: Colors.blue, child: Text('Xanh dương')),
                DropdownMenuItem(value: Colors.red, child: Text('Đỏ')),
                DropdownMenuItem(value: Colors.green, child: Text('Xanh lá')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(settingsProvider.notifier).setColor(v);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Số câu hỏi mỗi lần'),
            trailing: DropdownButton<int>(
              value: settings.quizLength,
              items: const [5, 10, 20, 50]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  ref.read(settingsProvider.notifier).setQuizLength(v);
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Âm thanh'),
            value: settings.soundEnabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setSound(v),
          ),
        ],
      ),
    );
  }
}
