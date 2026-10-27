import 'package:flutter/material.dart';

class AppColors {
  // Configurable Palette Tokens
  static const Color primarySage = Color(0xFF829985);
  static const Color deepForest = Color(0xFF304C3B);
  static const Color softCream = Color(0xFFF7F5EE);
  static const Color lightSage = Color(0xFFE7EEE4);
  static const Color mutedBlue = Color(0xFF9CB8C8);
  static const Color darkBackground = Color(0xFF17231D);
  static const Color darkSurface = Color(0xFF22332A);
  static const Color mainTextLight = Color(0xFF26362C);
  static const Color secondaryTextLight = Color(0xFF6C786F);
  static const Color mainTextDark = Color(0xFFF7F5EE);
  static const Color secondaryTextDark = Color(0xFFA3B3A6);
  static const Color accentRose = Color(0xFFD4A373);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primarySage,
      scaffoldBackgroundColor: softCream,
      colorScheme: const ColorScheme.light(
        primary: primarySage,
        secondary: deepForest,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: mainTextLight,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightSage, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: softCream,
        elevation: 0,
        iconTheme: IconThemeData(color: deepForest),
        titleTextStyle: TextStyle(
          color: mainTextLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: deepForest,
        unselectedItemColor: secondaryTextLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepForest,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: deepForest,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primarySage,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primarySage,
        secondary: lightSage,
        surface: darkSurface,
        onPrimary: darkBackground,
        onSecondary: darkBackground,
        onSurface: mainTextDark,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E463A), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: lightSage),
        titleTextStyle: TextStyle(
          color: mainTextDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: lightSage,
        unselectedItemColor: secondaryTextDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySage,
          foregroundColor: darkBackground,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightSage,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
