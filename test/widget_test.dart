// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nihongo_mvp/app.dart';
import 'package:nihongo_mvp/services/realm_service.dart';
import 'package:nihongo_mvp/providers/providers.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Mock RealmService for testing
    final mockRealmService = RealmService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          realmServiceProvider.overrideWithValue(mockRealmService),
        ],
        child: const NihongoApp(),
      ),
    );

    // Just verify that the app launches
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
