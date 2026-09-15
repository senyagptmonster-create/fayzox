import 'package:flutter/material.dart';

class FayzoxTheme {
  static const bg = Color(0xFFFDFBFF);
  static const surface = Color(0xFFFFFFFF);
  static const edge = Color(0xFFEBE4F5);
  static const accent = Color(0xFFA855F7);
  static const accentLight = Color(0xFFD8B4FE);
  static const ink = Color(0xFF280A3D);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      fontFamily: 'AppFont',
      primaryColor: accent,
      colorScheme: const ColorScheme.light(
        primary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        foregroundColor: ink,
        iconTheme: IconThemeData(color: ink),
      ),
    );
  }
}
