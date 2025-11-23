import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _imagePath;
  final DatabaseService db = locator<DatabaseService>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.vocab != null) {
      _term = widget.vocab!.term;
      _hiragana = widget.vocab!.hiragana;
      _meaning = widget.vocab!.meaning;
      _level = widget.vocab!.level;
      _note = widget.vocab!.note;
      _imagePath = widget.vocab!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
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
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                          },
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Thêm ảnh minh hoạ', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
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
              initialValue: _level,
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
                            note: _note,
                            imagePath: _imagePath);
                      } else {
                        await db.updateVocab(
                            widget.vocab!,
                            term: _term,
                            hiragana: _hiragana,
                            meaning: _meaning,
                            level: _level,
                            note: _note,
                            imagePath: _imagePath);
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