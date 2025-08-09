import 'package:go_router/go_router.dart';
import './models/vocab.dart';
import './models/kanji.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/vocab_list_screen.dart';
import 'ui/screens/add_edit_vocab_screen.dart';
import 'ui/screens/flashcards_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/kanji_flashcards_screen.dart';
import 'ui/screens/kanji_quiz_screen.dart';
import 'ui/screens/kanji_list_screen.dart';
import 'ui/screens/add_edit_kanji_screen.dart';
import 'ui/screens/stats_screen.dart';
import 'ui/screens/grammar_list_screen.dart';
import 'ui/screens/grammar_quiz_screen.dart';

final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
  GoRoute(path: '/list', builder: (_, __) => const VocabListScreen()),
  GoRoute(
    path: '/add',
    builder: (context, state) {
      final vocab = state.extra as Vocab?;
      return AddEditVocabScreen(vocab: vocab);
    },
  ),
  GoRoute(path: '/flash', builder: (_, __) => const FlashcardsScreen()),
  GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
  GoRoute(path: '/kanji-list', builder: (_, __) => const KanjiListScreen()),
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
  GoRoute(path: '/grammar', builder: (_, __) => const GrammarListScreen()),
  GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
]);