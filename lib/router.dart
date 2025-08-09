import 'package:go_router/go_router.dart';
import './models/vocab.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/vocab_list_screen.dart';
import 'ui/screens/add_edit_vocab_screen.dart';
import 'ui/screens/flashcards_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/stats_screen.dart';
import 'ui/screens/grammar_list_screen.dart';

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
  GoRoute(path: '/grammar', builder: (_, __) => const GrammarListScreen()),
  GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
]);