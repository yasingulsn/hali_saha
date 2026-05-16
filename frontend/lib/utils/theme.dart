import 'package:flutter/material.dart';

class AppTheme {
  // Ana renkler — Teal/Cyan bazlı
  static const Color primaryGreen = Color(0xFF00BFA5);
  static const Color darkGreen = Color(0xFF00897B);
  static const Color lightGreen = Color(0xFF64FFDA);
  static const Color fieldGreen = Color(0xFF1DE9B6);
  static const Color neonGreen = Color(0xFF64FFDA);

  // Altın / Amber aksanlar
  static const Color accentOrange = Color(0xFFFFB74D);
  static const Color lightOrange = Color(0xFFFFD54F);
  static const Color amber = Color(0xFFFFD740);

  // Mor / Violet aksanlar
  static const Color accentPurple = Color(0xFFB388FF);
  static const Color lightPurple = Color(0xFFCE93D8);

  // Mercan / Pembe
  static const Color accentCoral = Color(0xFFFF8A80);
  static const Color accentPink = Color(0xFFF48FB1);

  // Mavi aksanlar
  static const Color accentBlue = Color(0xFF82B1FF);
  static const Color lightBlue = Color(0xFF80D8FF);

  // Koyu arka plan tonları — mavi-gri alt ton
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF131920);
  static const Color cardDark = Color(0xFF161B22);
  static const Color cardDarkElevated = Color(0xFF1C2333);
  static const Color inputFill = Color(0xFF121820);

  // Metin
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textHint = Color(0xFF484F58);

  // Durum
  static const Color errorRed = Color(0xFFFF6B6B);
  static const Color successGreen = Color(0xFF64FFDA);

  // Gradient'ler
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D1117),
      Color(0xFF0F1419),
      Color(0xFF0D1117),
      Color(0xFF101820),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1DE9B6),
      Color(0xFF00BFA5),
      Color(0xFF00897B),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1DE9B6),
      Color(0xFF00BFA5),
    ],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB388FF),
      Color(0xFF7C4DFF),
    ],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF8A80),
      Color(0xFFFF5252),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1C2333),
      Color(0xFF161B22),
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1500BFA5),
      Color(0x0800897B),
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentPurple,
        surface: surfaceDark,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGreen.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: backgroundDark,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryGreen),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(backgroundDark),
        side: BorderSide(color: textSecondary.withOpacity(0.4), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentPurple,
        surface: Colors.white,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF1A1A2E),
      ),
      cardColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryGreen),
      ),
    );
  }
}
