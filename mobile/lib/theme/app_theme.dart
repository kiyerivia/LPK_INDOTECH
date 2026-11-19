import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aurora Frost — Elegan, Futuristik & Nyaman di Mata
class AppColors {
  // Primary Futuristic Mobility Blue-Cyan
  static const Color primary = Color(0xFF2563EB); // Electric Royal Blue
  static const Color primaryLight = Color(0xFF0EA5E9); // Futuristic Sky Cyan
  static const Color primaryGlow = Color(0xFF38BDF8); // Soft Cyan Neon
  static const Color primaryDark = Color(0xFF1D4ED8); // Deep Sapphire

  // Soft Pearl / Ice Glass Surfaces (Eye-Friendly, Zero Glare)
  static const Color background = Color(0xFFF2F6FC); // Cool Pearl Canvas
  static const Color backgroundAlt = Color(0xFFE8F0FA); // Soft Ice Blue Tint
  static const Color surface = Color(0xFFFFFFFF); // Frosted Glass Base
  static const Color surfaceElevated = Color(
    0xFFF8FAFF,
  ); // Subtle Elevated Card
  static const Color borderSubtle = Color(0xFFDCE6F4); // Crisp Glass Border

  // High-Comfort Typography (Deep Slate, Never Harsh Pure Black)
  static const Color textPrimary = Color(0xFF0F172A); // Deep Slate Navy
  static const Color textSecondary = Color(0xFF475569); // Calm Slate Gray
  static const Color textMuted = Color(0xFF64748B); // Soft Metadata Gray

  // Semantic Futuristic Accents
  static const Color emerald = Color(
    0xFF0D9488,
  ); // Refined Teal-Emerald (Mitra)
  static const Color amber = Color(0xFFD97706); // Warm Gold-Amber
  static const Color blue = Color(0xFF2563EB); // Electric Blue
  static const Color purple = Color(
    0xFF6366F1,
  ); // Futuristic Indigo-Violet (Admin)
  static const Color danger = Color(
    0xFFE11D48,
  ); // Soft Crimson (for alerts/logout)
}

class AppTheme {
  static BoxDecoration glassCard({
    double opacity = 0.82,
    double borderOpacity = 0.9,
    double radius = 22,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: borderOpacity),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          blurRadius: 2,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

  static BoxDecoration glassCardHighlight({
    double radius = 22,
    Color color = AppColors.primary,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.92),
          color.withValues(alpha: 0.09),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: 0.32), width: 1.3),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.14),
          blurRadius: 24,
          spreadRadius: -4,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(color: AppColors.textPrimary),
          bodyMedium: const TextStyle(color: AppColors.textSecondary),
          bodySmall: const TextStyle(color: AppColors.textMuted),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textMuted,
      ),
      dividerColor: AppColors.borderSubtle,
    );
  }
}

String formatRupiah(int amount) {
  final str = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return 'Rp ${buffer.toString()}';
}
