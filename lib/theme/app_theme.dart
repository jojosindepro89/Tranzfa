import 'package:flutter/material.dart';

class AppTheme {
  // Legacy & Compatibility Static Constants
  static const Color obsidianBg = Color(0xFF040E0A);
  static const Color darkEmeraldCard = Color(0xFF091F17);
  static const Color glassBorder = Color(0x2BFFFFFF);
  static const Color goldBorder = Color(0x33F3B728);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);

  // Dark Theme Color System - Ultra-Crisp & Sharp Contrast
  static const Color darkBg = Color(0xFF040E0A);
  static const Color darkCard = Color(0xFF071F17);
  static const Color darkCardBorder = Color(0xFF0E382A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0C4BC); // Sharpened high-contrast light green-gray

  // Light Theme Color System - Ultra-Crisp & Sharp Contrast
  static const Color lightBg = Color(0xFFF2F6F4);
  static const Color lightCard = Colors.white;
  static const Color lightCardBorder = Color(0xFFD4E0DB);
  static const Color lightTextPrimary = Color(0xFF03140C); // Ultra-sharp deep dark emerald black
  static const Color lightTextSecondary = Color(0xFF2B4239); // High-contrast sharp forest slate

  // Shared Brand Accent Colors
  static const Color emeraldPrimary = Color(0xFF00875A);
  static const Color emeraldAccent = Color(0xFF00C88C);
  static const Color emeraldDark = Color(0xFF023824);
  static const Color orangePrimary = Color(0xFFEF531D);
  static const Color goldPrimary = Color(0xFFE5B800);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: emeraldAccent,
      colorScheme: const ColorScheme.dark(
        primary: emeraldAccent,
        secondary: goldPrimary,
        surface: darkCard,
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkTextPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: darkTextPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        titleLarge: TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: emeraldPrimary,
      colorScheme: const ColorScheme.light(
        primary: emeraldPrimary,
        secondary: orangePrimary,
        surface: lightCard,
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightTextPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: lightTextPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        titleLarge: TextStyle(color: lightTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Glassmorphic Decoration Utility
  static BoxDecoration glassBoxDecoration({
    BorderRadius? borderRadius,
    Color? borderCol,
    Color? bgCol,
  }) {
    return BoxDecoration(
      color: bgCol ?? darkEmeraldCard.withOpacity(0.65),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: borderCol ?? goldBorder,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: emeraldAccent.withOpacity(0.08),
          blurRadius: 30,
          spreadRadius: -5,
        ),
      ],
    );
  }
}
