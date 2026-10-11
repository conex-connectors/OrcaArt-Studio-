import 'package:flutter/material.dart';

class AppTheme {
  static const Color teal = Color(0xFF2EE6C4);

  static ThemeData dark() => _build(Brightness.dark, const Color(0xFF020403), const Color(0xFF0E1512));
  static ThemeData light() => _build(Brightness.light, const Color(0xFFEEF4F2), Colors.white);

  static ThemeData _build(Brightness b, Color bg, Color card) {
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: bg,
      cardColor: card,
      colorScheme: ColorScheme.fromSeed(seedColor: teal, brightness: b).copyWith(primary: teal, onPrimary: Colors.black, surface: card),
      appBarTheme: AppBarTheme(backgroundColor: bg, elevation: 0, centerTitle: true),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
