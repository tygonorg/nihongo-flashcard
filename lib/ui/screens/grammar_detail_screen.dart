import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/grammar.dart';

class GrammarDetailScreen extends StatefulWidget {
  final Grammar grammar;
  const GrammarDetailScreen({super.key, required this.grammar});

  @override
  State<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends State<GrammarDetailScreen> {
  late SharedPreferences _prefs;
  bool _bookmarked = false;
  late TextEditingController _noteController;
  String _search = '';
  double _fontSize = 16;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final key = widget.grammar.title;
    _bookmarked = _prefs.getBool('grammar_bookmark_$key') ?? false;
    _noteController.text = _prefs.getString('grammar_note_$key') ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _toggleBookmark() async {
    setState(() => _bookmarked = !_bookmarked);
    await _prefs.setBool(
        'grammar_bookmark_${widget.grammar.title}', _bookmarked);
  }

  Future<void> _saveNote() async {
    await _prefs.setString(
        'grammar_note_${widget.grammar.title}', _noteController.text);
  }

  Future<void> _searchContent() async {
    final q = await showSearch<String>(
        context: context, delegate: _GrammarSearchDelegate());
    if (q != null) {
      setState(() {
        _search = q;
      });
    }
  }

  TextSpan _buildHighlighted(String text) {
    if (_search.isEmpty) {
      return TextSpan(text: text, style: TextStyle(fontSize: _fontSize));
    }
    final lcText = text.toLowerCase();
    final lcQuery = _search.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final index = lcText.indexOf(lcQuery, start);
      if (index < 0) {
        spans.add(TextSpan(
            text: text.substring(start),
            style: TextStyle(fontSize: _fontSize)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(
            text: text.substring(start, index),
            style: TextStyle(fontSize: _fontSize)));
      }
      spans.add(TextSpan(
          text: text.substring(index, index + _search.length),
          style: TextStyle(
              fontSize: _fontSize, backgroundColor: Colors.yellow)));
      start = index + _search.length;
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.grammar;
    return Scaffold(
      appBar: AppBar(
        title: Text(g.title),
        actions: [
          IconButton(
              onPressed: _searchContent, icon: const Icon(Icons.search)),
          IconButton(
            icon: Icon(
                _bookmarked ? Icons.bookmark : Icons.bookmark_border_outlined),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            RichText(text: _buildHighlighted(g.meaning)),
            if (g.example != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(text: _buildHighlighted('Ví dụ: ${g.example}')),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextField(
                key: const Key('noteField'),
                controller: _noteController,
                maxLines: null,
                decoration: const InputDecoration(
                    labelText: 'Ghi chú', border: OutlineInputBorder()),
                onChanged: (_) => _saveNote(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: () => setState(() => _fontSize += 2),
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: () =>
                setState(() => _fontSize = _fontSize > 12 ? _fontSize - 2 : 12),
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}

class _GrammarSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => close(context, query),
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}
