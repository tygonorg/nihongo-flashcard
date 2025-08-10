import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/grammar.dart';

void main() {
  group('Grammar Model Tests', () {
    test('creates Grammar with required fields', () {
      final grammar = Grammar(
        title: 'は',
        meaning: 'trợ từ chỉ chủ đề',
        level: 'N5',
        content: 'content',
      );

      expect(grammar.title, 'は');
      expect(grammar.meaning, 'trợ từ chỉ chủ đề');
      expect(grammar.level, 'N5');
      expect(grammar.example, isNull);
    });

    test('creates Grammar with example', () {
      final grammar = Grammar(
        title: 'が',
        meaning: 'trợ từ chỉ chủ thể',
        level: 'N5',
        example: '猫が好きです。',
        content: 'content',
      );

      expect(grammar.example, '猫が好きです。');
    });

    test('toMap includes non-null fields only', () {
      final grammar = Grammar(
        title: 'は',
        meaning: 'trợ từ chỉ chủ đề',
        level: 'N5',
        content: 'content',
      );

      final map = grammar.toMap();

      expect(map['title'], 'は');
      expect(map['meaning'], 'trợ từ chỉ chủ đề');
      expect(map['level'], 'N5');
      expect(map.containsKey('example'), isFalse);
      expect(map['content'], 'content');
    });

    test('fromMap creates valid Grammar', () {
      final map = {
        'title': 'が',
        'meaning': 'trợ từ chỉ chủ thể',
        'level': 'N5',
        'example': '猫が好きです。',
        'content': 'content',
      };

      final grammar = Grammar.fromMap(map);

      expect(grammar.title, 'が');
      expect(grammar.meaning, 'trợ từ chỉ chủ thể');
      expect(grammar.level, 'N5');
      expect(grammar.example, '猫が好きです。');
      expect(grammar.content, 'content');
    });
  });
}
