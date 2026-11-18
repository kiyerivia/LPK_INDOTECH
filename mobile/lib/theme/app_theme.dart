import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF09090B); // zinc-950
  static const Color surface = Color(0xFF121215);
  static const Color card = Color(0xFF18181B); // zinc-900
  static const Color cardBorder = Color(0x1FFFFFFF); // 12% white
  static const Color primary = Color(0xFFF43F5E); // rose-500 neon
  static const Color primaryGlow = Color(0xFFFF2453);
  static const Color primaryLight = Color(0xFFFDA4AF);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color textMain = Color(0xFFFAFAFA);
  static const Color textMuted = Color(0xFFA1A1AA);
  static const Color textSubtle = Color(0xFF71717A);
}

class GlassCardDecoration extends BoxDecoration {
  GlassCardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) : super(
          color: color ?? const Color(0xB318181B), // 70% dark zinc
          borderRadius: borderRadius ?? BorderRadius.circular(24),
          border: border ?? Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        );
}

ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: baseTextTheme.apply(
      bodyColor: AppColors.textMain,
      displayColor: AppColors.textMain,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
  );
}
