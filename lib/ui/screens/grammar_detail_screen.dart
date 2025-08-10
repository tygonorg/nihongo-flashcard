import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../models/grammar.dart';

class GrammarDetailScreen extends StatefulWidget {
  final Grammar grammar;
  const GrammarDetailScreen({super.key, required this.grammar});

  @override
  State<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends State<GrammarDetailScreen> {
  double _fontSize = 16;

  @override
  Widget build(BuildContext context) {
    final g = widget.grammar;
    return Scaffold(
      appBar: AppBar(
        title: Text(g.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => setState(() => _fontSize += 2),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => setState(() {
              if (_fontSize > 12) _fontSize -= 2;
            }),
          ),
        ],
      ),
      body: Markdown(
        data: g.content,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
            .copyWith(p: TextStyle(fontSize: _fontSize)),
      ),
    );
  }
}
