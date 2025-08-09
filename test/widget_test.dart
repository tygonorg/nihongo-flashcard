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
import 'test_database_helper.dart';

void main() {
  group('Widget Tests', () {
    setUp(() async {
      // Initialize test database before each test
      await TestDatabaseService.initialize();
      await TestDatabaseService.reset();
    });

    tearDown(() async {
      // Clean up after each test
      await TestDatabaseService.reset();
    });

    testWidgets('App launches without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: NihongoApp(),
        ),
      );

      // Just verify that the app launches
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App can be built multiple times', (WidgetTester tester) async {
      // Test that we can rebuild the app without issues
      // (this verifies our database isolation works)
      
      await tester.pumpWidget(
        const ProviderScope(
          child: NihongoApp(),
        ),
      );
      
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Rebuild
      await tester.pumpWidget(
        const ProviderScope(
          child: NihongoApp(),
        ),
      );
      
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
