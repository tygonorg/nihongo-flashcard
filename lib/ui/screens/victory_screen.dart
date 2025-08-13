import 'package:flutter/material.dart';

class VictoryScreen extends StatelessWidget {
  final int correct;
  final int total;

  const VictoryScreen({super.key, required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final wrong = total - correct;
    final percent = (correct / total * 100).toStringAsFixed(1);
    return Scaffold(
      appBar: AppBar(title: const Text('Chiến thắng')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Điểm: $correct / $total',
                style: Theme.of(context).textTheme.headlineSmall),
            Text('Đúng: $correct'),
            Text('Sai: $wrong'),
            Text('Tỉ lệ: $percent%'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hoàn thành'),
            )
          ],
        ),
      ),
    );
  }
}

