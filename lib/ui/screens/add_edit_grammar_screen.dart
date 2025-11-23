import 'package:flutter/material.dart';
import '../../models/grammar.dart';
import '../widgets/simple_markdown_editor.dart';

class AddEditGrammarScreen extends StatefulWidget {
  final Grammar? grammar;
  const AddEditGrammarScreen({super.key, this.grammar});

  @override
  State<AddEditGrammarScreen> createState() => _AddEditGrammarScreenState();
}

class _AddEditGrammarScreenState extends State<AddEditGrammarScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _meaning = '';
  String _level = 'N5';
  String? _example;
  String _content = '';

  @override
  void initState() {
    super.initState();
    final g = widget.grammar;
    if (g != null) {
      _title = g.title;
      _meaning = g.meaning;
      _level = g.level;
      _example = g.example;
      _content = g.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.grammar == null ? 'Thêm ngữ pháp' : 'Sửa ngữ pháp')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
              onSaved: (v) => _title = v!.trim(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tiêu đề' : null,
            ),
            TextFormField(
              initialValue: _meaning,
              decoration: const InputDecoration(labelText: 'Nghĩa'),
              onSaved: (v) => _meaning = v!.trim(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập nghĩa' : null,
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Cấp độ'),
              initialValue: _level,
              items: const ['N5', 'N4', 'N3', 'N2', 'N1']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _level = v as String),
            ),
            TextFormField(
              initialValue: _example,
              decoration: const InputDecoration(labelText: 'Ví dụ'),
              onSaved: (v) =>
                  _example = (v?.trim().isEmpty ?? true) ? null : v!.trim(),
            ),
            SimpleMarkdownEditor(
              labelText: 'Nội dung',
              maxLines: 10,
              initialValue: _content,
              onChanged: (value) => _content = value,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập nội dung' : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Lưu'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final grammar = Grammar(
                      title: _title,
                      meaning: _meaning,
                      level: _level,
                      example: _example,
                      content: _content);
                  Navigator.pop(context, grammar);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
