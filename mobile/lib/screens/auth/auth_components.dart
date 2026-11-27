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

  // Matte Doff Dark Gray palette + deep dark shadow for active pills & action buttons
  static const Color matteTop = Color(0xFF3E4550);
  static const Color matteBottom = Color(0xFF232830);
  static const Color matteBorder = Color(0xFF525A66);
  static const Color matteTrackBg = Color(0xFFF1F3F6);
  static const Color matteTrackBorder = Color(0xFFD5DAE1);

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
    Color fillColor = const Color(0xFFFFFFFF),
    IconData? prefixIcon,
    bool obscure = false,
    bool enabled = true,
    int? maxLength,
    Widget? suffix,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? fillColor : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? borderTint.withValues(alpha: 0.75) : const Color(0xFFE5E7EB),
          width: 1.1,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscure,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: TextStyle(
          color: enabled ? textMain : textMuted,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: false,
          counterText: '',
          hintText: hint,
          hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.65), fontSize: 13),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 19,
                  color: enabled ? accentColor.withValues(alpha: 0.8) : textMuted.withValues(alpha: 0.5),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        ),
      ),
    );
  }

  static Widget gradientButton({
    required String label,
    List<Color>? gradientColors,
    Color? shadowColor,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.16),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF000000).withValues(alpha: 0.08),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textMain, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget appTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: textMain,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }

  static Widget modeSwitcher({
    required bool isLogin,
    required String loginLabel,
    required String registerLabel,
    List<Color>? activeGradient,
    Color? activeShadow,
    Color? trackBg,
    Color? trackBorder,
    required ValueChanged<bool> onSelectLogin,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: matteTrackBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: matteTrackBorder.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectLogin(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: isLogin
                      ? const LinearGradient(
                          colors: [matteTop, matteBottom],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(18),
                  border: isLogin ? Border.all(color: matteBorder.withValues(alpha: 0.7), width: 0.9) : null,
                  boxShadow: isLogin
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.34),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: const Color(0xFF000000).withValues(alpha: 0.18),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  loginLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: !isLogin
                      ? const LinearGradient(
                          colors: [matteTop, matteBottom],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(18),
                  border: !isLogin ? Border.all(color: matteBorder.withValues(alpha: 0.7), width: 0.9) : null,
                  boxShadow: !isLogin
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.34),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: const Color(0xFF000000).withValues(alpha: 0.18),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  registerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: bioActive ? AppColors.emerald : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.fingerprint_rounded,
                size: 30,
                color: bioActive ? AppColors.emerald : primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bioActive ? 'Sidik jari: $activeName' : 'Masuk dengan Sidik Jari',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: bioActive ? AppColors.emerald : textMuted,
              fontSize: 11.5,
              fontWeight: bioActive ? FontWeight.w600 : FontWeight.w500,
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

  /// Dedicated Email Verification confirmation view shown after real Supabase signUp
  static Widget emailVerificationView({
    required String email,
    required Color accentColor,
    required String title,
    required String subtitle,
    required bool resending,
    String? resendInfo,
    required VoidCallback onResend,
    required VoidCallback onBackToLogin,
  }) {
    return Column(
      children: [
        const SizedBox(height: 6),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.12),
            border: Border.all(color: accentColor, width: 2.2),
          ),
          child: Icon(Icons.mark_email_unread_rounded, color: accentColor, size: 36),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textMain, fontSize: 17.5, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: matteTrackBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: matteTrackBorder),
          ),
          child: Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMain, fontSize: 12.5, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textMuted, fontSize: 12, height: 1.45),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: matteTrackBorder),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Langkah verifikasi:', style: TextStyle(color: textMain, fontSize: 11.5, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('1. Buka Inbox (atau folder Spam / Promosi) di email Anda.', style: TextStyle(color: textMuted, fontSize: 11, height: 1.35)),
              Text('2. Klik tautan "Confirm your mail" untuk mengaktifkan akun.', style: TextStyle(color: textMuted, fontSize: 11, height: 1.35)),
              Text('3. Kembali ke aplikasi ini lalu masuk dengan email & sandi Anda.', style: TextStyle(color: textMuted, fontSize: 11, height: 1.35)),
            ],
          ),
        ),
        if (resendInfo != null) ...[
          const SizedBox(height: 12),
          infoBanner(resendInfo, color: AppColors.emerald),
        ],
        const SizedBox(height: 16),
        gradientButton(
          label: 'Sudah Verifikasi — Masuk Sekarang',
          icon: Icons.login_rounded,
          onTap: onBackToLogin,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: resending ? null : onResend,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: matteTrackBorder, width: 1.3),
            ),
            alignment: Alignment.center,
            child: Text(
              resending ? 'Mengirim ulang email...' : 'Kirim Ulang Email Verifikasi',
              style: TextStyle(
                color: resending ? textMuted : textMain,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Inline OTP status suffix: crisp green checkmark when verified, or compact "Kirim OTP" action button.
  static Widget otpFieldSuffix({
    required bool verified,
    required bool sending,
    required bool enabled,
    required Color accentColor,
    required VoidCallback onSendOtp,
    VoidCallback? onChangeTarget,
  }) {
    if (verified) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
            if (onChangeTarget != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onChangeTarget,
                child: const Text(
                  'Ubah',
                  style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (!enabled) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        widthFactor: 1.0,
        child: GestureDetector(
          onTap: sending ? null : onSendOtp,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              sending ? 'Mengirim...' : 'Kirim OTP',
              style: TextStyle(
                color: sending ? textMuted : accentColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Inline 6-digit OTP verification box displayed directly under WhatsApp or Email field
  static Widget otpVerifyBox({
    required String title,
    required TextEditingController otpController,
    required Color accentColor,
    required Color borderTint,
    required bool verifying,
    required bool resending,
    String? sandboxCode,
    required VoidCallback onVerify,
    required VoidCallback onResend,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: resending ? null : onResend,
                child: Text(
                  resending ? 'Mengirim...' : 'Kirim ulang',
                  style: TextStyle(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (sandboxCode != null) ...[
            const SizedBox(height: 6),
            Text(
              'Kode OTP uji coba: $sandboxCode',
              style: const TextStyle(color: AppColors.emerald, fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: TextField(
                    controller: otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      filled: false,
                      counterText: '',
                      hintText: '6 digit kode',
                      hintStyle: TextStyle(color: textMuted, fontSize: 12.5, letterSpacing: 0.3),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: verifying ? null : onVerify,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    verifying ? '...' : 'Verifikasi',
                    style: const TextStyle(color: textMain, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
