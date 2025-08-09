import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/grammar.dart';

class GrammarListScreen extends StatefulWidget {
  const GrammarListScreen({super.key});

  @override
  State<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends State<GrammarListScreen> {
  List<Grammar>? _grammars;
  bool _loading = true;
  String? _error;
  String _level = 'n5';

  static const _levels = ['n5', 'n4', 'n3', 'n2', 'n1'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw =
          await rootBundle.loadString('assets/presets/grammar_$_level.json');
      final list = jsonDecode(raw) as List;
      _grammars =
          list.map((e) => Grammar.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = e.toString();
      _grammars = null;
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _changeLevel(String? level) {
    if (level == null || level == _level) return;
    setState(() {
      _level = level;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ngữ pháp')),
        body: Center(child: Text('Lỗi: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ngữ pháp ${_level.toUpperCase()}'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('levelDropdown'),
              value: _level,
              onChanged: _changeLevel,
              items: _levels
                  .map((l) =>
                      DropdownMenuItem(value: l, child: Text(l.toUpperCase())))
                  .toList(),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _grammars?.length ?? 0,
        itemBuilder: (context, index) {
          final g = _grammars![index];
          return ListTile(
            title: Text(
              g.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.meaning),
                if (g.example != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('Ví dụ: ${g.example}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
