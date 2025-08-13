import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'database_service.dart';

class PresetLoader {
  final DatabaseService db;
  PresetLoader(this.db);

  /// JSON format: [{"term":"猫","hiragana":"ねこ","meaning":"con mèo","level":"N5","note":"neko"}, ...]
  Future<int> importJsonAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List;
    var count = 0;
    for (final m in list) {
      await db.addVocab(
        term: m['term'],
        hiragana: m['hiragana'],
        meaning: m['meaning'],
        level: m['level'],
        note: m['note'],
      );
      count++;
    }
    return count;
  }
}
