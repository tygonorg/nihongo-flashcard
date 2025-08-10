import 'package:flutter/material.dart';

class SimpleMarkdownEditor extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onChanged;
  final String? labelText;
  final int? maxLines;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const SimpleMarkdownEditor({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.labelText,
    this.maxLines = 10,
    this.controller,
    this.validator,
  });

  @override
  State<SimpleMarkdownEditor> createState() => _SimpleMarkdownEditorState();
}

class _SimpleMarkdownEditorState extends State<SimpleMarkdownEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    widget.onChanged(_controller.text);
  }

  void _wrapSelection(String prefix, [String suffix = '']) {
    final currentText = _controller.text;
    final selection = _controller.selection;
    final text = selection.textInside(currentText);
    final newText = '$prefix$text$suffix';

    final newSelection = selection.copyWith(
      baseOffset: selection.baseOffset + prefix.length,
      extentOffset: selection.extentOffset + prefix.length,
    );

    _controller.value = _controller.value.copyWith(
      text: currentText.replaceRange(selection.start, selection.end, newText),
      selection: newSelection,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Thanh công cụ định dạng
              IconButton(
                icon: const Text('B',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _wrapSelection('**', '**'),
                tooltip: 'In đậm',
              ),
              IconButton(
                icon: const Text('I',
                    style: TextStyle(fontStyle: FontStyle.italic)),
                onPressed: () => _wrapSelection('*', '*'),
                tooltip: 'In nghiêng',
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () {
                  final text =
                      _controller.selection.textInside(_controller.text);
                  final lines = text.split('\n');
                  final newText = lines.map((line) => '- $line').join('\n');
                  _wrapSelection(newText);
                },
                tooltip: 'Danh sách không thứ tự',
              ),
              IconButton(
                icon: const Icon(Icons.format_list_numbered),
                onPressed: () {
                  final text =
                      _controller.selection.textInside(_controller.text);
                  final lines = text.split('\n');
                  final newText = lines
                      .asMap()
                      .entries
                      .map((e) => '${e.key + 1}. ${e.value}')
                      .join('\n');
                  _wrapSelection(newText);
                },
                tooltip: 'Danh sách có thứ tự',
              ),
              IconButton(
                icon: const Icon(Icons.format_quote),
                onPressed: () => _wrapSelection('> '),
                tooltip: 'Trích dẫn',
              ),
              IconButton(
                icon: const Text('`'),
                onPressed: () => _wrapSelection('`', '`'),
                tooltip: 'Code inline',
              ),
              IconButton(
                icon: const Icon(Icons.code),
                onPressed: () => _wrapSelection('\n```\n', '\n```\n'),
                tooltip: 'Code block',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            labelText: widget.labelText,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
          validator: widget.validator,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }
}
