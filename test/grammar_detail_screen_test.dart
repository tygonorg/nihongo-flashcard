import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo_flashcard/models/grammar.dart';
import 'package:nihongo_flashcard/ui/screens/grammar_detail_screen.dart';

void main() {
  testWidgets('GrammarDetailScreen shows markdown content and zoom icons',
      (tester) async {
    final grammar = Grammar(
      title: 'test',
      meaning: 'm',
      level: 'n5',
      content: 'Nội dung **markdown**',
    );

    await tester.pumpWidget(
        MaterialApp(home: GrammarDetailScreen(grammar: grammar)));
    await tester.pumpAndSettle();

    expect(find.text('Nội dung markdown'), findsOneWidget);
    expect(find.byIcon(Icons.zoom_in), findsOneWidget);
    expect(find.byIcon(Icons.zoom_out), findsOneWidget);
  });
}
