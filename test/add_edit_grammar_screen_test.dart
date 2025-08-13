import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_flashcard/models/grammar.dart';
import 'package:nihongo_flashcard/ui/screens/add_edit_grammar_screen.dart';

void main() {
  testWidgets('AddEditGrammarScreen returns new grammar on save',
      (tester) async {
    Grammar? result;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await Navigator.push<Grammar>(
              context,
              MaterialPageRoute(builder: (_) => const AddEditGrammarScreen()),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Tiêu đề'), 'ている');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nghĩa'), 'đang làm');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Ví dụ'), '本を読んでいる');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nội dung'), 'content');

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.title, 'ている');
    expect(result!.meaning, 'đang làm');
    expect(result!.example, '本を読んでいる');
    expect(result!.content, 'content');
  });

  testWidgets('AddEditGrammarScreen prefills data when editing',
      (tester) async {
    final grammar = Grammar(
      title: 'は',
      meaning: 'chủ đề',
      level: 'N5',
      example: '猫はかわいい',
      content: 'content',
    );

    await tester
        .pumpWidget(MaterialApp(home: AddEditGrammarScreen(grammar: grammar)));

    expect(find.text('は'), findsOneWidget);
    expect(find.text('chủ đề'), findsOneWidget);
    expect(find.text('猫はかわいい'), findsOneWidget);
  });
}
