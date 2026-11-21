import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import 'web_biometric_stub.dart' if (dart.library.js_interop) 'web_biometric_web.dart';

class BiometricBinding {
  final String username;
  final String email;
  final String fullName;
  final UserRole role;
  final bool isSuperAdmin;
  final bool isMaster;
  final String? webCredentialId;

  const BiometricBinding({
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isSuperAdmin,
    this.isMaster = false,
    this.webCredentialId,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'fullName': fullName,
        'role': role.name,
        'isSuperAdmin': isSuperAdmin,
        'isMaster': isMaster,
        'webCredentialId': webCredentialId,
      };

  factory BiometricBinding.fromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String? ?? 'siswa';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => UserRole.siswa,
    );
    return BiometricBinding(
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: role,
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
      isMaster: json['isMaster'] as bool? ?? false,
      webCredentialId: json['webCredentialId'] as String?,
    );
  }
}

class BiometricAuthResult {
  final bool success;
  final String message;
  final BiometricBinding? binding;

  const BiometricAuthResult({
    required this.success,
    required this.message,
    this.binding,
  });
}

/// Real Security-Grade Biometric Service:
/// - Native (Android / iOS / Windows): uses OS hardware biometrics via `local_auth`
/// - Web (Chrome / Edge / Safari): uses WebAuthn Platform Authenticator (Windows Hello / Touch ID / Fingerprint)
/// - Strictly requires prior password authentication & explicit enrollment on this device (no bypass!)
class BiometricService {
  static const String _storageKey = 'lpk_cij_biometric_binding_v1';
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Checks whether this device supports real hardware biometric verification.
  static Future<bool> isHardwareAvailable() async {
    if (kIsWeb) {
      return isWebBiometricAvailable();
    }
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Reads the currently enrolled biometric account binding on this device, if any.
  static Future<BiometricBinding?> getEnrolledBinding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return null;
      return BiometricBinding.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Enrolls biometric login for the currently authenticated user after verifying real hardware biometrics.
  static Future<BiometricAuthResult> enrollForUser({
    required String username,
    required String email,
    required String fullName,
    required UserRole role,
    required bool isSuperAdmin,
    bool isMaster = false,
  }) async {
    final available = await isHardwareAvailable();
    if (!available) {
      return const BiometricAuthResult(
        success: false,
        message: 'Perangkat belum mendukung sensor sidik jari / Windows Hello (atau perlu HTTPS).',
      );
    }

    String? webCredId;
    if (kIsWeb) {
      webCredId = await enrollWebBiometric(
        userId: email,
        username: username,
        displayName: fullName,
      );
      if (webCredId == null) {
        return const BiometricAuthResult(
          success: false,
          message: 'Pendaftaran sidik jari dibatalkan atau gagal diverifikasi perangkat.',
        );
      }
    } else {
      try {
        final verified = await _localAuth.authenticate(
          localizedReason: 'Konfirmasi sidik jari untuk mengaktifkan login biometrik LPK CIJ',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (!verified) {
          return const BiometricAuthResult(
            success: false,
            message: 'Verifikasi sidik jari gagal atau dibatalkan.',
          );
        }
      } catch (e) {
        return BiometricAuthResult(
          success: false,
          message: 'Sensor biometrik tidak dapat diakses: $e',
        );
      }
    }

    final binding = BiometricBinding(
      username: username,
      email: email,
      fullName: fullName,
      role: role,
      isSuperAdmin: isSuperAdmin,
      isMaster: isMaster,
      webCredentialId: webCredId,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(binding.toJson()));

    return BiometricAuthResult(
      success: true,
      message: 'Login sidik jari berhasil diaktifkan untuk akun $fullName!',
      binding: binding,
    );
  }

  /// Authenticates using enrolled hardware biometrics.
  /// Strictly rejects if not enrolled OR if hardware verification fails/cancelled.
  static Future<BiometricAuthResult> authenticateWithBiometrics() async {
    final binding = await getEnrolledBinding();
    if (binding == null) {
      return const BiometricAuthResult(
        success: false,
        message: 'Sidik jari belum terdaftar di perangkat ini. Masuk dulu pakai kata sandi, lalu aktifkan Sidik Jari di menu Profil.',
      );
    }

    final available = await isHardwareAvailable();
    if (!available) {
      return const BiometricAuthResult(
        success: false,
        message: 'Sensor biometrik / Windows Hello tidak tersedia pada perangkat ini.',
      );
    }

    bool verified = false;
    if (kIsWeb) {
      if (binding.webCredentialId == null || binding.webCredentialId!.isEmpty) {
        return const BiometricAuthResult(
          success: false,
          message: 'Kredensial WebAuthn tidak valid. Silakan aktifkan ulang Sidik Jari dari Profil.',
        );
      }
      verified = await verifyWebBiometric(credentialIdBase64Url: binding.webCredentialId!);
    } else {
      try {
        verified = await _localAuth.authenticate(
          localizedReason: 'Verifikasi sidik jari untuk masuk sebagai ${binding.fullName}',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      } catch (_) {
        verified = false;
      }
    }

    if (!verified) {
      return const BiometricAuthResult(
        success: false,
        message: 'Verifikasi sidik jari gagal atau dibatalkan. Akses ditolak.',
      );
    }

    return BiometricAuthResult(
      success: true,
      message: 'Sidik jari terverifikasi! Selamat datang, ${binding.fullName}.',
      binding: binding,
    );
  }

  /// Disables & clears biometric binding on this device.
  static Future<void> revokeBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
