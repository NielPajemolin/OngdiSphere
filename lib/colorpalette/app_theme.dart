import 'package:flutter/material.dart';
import '../colorpalette/color_palette.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1565C0),
      secondary: Color(0xFF26A69A),
      surface: Color(0xFFF4F8FF),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF10213B),
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F8FF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF10213B),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD7E4FA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.6),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Color(0xFF10213B),
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: Color(0xFF10213B),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF20385A),
        height: 1.35,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF3A506D)),
    ),
    extensions: const [
      AppColors(
        primary: Color(0xFF1565C0),
        secondary: Color(0xFF26A69A),
        surface: Color(0xFFF4F8FF),
        tertiary: Color(0xFF0D47A1),
        primaryText: Colors.white,
        secondaryText: Color(0xFFE3F2FD),
        tertiaryText: Color(0xFF10213B),
      ),
    ],
  );
}
