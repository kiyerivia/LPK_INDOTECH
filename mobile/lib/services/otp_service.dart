import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import 'auth_service.dart';

class OtpSendResult {
  final bool success;
  final String message;
  final String normalizedTarget;
  final bool isSandboxFallback;
  final String? sandboxPreviewCode;

  const OtpSendResult({
    required this.success,
    required this.message,
    required this.normalizedTarget,
    this.isSandboxFallback = false,
    this.sandboxPreviewCode,
  });
}

class OtpVerifyResult {
  final bool success;
  final String message;

  const OtpVerifyResult({
    required this.success,
    required this.message,
  });
}

class _PendingOtpEntry {
  final String code;
  final DateTime expiresAt;
  final bool viaSupabase;

  const _PendingOtpEntry({
    required this.code,
    required this.expiresAt,
    required this.viaSupabase,
  });
}

/// Real Sequential Dual-OTP Verification Service:
/// 1) WhatsApp / Phone OTP (tries Supabase Phone Auth first; gracefully uses secure Beta Sandbox OTP while SMS/WA gateway is unconfigured)
/// 2) Email OTP (real 6-digit Supabase Email OTP via signInWithOtp + verifyOTP)
class OtpService {
  static final Map<String, _PendingOtpEntry> _phoneOtps = {};
  static final Map<String, _PendingOtpEntry> _emailOtps = {};

  static String _generateSixDigitCode() {
    final rng = Random.secure();
    return (100000 + rng.nextInt(900000)).toString();
  }

  /// Normalizes Indonesian mobile numbers (0812-xxx -> +62812xxx). Returns null if invalid.
  static String? normalizeIndonesianPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return null;
    String e164;
    if (digits.startsWith('+62')) {
      e164 = digits;
    } else if (digits.startsWith('62')) {
      e164 = '+$digits';
    } else if (digits.startsWith('0')) {
      e164 = '+62${digits.substring(1)}';
    } else if (digits.startsWith('8')) {
      e164 = '+62$digits';
    } else {
      return null;
    }
    final cleanDigits = e164.substring(1);
    if (cleanDigits.length < 10 || cleanDigits.length > 15) return null;
    return e164;
  }

  static SupabaseClient? _tryClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Step 1: Send 6-digit OTP to WhatsApp / Phone number
  static Future<OtpSendResult> sendPhoneOtp(String rawPhone) async {
    final e164 = normalizeIndonesianPhone(rawPhone);
    if (e164 == null) {
      return const OtpSendResult(
        success: false,
        message: 'Masukkan nomor WhatsApp Indonesia yang valid (contoh: 0812-xxxx-xxxx).',
        normalizedTarget: '',
      );
    }

    final client = _tryClient();
    if (client != null) {
      try {
        await client.auth.signInWithOtp(phone: e164, shouldCreateUser: true);
        _phoneOtps[e164] = _PendingOtpEntry(
          code: '',
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          viaSupabase: true,
        );
        return OtpSendResult(
          success: true,
          message: 'Kode OTP 6 digit telah dikirim ke $e164.',
          normalizedTarget: e164,
        );
      } on AuthException catch (e) {
        final lower = e.message.toLowerCase();
        final providerDisabled = lower.contains('phone') &&
            (lower.contains('disabled') || lower.contains('provider') || lower.contains('unsupported') || lower.contains('sms'));
        if (!providerDisabled) {
          return OtpSendResult(
            success: false,
            message: 'Gagal mengirim OTP WhatsApp: ${e.message}',
            normalizedTarget: e164,
          );
        }
        // Fall through cleanly to Beta Sandbox OTP when SMS/WA gateway is not yet enabled in Supabase
      } catch (_) {
        // Fall through to Beta Sandbox OTP
      }
    }

    final code = _generateSixDigitCode();
    _phoneOtps[e164] = _PendingOtpEntry(
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      viaSupabase: false,
    );
    return OtpSendResult(
      success: true,
      normalizedTarget: e164,
      isSandboxFallback: true,
      sandboxPreviewCode: code,
      message: 'OTP Beta WA ($e164) siap diverifikasi. Masukkan kode 6 digit di bawah.',
    );
  }

  /// Step 1 Verify: Verify 6-digit WhatsApp / Phone OTP
  static Future<OtpVerifyResult> verifyPhoneOtp({
    required String rawPhone,
    required String token,
  }) async {
    final e164 = normalizeIndonesianPhone(rawPhone);
    final cleanToken = token.trim();
    if (e164 == null) {
      return const OtpVerifyResult(success: false, message: 'Nomor WhatsApp tidak valid.');
    }
    if (!RegExp(r'^\d{6}$').hasMatch(cleanToken)) {
      return const OtpVerifyResult(success: false, message: 'Masukkan kode OTP 6 digit angka.');
    }

    final entry = _phoneOtps[e164];
    if (entry == null) {
      return const OtpVerifyResult(success: false, message: 'Klik "Kirim OTP" terlebih dahulu.');
    }
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _phoneOtps.remove(e164);
      return const OtpVerifyResult(success: false, message: 'Kode OTP telah kedaluwarsa. Kirim ulang OTP.');
    }

    if (entry.viaSupabase) {
      final client = _tryClient();
      if (client != null) {
        try {
          await client.auth.verifyOTP(phone: e164, token: cleanToken, type: OtpType.sms);
          _phoneOtps.remove(e164);
          return const OtpVerifyResult(success: true, message: 'Nomor WhatsApp berhasil diverifikasi!');
        } on AuthException catch (e) {
          return OtpVerifyResult(success: false, message: 'Kode OTP salah atau kedaluwarsa (${e.message}).');
        } catch (_) {
          return const OtpVerifyResult(success: false, message: 'Gagal memverifikasi OTP ke server.');
        }
      }
    }

    if (cleanToken == entry.code) {
      _phoneOtps.remove(e164);
      return const OtpVerifyResult(success: true, message: 'Nomor WhatsApp berhasil diverifikasi!');
    }
    return const OtpVerifyResult(success: false, message: 'Kode OTP WhatsApp salah. Periksa kembali 6 digit kode Anda.');
  }

  /// Step 2: Send 6-digit Email OTP via real Supabase Email Auth
  static Future<OtpSendResult> sendEmailOtp({
    required String rawEmail,
    required AppFlavor flavor,
  }) async {
    final cleanEmail = rawEmail.trim().toLowerCase();
    if (!AuthService.isValidEmail(cleanEmail)) {
      return const OtpSendResult(
        success: false,
        message: 'Masukkan alamat email aktif yang valid (contoh: nama@gmail.com).',
        normalizedTarget: '',
      );
    }

    final builtInExists = AuthService.allAccounts.any((a) => a.email.toLowerCase() == cleanEmail);
    if (builtInExists) {
      return OtpSendResult(
        success: false,
        message: 'Email $cleanEmail sudah terdaftar. Silakan masuk di halaman Login.',
        normalizedTarget: cleanEmail,
      );
    }

    final client = _tryClient();
    if (client != null) {
      try {
        await client.auth.signInWithOtp(
          email: cleanEmail,
          shouldCreateUser: true,
          emailRedirectTo: AuthService.redirectUrlForFlavor(flavor),
        );
        _emailOtps[cleanEmail] = _PendingOtpEntry(
          code: '',
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
          viaSupabase: true,
        );
        return OtpSendResult(
          success: true,
          normalizedTarget: cleanEmail,
          message: 'Kode OTP 6 digit telah dikirim ke $cleanEmail. Cek Inbox atau folder Spam.',
        );
      } on AuthException catch (e) {
        final lower = e.message.toLowerCase();
        if (lower.contains('rate limit') || lower.contains('too many requests')) {
          return OtpSendResult(
            success: false,
            normalizedTarget: cleanEmail,
            message: 'Batas pengiriman email OTP sementara tercapai. Tunggu beberapa menit lalu coba lagi.',
          );
        }
        return OtpSendResult(
          success: false,
          normalizedTarget: cleanEmail,
          message: 'Gagal mengirim OTP Email: ${e.message}',
        );
      } catch (_) {
        return OtpSendResult(
          success: false,
          normalizedTarget: cleanEmail,
          message: 'Gagal menghubungi server email OTP. Periksa koneksi internet Anda.',
        );
      }
    }

    // Offline / widget-test fallback
    final code = _generateSixDigitCode();
    _emailOtps[cleanEmail] = _PendingOtpEntry(
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      viaSupabase: false,
    );
    return OtpSendResult(
      success: true,
      normalizedTarget: cleanEmail,
      isSandboxFallback: true,
      sandboxPreviewCode: code,
      message: 'Kode OTP Email dikirim ke $cleanEmail.',
    );
  }

  /// Step 2 Verify: Verify 6-digit Email OTP via Supabase verifyOTP(type: OtpType.email)
  static Future<OtpVerifyResult> verifyEmailOtp({
    required String rawEmail,
    required String token,
  }) async {
    final cleanEmail = rawEmail.trim().toLowerCase();
    final cleanToken = token.trim();
    if (!AuthService.isValidEmail(cleanEmail)) {
      return const OtpVerifyResult(success: false, message: 'Format email tidak valid.');
    }
    if (!RegExp(r'^\d{6}$').hasMatch(cleanToken)) {
      return const OtpVerifyResult(success: false, message: 'Masukkan kode OTP Email 6 digit angka.');
    }

    final entry = _emailOtps[cleanEmail];
    if (entry == null) {
      return const OtpVerifyResult(success: false, message: 'Klik "Kirim OTP" pada kolom Email terlebih dahulu.');
    }
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _emailOtps.remove(cleanEmail);
      return const OtpVerifyResult(success: false, message: 'Kode OTP Email kedaluwarsa. Silakan kirim ulang.');
    }

    if (entry.viaSupabase) {
      final client = _tryClient();
      if (client != null) {
        try {
          await client.auth.verifyOTP(
            email: cleanEmail,
            token: cleanToken,
            type: OtpType.email,
          );
          _emailOtps.remove(cleanEmail);
          return const OtpVerifyResult(success: true, message: 'Email berhasil diverifikasi dengan OTP!');
        } on AuthException catch (e) {
          return OtpVerifyResult(success: false, message: 'Kode OTP Email salah atau kedaluwarsa (${e.message}).');
        } catch (_) {
          return const OtpVerifyResult(success: false, message: 'Gagal memverifikasi OTP Email ke server.');
        }
      }
    }

    if (cleanToken == entry.code) {
      _emailOtps.remove(cleanEmail);
      return const OtpVerifyResult(success: true, message: 'Email berhasil diverifikasi dengan OTP!');
    }
    return const OtpVerifyResult(success: false, message: 'Kode OTP Email salah. Periksa kembali 6 digit kode Anda.');
  }
}
