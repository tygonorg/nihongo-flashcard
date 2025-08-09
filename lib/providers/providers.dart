import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/srs_service.dart';
import '../services/kanji_srs_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final srsProvider =
    Provider<SrsService>((ref) => SrsService(ref.read(databaseServiceProvider)));

final kanjiSrsProvider = Provider<KanjiSrsService>(
    (ref) => KanjiSrsService(ref.read(databaseServiceProvider)));

final selectedLevelProvider =
    StateProvider<String?>((ref) => null); // null = tất cả

class AppSettings {
  final double fontSize;
  final MaterialColor primaryColor;
  final int quizLength;
  final bool soundEnabled;

  const AppSettings({
    this.fontSize = 16,
    this.primaryColor = Colors.blue,
    this.quizLength = 10,
    this.soundEnabled = true,
  });

  AppSettings copyWith({
    double? fontSize,
    MaterialColor? primaryColor,
    int? quizLength,
    bool? soundEnabled,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      primaryColor: primaryColor ?? this.primaryColor,
      quizLength: quizLength ?? this.quizLength,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void setFontSize(double v) => state = state.copyWith(fontSize: v);
  void setColor(MaterialColor c) => state = state.copyWith(primaryColor: c);
  void setQuizLength(int v) => state = state.copyWith(quizLength: v);
  void setSound(bool enabled) =>
      state = state.copyWith(soundEnabled: enabled);
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
