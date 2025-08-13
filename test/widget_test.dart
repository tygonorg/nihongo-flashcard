// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nihongo_flashcard/app.dart';
import 'package:nihongo_flashcard/locator.dart';
import 'package:nihongo_flashcard/services/database_service.dart';
import 'package:nihongo_flashcard/models/vocab.dart';
import 'package:nihongo_flashcard/models/kanji.dart';
import 'test_database_helper.dart';

class FakeDatabaseService extends DatabaseService {
  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<Vocab>> getAllVocabs({String? level}) async => [];

  @override
  Future<List<Kanji>> getAllKanjis({String? level}) async => [];
}

void main() {
  group('Widget Tests', () {
    setUp(() async {
      await locator.reset();
      locator.registerSingleton<DatabaseService>(FakeDatabaseService());
      // Initialize test database before each test (unused but keeps DB logic)
      await TestDatabaseService.initialize();
      await TestDatabaseService.reset();
    });

    tearDown(() async {
      // Clean up after each test
      await TestDatabaseService.reset();
      await locator.reset();
    });

    testWidgets('App launches without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const NihongoApp(),
      );

      // Just verify that the app launches
      expect(find.byType(GetMaterialApp), findsOneWidget);
    });

    testWidgets('App can be built multiple times', (WidgetTester tester) async {
      // Test that we can rebuild the app without issues
      // (this verifies our database isolation works)

      await tester.pumpWidget(
        const NihongoApp(),
      );

      expect(find.byType(GetMaterialApp), findsOneWidget);

      // Rebuild
      await tester.pumpWidget(
        const NihongoApp(),
      );

      expect(find.byType(GetMaterialApp), findsOneWidget);
    });
  });
}
