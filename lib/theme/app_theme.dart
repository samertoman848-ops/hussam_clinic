import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand colours ────────────────────────────────────────────────────────
  static const primaryColor   = Color(0xFF1D9D99);
  static const secondaryColor = Color(0xFF0F4C5C);
  static const accentColor    = Color(0xFFE36414);
  static const backgroundColor = Color(0xFFF8F9FA);
  static const cardColor      = Colors.white;

  // ── Typography helpers ────────────────────────────────────────────────────
  static const String fontFamily = 'Cairo';

  static TextStyle get headingStyle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle get bodyStyle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: Colors.black87,
  );

  static TextStyle get labelStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: Colors.blueGrey[600],
    fontWeight: FontWeight.w500,
  );

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: Colors.grey[600],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: primaryColor,
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.grey[400],
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: fontFamily),
        displayMedium: TextStyle(fontFamily: fontFamily),
        displaySmall:  TextStyle(fontFamily: fontFamily),
        headlineLarge: TextStyle(fontFamily: fontFamily),
        headlineMedium: TextStyle(fontFamily: fontFamily),
        headlineSmall: TextStyle(fontFamily: fontFamily),
        titleLarge:    TextStyle(fontFamily: fontFamily),
        titleMedium:   TextStyle(fontFamily: fontFamily),
        titleSmall:    TextStyle(fontFamily: fontFamily),
        bodyLarge:     TextStyle(fontFamily: fontFamily),
        bodyMedium:    TextStyle(fontFamily: fontFamily),
        bodySmall:     TextStyle(fontFamily: fontFamily),
        labelLarge:    TextStyle(fontFamily: fontFamily),
        labelMedium:   TextStyle(fontFamily: fontFamily),
        labelSmall:    TextStyle(fontFamily: fontFamily),
      ),
    );
  }
}
