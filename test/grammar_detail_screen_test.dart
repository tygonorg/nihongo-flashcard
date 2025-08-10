import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/ui/screens/grammar_detail_screen.dart';
import '../lib/models/grammar.dart';

void main() {
  testWidgets('GrammarDetailScreen shows content and toggles bookmark',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final grammar = Grammar(
        title: 'test', meaning: 'meaning example', level: 'n5', example: 'ex');

    await tester.pumpWidget(
        MaterialApp(home: GrammarDetailScreen(grammar: grammar)));
    await tester.pumpAndSettle();

    expect(find.text('meaning example'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_border_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });
}
