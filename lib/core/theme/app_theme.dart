import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/color_palette.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF131015),
      secondary: Color(0xFFF48FB1),
      surface: Color(0xFFFFF6FB),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF2B1622),
      onSurface: Color(0xFF211724),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF2FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF211724),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFAFD),
      elevation: 0,
      shadowColor: const Color(0xFFB17695),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF131015),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFF48FB1),
      foregroundColor: Color(0xFF2B1622),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFF0F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFF4C7DC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFF48FB1), width: 1.6),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Color(0xFF211724),
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: Color(0xFF211724),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF34263A),
        height: 1.35,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF5A3E52)),
    ),
    extensions: const [
      AppColors(
        primary: Color(0xFF131015),
        secondary: Color(0xFFF48FB1),
        surface: Color(0xFFFFF6FB),
        tertiary: Color(0xFF8F6EA8),
        primaryText: Colors.white,
        secondaryText: Color(0xFF2B1622),
        tertiaryText: Color(0xFF211724),
      ),
    ],
  );
}
