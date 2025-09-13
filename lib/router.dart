import 'package:go_router/go_router.dart';
import './models/vocab.dart';
import './models/kanji.dart';
import './models/grammar.dart';
import 'ui/screens/main_screen.dart';
import 'ui/screens/add_edit_vocab_screen.dart';
import 'ui/screens/flashcards_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/true_false_quiz_screen.dart';
import 'ui/screens/fill_in_blank_quiz_screen.dart';
import 'ui/screens/matching_quiz_screen.dart';
import 'ui/screens/time_attack_quiz_screen.dart';
import 'ui/screens/kanji_flashcards_screen.dart';
import 'ui/screens/kanji_quiz_screen.dart';
import 'ui/screens/add_edit_kanji_screen.dart';
import 'ui/screens/grammar_quiz_screen.dart';
import 'ui/screens/grammar_detail_screen.dart';
import 'ui/screens/add_edit_grammar_screen.dart';
import 'ui/screens/stats_screen.dart';
import 'ui/screens/victory_screen.dart';

final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const MainScreen()),
  GoRoute(
    path: '/add',
    builder: (context, state) {
      final vocab = state.extra as Vocab?;
      return AddEditVocabScreen(vocab: vocab);
    },
  ),
  GoRoute(path: '/flash', builder: (_, __) => const FlashcardsScreen()),
  GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
  GoRoute(path: '/quiz-tf', builder: (_, __) => const TrueFalseQuizScreen()),
  GoRoute(path: '/quiz-fill', builder: (_, __) => const FillInBlankQuizScreen()),
  GoRoute(path: '/quiz-match', builder: (_, __) => const MatchingQuizScreen()),
  GoRoute(path: '/quiz-time', builder: (_, __) => const TimeAttackQuizScreen()),
  GoRoute(
    path: '/kanji-add',
    builder: (context, state) {
      final kanji = state.extra as Kanji?;
      return AddEditKanjiScreen(kanji: kanji);
    },
  ),
  GoRoute(path: '/kanji-flash', builder: (_, __) => const KanjiFlashcardsScreen()),
  GoRoute(path: '/kanji-quiz', builder: (_, __) => const KanjiQuizScreen()),
  GoRoute(path: '/grammar-quiz', builder: (_, __) => const GrammarQuizScreen()),
  GoRoute(
    path: '/grammar-add',
    builder: (context, state) {
      final grammar = state.extra as Grammar?;
      return AddEditGrammarScreen(grammar: grammar);
    },
  ),
  GoRoute(
    path: '/grammar-detail',
    builder: (context, state) {
      final grammar = state.extra as Grammar;
      return GrammarDetailScreen(grammar: grammar);
    },
  ),
  GoRoute(path: '/stats', builder: (_, __) => StatsScreen()),
  GoRoute(
    path: '/victory',
    builder: (context, state) {
      final data = state.extra as Map<String, int>;
      return VictoryScreen(correct: data['correct']!, total: data['total']!);
    },
  ),
]);
