import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/ui/screens/grammar_list_screen.dart';

void main() {
  testWidgets('GrammarListScreen loads and displays items', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GrammarListScreen()));

    // Wait for asset loading
    await tester.pumpAndSettle();

    expect(find.text('Ngữ pháp N5'), findsOneWidget);
    expect(find.text('は'), findsOneWidget);
    expect(find.text('trợ từ chỉ chủ đề'), findsOneWidget);
  });
}
