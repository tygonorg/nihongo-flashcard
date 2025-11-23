import 'package:flutter/material.dart';
import '../../models/kanji.dart';
import '../../locator.dart';
import '../../services/database_service.dart';

class AddEditKanjiScreen extends StatefulWidget {
  final Kanji? kanji;
  const AddEditKanjiScreen({super.key, this.kanji});

  @override
  State<AddEditKanjiScreen> createState() => _State();
}

class _State extends State<AddEditKanjiScreen> {
  final _formKey = GlobalKey<FormState>();
  String _character = '';
  String _onyomi = '';
  String _kunyomi = '';
  String _meaning = '';
  String _hanviet = '';
  String _level = 'N5';
  final DatabaseService db = locator<DatabaseService>();

  @override
  void initState() {
    super.initState();
    if (widget.kanji != null) {
      _character = widget.kanji!.character;
      _onyomi = widget.kanji!.onyomi;
      _kunyomi = widget.kanji!.kunyomi;
      _meaning = widget.kanji!.meaning;
      _hanviet = widget.kanji!.hanviet;
      _level = widget.kanji!.level;
    }
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.kanji == null ? 'Thêm kanji' : 'Sửa kanji')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _character,
              decoration: const InputDecoration(labelText: 'Kanji'),
              onSaved: (v) => _character = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập kanji' : null,
            ),
            TextFormField(
              initialValue: _onyomi,
              decoration: const InputDecoration(labelText: 'Onyomi'),
              onSaved: (v) => _onyomi = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập onyomi' : null,
            ),
            TextFormField(
              initialValue: _kunyomi,
              decoration: const InputDecoration(labelText: 'Kunyomi'),
              onSaved: (v) => _kunyomi = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập kunyomi' : null,
            ),
            TextFormField(
              initialValue: _meaning,
              decoration: const InputDecoration(labelText: 'Nghĩa'),
              onSaved: (v) => _meaning = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập nghĩa' : null,
            ),
            TextFormField(
              initialValue: _hanviet,
              decoration: const InputDecoration(labelText: 'Hán Việt'),
              onSaved: (v) => _hanviet = v!.trim(),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập Hán Việt' : null,
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Cấp độ'),
              initialValue: _level,
              items: const ['N5','N4','N3','N2','N1']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _level = v as String),
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
                          content: Text('Cơ sở dữ liệu chưa được khởi tạo. Vui lòng thử lại.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (widget.kanji == null) {
                      await db.addKanji(
                        character: _character,
                        onyomi: _onyomi,
                        kunyomi: _kunyomi,
                        meaning: _meaning,
                        hanviet: _hanviet,
                        level: _level,
                      );
                    } else {
                      await db.updateKanji(
                        widget.kanji!,
                        character: _character,
                        onyomi: _onyomi,
                        kunyomi: _kunyomi,
                        meaning: _meaning,
                        hanviet: _hanviet,
                        level: _level,
                      );
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.kanji == null
                            ? 'Đã thêm kanji'
                            : 'Đã cập nhật kanji'),
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
