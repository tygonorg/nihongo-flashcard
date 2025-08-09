// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib/app.dart';
import '../lib/services/database_service.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Initialize DatabaseService for testing
    final databaseService = DatabaseService.instance;
    await databaseService.initialize();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: NihongoApp(),
      ),
    );

    // Just verify that the app launches
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
