import 'package:flutter/material.dart';

class AppColors {
  static const black = Color(0xFF0B1020);
  static const charcoal = Color(0xFF0D1117);
  static const surface = Color(0xFF141A2A);
  static const surfaceHigh = Color(0xFF1A2235);
  static const border = Color(0xFF26324A);
  static const text = Color(0xFFF8F5EE);
  static const muted = Color(0xFFAAB2C0);
  static const red = Color(0xFFD94A4A);
  static const gold = Color(0xFFF4B860);
  static const green = Color(0xFF4FB3A3);
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.green,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.red,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.text,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 23,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: const TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 15,
          height: 1.35,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: const TextStyle(color: AppColors.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        hintStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }
}

class AppText {
  static const hero = TextStyle(
    color: AppColors.text,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: 0,
  );

  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
  );

  static const muted = TextStyle(
    color: AppColors.muted,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0,
  );
}
