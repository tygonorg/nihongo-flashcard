import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vocab.dart';
import '../../providers/providers.dart';

class AddEditVocabScreen extends ConsumerStatefulWidget {
  final Vocab? vocab;
  const AddEditVocabScreen({super.key, this.vocab});
  @override
  ConsumerState<AddEditVocabScreen> createState() => _State();
}

class _State extends ConsumerState<AddEditVocabScreen> {
  final _formKey = GlobalKey<FormState>();
  String _term = '';
  String _meaning = '';
  String _level = 'N5';
  String? _note;

  @override
  void initState() {
    super.initState();
    if (widget.vocab != null) {
      _term = widget.vocab!.term;
      _meaning = widget.vocab!.meaning;
      _level = widget.vocab!.level;
      _note = widget.vocab!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(realmServiceProvider);
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
                          content: Text('Cơ sở dữ liệu chưa được khởi tạo. Vui lòng thử lại.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (widget.vocab == null) {
                      final result = await db.addVocab(
                        term: _term, 
                        meaning: _meaning, 
                        level: _level, 
                        note: _note
                      );
                      
                      if (result == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không thể thêm từ vựng. Vui lòng thử lại.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    } else {
                      await db.updateVocab(
                        widget.vocab!, 
                        term: _term, 
                        meaning: _meaning, 
                        level: _level, 
                        note: _note
                      );
                    }
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.vocab == null ? 'Đã thêm từ vựng' : 'Đã cập nhật từ vựng'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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