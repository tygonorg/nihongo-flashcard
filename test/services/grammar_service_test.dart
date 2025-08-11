import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_flashcard/services/grammar_service.dart';

void main() {
  final service = GrammarService();

  test('adds capitalization and period', () {
    expect(service.correctGrammar('hello world'), 'Hello world.');
  });

  test('keeps existing punctuation', () {
    expect(service.correctGrammar('Hi there!'), 'Hi there!');
  });

  test('returns empty for whitespace', () {
    expect(service.correctGrammar('   '), '');
  });
}
