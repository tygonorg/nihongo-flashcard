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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/presets/grammar_n5.json');
      final list = jsonDecode(raw) as List;
      _grammars =
          list.map((e) => Grammar.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
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
      appBar: AppBar(title: const Text('Ngữ pháp N5')),
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
