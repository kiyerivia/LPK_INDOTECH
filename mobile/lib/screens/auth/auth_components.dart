import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

/// Shared visual building blocks for the 3 dedicated Auth Dashboards:
/// - UserAuthScreen (cij-driving.vercel.app)
/// - MitraAuthScreen (cij-partner.vercel.app)
/// - ConsoleAuthScreen (cij-console.vercel.app)
class AuthComponents {
  static const Color textMain = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  static Widget logoBanner({double width = 220, double height = 136, Color fallbackColor = const Color(0xFFDC2626)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Image.asset(
        'assets/logo.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.directions_car_rounded,
          size: 68,
          color: fallbackColor,
        ),
      ),
    );
  }

  static Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: textMain,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Widget softInput({
    required TextEditingController controller,
    required String hint,
    required Color accentColor,
    required Color borderTint,
    Color fillColor = const Color(0xFFFFFBF7),
    IconData? prefixIcon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderTint.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderTint.withValues(alpha: 0.28),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: textMain,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.72), fontSize: 12.5),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 19, color: accentColor.withValues(alpha: 0.85))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  static Widget gradientButton({
    required String label,
    required List<Color> gradientColors,
    required Color shadowColor,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: onTap == null ? 0.65 : 1.0,
        child: Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.34),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget modeSwitcher({
    required bool isLogin,
    required String loginLabel,
    required String registerLabel,
    required List<Color> activeGradient,
    required Color activeShadow,
    required Color trackBg,
    required Color trackBorder,
    required ValueChanged<bool> onSelectLogin,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: trackBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectLogin(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isLogin ? LinearGradient(colors: activeGradient) : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isLogin
                      ? [BoxShadow(color: activeShadow.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  loginLabel,
                  style: TextStyle(
                    color: isLogin ? Colors.white : textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectLogin(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: !isLogin ? LinearGradient(colors: activeGradient) : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: !isLogin
                      ? [BoxShadow(color: activeShadow.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  registerLabel,
                  style: TextStyle(
                    color: !isLogin ? Colors.white : textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gpp_bad_rounded, color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget infoBanner(String message, {Color color = AppColors.emerald}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  static Widget biometricButton({
    required bool bioActive,
    required String activeName,
    required Color primaryColor,
    required Color ringColor,
    required VoidCallback? onTap,
  }) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: bioActive ? AppColors.emerald : ringColor,
                  width: 2.3,
                ),
                boxShadow: [
                  const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
                  BoxShadow(
                    color: (bioActive ? AppColors.emerald : primaryColor).withValues(alpha: 0.22),
                    offset: const Offset(4, 6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Icon(
                Icons.fingerprint_rounded,
                size: 38,
                color: bioActive ? AppColors.emerald : primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bioActive ? 'Sidik jari aktif: $activeName' : 'Masuk cepat dengan Sidik Jari (Biometrik)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: bioActive ? AppColors.emerald : textMuted,
              fontSize: 10.5,
              fontWeight: bioActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget featureChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static Future<void> triggerPasswordReset(String target) async {
    if (target.contains('@')) {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(target);
      } catch (_) {}
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}
