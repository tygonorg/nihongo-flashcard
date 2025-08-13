import 'package:flutter/material.dart';
import '../../models/vocab.dart';
import '../../locator.dart';
import '../../services/database_service.dart';

class AddEditVocabScreen extends StatefulWidget {
  final Vocab? vocab;
  const AddEditVocabScreen({super.key, this.vocab});
  @override
  State<AddEditVocabScreen> createState() => _State();
}

class _State extends State<AddEditVocabScreen> {
  final _formKey = GlobalKey<FormState>();
  String _term = '';
  String _hiragana = '';
  String _meaning = '';
  String _level = 'N5';
  String? _note;
  final DatabaseService db = locator<DatabaseService>();

  @override
  void initState() {
    super.initState();
    if (widget.vocab != null) {
      _term = widget.vocab!.term;
      _hiragana = widget.vocab!.hiragana;
      _meaning = widget.vocab!.meaning;
      _level = widget.vocab!.level;
      _note = widget.vocab!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vocab == null ? 'Thêm từ' : 'Sửa từ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _term,
              decoration: const InputDecoration(labelText: 'Từ (kanji/kana)'),
              onSaved: (v) => _term = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập từ' : null,
            ),
            TextFormField(
              initialValue: _hiragana,
              decoration: const InputDecoration(labelText: 'Hiragana'),
              onSaved: (v) => _hiragana = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập hiragana' : null,
            ),
            TextFormField(
              initialValue: _meaning,
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
              initialValue: _note,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
              onSaved: (v) => _note = (v?.trim().isEmpty ?? true) ? null : v!.trim(),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    try {
                      if (!db.isInitialized) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Cơ sở dữ liệu chưa được khởi tạo. Vui lòng thử lại.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (widget.vocab == null) {
                        await db.addVocab(
                            term: _term,
                            hiragana: _hiragana,
                            meaning: _meaning,
                            level: _level,
                            note: _note);
                      } else {
                        await db.updateVocab(
                            widget.vocab!,
                            term: _term,
                            hiragana: _hiragana,
                            meaning: _meaning,
                            level: _level,
                            note: _note);
                      }

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.vocab == null
                                ? 'Đã thêm từ vựng'
                                : 'Đã cập nhật từ vựng'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                },
              )
            ],
          ),
        ),
      );
  }
}