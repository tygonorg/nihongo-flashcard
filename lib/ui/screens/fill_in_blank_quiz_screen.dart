import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locator.dart';
import '../../services/database_service.dart';
import '../../controllers/level_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/vocab.dart';
import 'victory_screen.dart';

class FillInBlankQuizScreen extends StatefulWidget {
  const FillInBlankQuizScreen({super.key});
  @override
  State<FillInBlankQuizScreen> createState() => _State();
}

class _State extends State<FillInBlankQuizScreen> {
  final DatabaseService db = locator<DatabaseService>();
  final LevelController levelCtrl = Get.find();
  final SettingsController settings = Get.find();
  late List<Vocab> pool;
  late int maxQuestions;
  int qIndex = 0;
  int correct = 0;
  Vocab? current;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_newQuiz);
  }

  void _newQuiz() async {
    final result =
        await db.getAllVocabs(level: levelCtrl.selectedLevel.value);
    result.shuffle();
    maxQuestions = min(settings.quizLength.value, result.length);
    pool = result.take(maxQuestions).toList();
    qIndex = 0;
    correct = 0;
    _nextQ();
    setState(() {});
  }

  void _nextQ() {
    if (qIndex >= maxQuestions) {
      _finishQuiz();
      return;
    }
    current = pool[qIndex];
    controller.clear();
  }

  void _finishQuiz() {
    final wrong = maxQuestions - correct;
    final percent = correct / maxQuestions * 100;
    if (percent >= 70) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => VictoryScreen(correct: correct, total: maxQuestions)),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kết quả'),
          content: Text(
              'Điểm: $correct/$maxQuestions\nĐúng: $correct\nSai: $wrong\nTỉ lệ: ${percent.toStringAsFixed(1)}%'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Điền khuyết')),
          body: const Center(child: Text('Chưa đủ dữ liệu.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Điền khuyết')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Câu ${qIndex + 1}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
                child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(current!.term,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall),
            )),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Nghĩa tiếng Việt'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final ans = controller.text.trim();
                final ok = ans == current!.meaning;
                if (ok) correct++;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Đúng!' : 'Sai: ${current!.meaning}')));
                setState(() {
                  qIndex++;
                  _nextQ();
                });
              },
              child: const Text('Kiểm tra'),
            ),
            const Spacer(),
            Text('Đúng: $correct', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

