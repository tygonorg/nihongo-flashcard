import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_mvp/services/realm_service.dart';

void main() {
  if (!Platform.isAndroid && !Platform.isIOS) {
    print('Test này chỉ chạy trên Android hoặc iOS.');
    return;
  }
  group('Tạo từ vựng N5', () {
    late RealmService db;

    setUp(() async {
      db = RealmService();
      await db.initialize();
    });

    test('Thêm một số từ N5', () async {
      final words = [
        {'term': '水', 'meaning': 'nước', 'level': 'N5'},
        {'term': '火', 'meaning': 'lửa', 'level': 'N5'},
        {'term': '山', 'meaning': 'núi', 'level': 'N5'},
        {'term': '川', 'meaning': 'sông', 'level': 'N5'},
        {'term': '空', 'meaning': 'bầu trời', 'level': 'N5'},
      ];
      for (final w in words) {
        final v = await db.addVocab(
            term: w['term']!, meaning: w['meaning']!, level: w['level']!);
        expect(v, isNotNull);
        expect(v!.term, w['term']);
        expect(v.meaning, w['meaning']);
        expect(v.level, w['level']);
      }
    });
  });
}
