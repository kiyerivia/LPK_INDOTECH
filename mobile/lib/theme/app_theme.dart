import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CIJ Matte Red & Ochre-Yellow Theme
/// Solid doff tones derived from the Citra Indotech Jaya logo with soft elevation shadows.
class AppColors {
  // Primary CIJ Matte Red & Warm Ochre Yellow (Doff)
  static const Color primary = Color(0xFFB3302A); // Matte CIJ Crimson Red
  static const Color primaryLight = Color(0xFFC98A1C); // Matte CIJ Warm Ochre Yellow
  static const Color primaryGlow = Color(0xFFE0B23B); // Soft Matte Gold Accent
  static const Color primaryDark = Color(0xFF8C231E); // Deep Matte Burgundy Red

  // Bottom Navigation Bar — Solid Matte Reddish-Yellow (Terracotta Doff, No Gradient)
  static const Color navBarBg = Color(0xFFA83E2B);
  static const Color navBarBubble = Color(0xFF8C3121);
  static const Color navBarActiveIcon = Color(0xFFF3C64F);

  // Warm Neutral Matte Paper Surfaces
  static const Color background = Color(0xFFF6F4F0);
  static const Color backgroundAlt = Color(0xFFEDEAE3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAF9F6);
  static const Color borderSubtle = Color(0xFFE3DDD4);

  // Typography (Warm Charcoal)
  static const Color textPrimary = Color(0xFF1F1D1A);
  static const Color textSecondary = Color(0xFF57534E);
  static const Color textMuted = Color(0xFF78716C);

  // Semantic Matte Accents
  static const Color emerald = Color(0xFF2E7D5B); // Matte Forest Green
  static const Color amber = Color(0xFFC98A1C); // Matte Ochre Gold
  static const Color blue = Color(0xFFB3302A); // Unified with CIJ Matte Red
  static const Color purple = Color(0xFF8C231E); // Deep Matte Crimson (Admin)
  static const Color danger = Color(0xFFB91C1C); // Matte Red Alert
}

class AppTheme {
  static BoxDecoration glassCard({
    double opacity = 1.0,
    double borderOpacity = 1.0,
    double radius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? AppColors.borderSubtle,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1F1D1A).withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF1F1D1A).withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration glassCardHighlight({
    double radius = 16,
    Color color = AppColors.primary,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: 0.42), width: 1.3),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: const Color(0xFF1F1D1A).withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration matteBanner({
    Color color = AppColors.primary,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF1F1D1A).withValues(alpha: 0.12),
          blurRadius: 6,
          offset: const Offset(0, 2),
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
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 102),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
