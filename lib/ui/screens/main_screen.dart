import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'vocab_list_screen.dart';
import 'grammar_list_screen.dart';
import 'kanji_list_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static final _screens = [
    HomeScreen(),
    VocabListScreen(),
    const GrammarListScreen(),
    KanjiListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Từ vựng'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Ngữ pháp'),
          BottomNavigationBarItem(icon: Icon(Icons.text_fields), label: 'Kanji'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
