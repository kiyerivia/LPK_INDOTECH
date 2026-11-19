import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────
  static const Color primary = Color(0xFFE11D48);      // rose-600
  static const Color primaryDark = Color(0xFF9F1239);   // rose-800
  static const Color accent = Color(0xFFFF6B6B);        // coral
  static const Color bgDark = Color(0xFF0A0A0F);        // near black
  static const Color bgCard = Color(0x1AFFFFFF);        // glass white
  static const Color bgCardBorder = Color(0x33FFFFFF);  // glass border
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Glass Decoration ──────────────────────────────────────────
  static BoxDecoration glassCard({double opacity = 0.1, double borderOpacity = 0.2, double radius = 20}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(borderOpacity)),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }

  static BoxDecoration glassCardHighlight({double radius = 20}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withOpacity(0.2),
          primaryDark.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: primary.withOpacity(0.4)),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }

  // ── ThemeData ──────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: const Color(0xFF12121A),
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          displayMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          headlineLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: const TextStyle(color: textPrimary),
          bodyLarge: const TextStyle(color: textPrimary),
          bodyMedium: const TextStyle(color: textSecondary),
          bodySmall: const TextStyle(color: textSecondary),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.07),
        selectedColor: primary.withOpacity(0.3),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        side: BorderSide(color: Colors.white.withOpacity(0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: Colors.white.withOpacity(0.1),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }
}
