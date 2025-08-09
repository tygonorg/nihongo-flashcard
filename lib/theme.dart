import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme(MaterialColor color, double fontSize) {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: color);
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme)
        .apply(fontSizeFactor: fontSize / 16),
    cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)))),
    appBarTheme: const AppBarTheme(centerTitle: true),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
