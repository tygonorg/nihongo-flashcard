import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final gridCount = isTablet ? 3 : 2;
    final items = [
      _HomeItem(Icons.list_alt, 'Danh sách', '/list'),
      _HomeItem(Icons.add_circle, 'Thêm từ', '/add'),
      _HomeItem(Icons.style, 'Flashcards', '/flash'),
      _HomeItem(Icons.quiz, 'Trắc nghiệm', '/quiz'),
      _HomeItem(Icons.auto_awesome, 'Thống kê & SRS', '/stats'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nihongo – Học từ vựng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: gridCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            for (final it in items)
              InkWell(
                onTap: () => context.push(it.route),
                child: Card(
                  elevation: 1,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(it.icon, size: 40), const SizedBox(height: 12), Text(it.title)],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  final IconData icon; final String title; final String route;
  _HomeItem(this.icon, this.title, this.route);
}
