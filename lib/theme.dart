import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo);
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    cardTheme: const CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))),
    appBarTheme: const AppBarTheme(centerTitle: true),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
