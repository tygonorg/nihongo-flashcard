import 'package:flutter/material.dart';
import '../../models/grammar.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class AddEditGrammarScreen extends StatefulWidget {
  const AddEditGrammarScreen({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm ngữ pháp')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
              onSaved: (v) => _title = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tiêu đề' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nghĩa'),
              onSaved: (v) => _meaning = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập nghĩa' : null,
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Cấp độ'),
              value: _level,
              items: const ['N5','N4','N3','N2','N1']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _level = v as String),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Ví dụ'),
              onSaved: (v) => _example = (v?.trim().isEmpty ?? true) ? null : v!.trim(),
            ),
            FormField<String>(
              validator: (_) =>
                  _content.trim().isEmpty ? 'Nhập nội dung' : null,
              builder: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownTextInput(
                    (String value) {
                      _content = value;
                      state.didChange(value);
                    },
                    _content,
                    label: 'Nội dung',
                    maxLines: 10,
                    actions: MarkdownType.values,
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
              ),
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
