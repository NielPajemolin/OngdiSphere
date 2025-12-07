import 'package:flutter/material.dart';
import '../colorpalette/color_palette.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1565C0),
  ),
  extensions: const [
    AppColors(
      primary: Color(0xFF1565C0),
      secondary: Color(0xFF42A5F5),
      surface: Color(0xFFFFF8E1),
      tertiary: Color(0xFF0D47A1),
      primaryText: Color(0xFFFFF8E1),
      secondaryText: Color(0xFFE0E0E0),
      tertiaryText: Color(0xFF1F2937),
      ),
    ],
  );
}