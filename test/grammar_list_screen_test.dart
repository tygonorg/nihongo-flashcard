import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo_flashcard/ui/screens/add_edit_grammar_screen.dart';
import 'package:nihongo_flashcard/ui/screens/grammar_list_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('GrammarListScreen loads and displays items', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GrammarListScreen()));

    // Wait for asset loading
    await tester.pumpAndSettle();

    expect(find.text('Ngữ pháp N5'), findsOneWidget);
    expect(find.text('は'), findsOneWidget);
    expect(find.text('trợ từ chỉ chủ đề'), findsOneWidget);
  });

  testWidgets('GrammarListScreen allows level selection', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GrammarListScreen()));

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('levelDropdown')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('N4').last);
    await tester.pumpAndSettle();

    expect(find.text('Ngữ pháp N4'), findsOneWidget);
    expect(find.text('べきだ'), findsOneWidget);
  });

  testWidgets('can add new grammar via AddEditGrammarScreen', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const GrammarListScreen()),
      GoRoute(path: '/grammar-add', builder: (_, __) => const AddEditGrammarScreen()),
    ]);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Tiêu đề'), 'テスト');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nghĩa'), 'test meaning');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Ví dụ'), '例');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nội dung'), 'content');

    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('テスト'), findsOneWidget);
  });
}
