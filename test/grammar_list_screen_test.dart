import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo_flashcard/ui/screens/add_edit_grammar_screen.dart';
import 'package:nihongo_flashcard/ui/screens/grammar_list_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:nihongo_flashcard/models/grammar.dart';

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
      GoRoute(
        path: '/grammar-add',
        builder: (context, state) {
          final grammar = state.extra as Grammar?;
          return AddEditGrammarScreen(grammar: grammar);
        },
      ),
    ]);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Tiêu đề'), 'テスト');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nghĩa'), 'test meaning');
    await tester.enterText(find.widgetWithText(TextFormField, 'Ví dụ'), '例');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nội dung'), 'content');

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text('テスト'), findsOneWidget);
  });

  testWidgets('can edit grammar via context menu', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const GrammarListScreen()),
      GoRoute(
        path: '/grammar-add',
        builder: (context, state) {
          final grammar = state.extra as Grammar?;
          return AddEditGrammarScreen(grammar: grammar);
        },
      ),
    ]);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('は').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Tiêu đề'), 'はね');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text('はね'), findsOneWidget);
  });
}
