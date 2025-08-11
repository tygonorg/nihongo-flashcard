class GrammarService {
  String correctGrammar(String input) {
    if (input.trim().isEmpty) {
      return '';
    }
    final trimmed = input.trim();
    var corrected =
        trimmed[0].toUpperCase() + trimmed.substring(1);
    if (!corrected.endsWith('.') &&
        !corrected.endsWith('!') &&
        !corrected.endsWith('?')) {
      corrected += '.';
    }
    return corrected;
  }
}
