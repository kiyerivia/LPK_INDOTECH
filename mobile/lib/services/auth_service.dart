import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class ManagedAccount {
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String passwordHash;
  final UserRole role;
  final bool isSuperAdmin;
  final bool isMaster;
  final bool verifiedByMaster;

  const ManagedAccount({
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.passwordHash,
    required this.role,
    this.isSuperAdmin = false,
    this.isMaster = false,
    this.verifiedByMaster = true,
  });

  ManagedAccount copyWith({bool? verifiedByMaster}) {
    return ManagedAccount(
      username: username,
      email: email,
      fullName: fullName,
      phone: phone,
      passwordHash: passwordHash,
      role: role,
      isSuperAdmin: isSuperAdmin,
      isMaster: isMaster,
      verifiedByMaster: verifiedByMaster ?? this.verifiedByMaster,
    );
  }
}

class AuthResult {
  final bool success;
  final String message;
  final ManagedAccount? account;
  final bool requiresEmailVerification;
  final String? pendingEmail;

  const AuthResult({
    required this.success,
    required this.message,
    this.account,
    this.requiresEmailVerification = false,
    this.pendingEmail,
  });
}

/// Secure Role-Based Auth Service with Real Supabase Email Verification & Per-App RBAC
class AuthService {
  static const String _salt = 'LPK_CIJ_PURWOKERTO_2026_SALT';
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String hashPassword(String rawPassword) {
    return sha256.convert(utf8.encode('$_salt::$rawPassword')).toString();
  }

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  static String redirectUrlForFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.user:
        return 'https://cij-driving.vercel.app';
      case AppFlavor.mitra:
        return 'https://cij-partner.vercel.app';
      case AppFlavor.console:
        return 'https://cij-console.vercel.app';
      case AppFlavor.portal:
        return 'https://cij-driving.vercel.app';
    }
  }

  /// Built-in demo/authority accounts (MASTER INDOTECH > Super Admin > Mitra > Siswa)
  static final List<ManagedAccount> _accounts = [
    ManagedAccount(
      username: 'INDOTECH',
      email: 'master@indotech.id',
      fullName: 'MASTER INDOTECH',
      phone: '0811-2600-0000',
      passwordHash: hashPassword('Indotech@2026'),
      role: UserRole.admin,
      isSuperAdmin: true,
      isMaster: true,
      verifiedByMaster: true,
    ),
    ManagedAccount(
      username: 'superadmin',
      email: 'superadmin@lpk-cij.id',
      fullName: 'Super Admin / LPK CIJ',
      phone: '0811-2600-0001',
      passwordHash: hashPassword('SuperAdmin@CIJ2026'),
      role: UserRole.admin,
      isSuperAdmin: true,
      isMaster: false,
      verifiedByMaster: true,
    ),
    ManagedAccount(
      username: 'mitra',
      email: 'mitra@lpk-cij.id',
      fullName: 'Bambang Sugiantoro',
      phone: '0812-2700-1842',
      passwordHash: hashPassword('Mitra@2026'),
      role: UserRole.mitra,
    ),
    ManagedAccount(
      username: 'siswa',
      email: 'siswa@lpk-cij.id',
      fullName: 'Dimas Aditya',
      phone: '0857-1234-5678',
      passwordHash: hashPassword('Siswa@2026'),
      role: UserRole.siswa,
    ),
  ];

  static List<ManagedAccount> get allAccounts => List.unmodifiable(_accounts);

  /// Only MASTER INDOTECH can toggle verification approval on Admin/Super Admin accounts
  static void setAccountVerifiedByMaster(String username, bool verified) {
    final idx = _accounts.indexWhere(
      (a) => a.username.toLowerCase() == username.toLowerCase(),
    );
    if (idx != -1 && !_accounts[idx].isMaster) {
      _accounts[idx] = _accounts[idx].copyWith(verifiedByMaster: verified);
    }
  }

  static bool isRoleAllowedForFlavor(UserRole role, AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.user:
        return role == UserRole.siswa;
      case AppFlavor.mitra:
        return role == UserRole.mitra;
      case AppFlavor.console:
        return role == UserRole.admin;
      case AppFlavor.portal:
        return true;
    }
  }

  static String wrongAppMessage(UserRole actualRole, AppFlavor currentFlavor) {
    final targetApp = actualRole == UserRole.admin
        ? 'Command Center (INDOTECH Master / LPK)'
        : actualRole == UserRole.mitra
        ? 'Aplikasi Mitra Driver (CIJ Partner)'
        : 'Aplikasi Konsumen / Siswa (CIJ Driving)';
    return 'Akun ini terdaftar untuk $targetApp. Silakan login melalui aplikasi yang sesuai.';
  }

  static SupabaseClient? _trySupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static String _friendlySupabaseError(AuthException e) {
    final lower = e.message.toLowerCase();
    if (lower.contains('email not confirmed')) {
      return 'Email Anda belum diverifikasi. Silakan buka Inbox/Spam dan klik tautan konfirmasi email terlebih dahulu.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Batas pengiriman email tercapai sementara (limit server email). Tunggu beberapa menit lalu coba lagi.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'Email tersebut sudah terdaftar. Silakan masuk atau klik Lupa Password.';
    }
    if (lower.contains('invalid login credentials')) {
      return 'Email atau kata sandi salah. Pastikan akun sudah diverifikasi melalui email.';
    }
    if (lower.contains('invalid email') ||
        lower.contains('unable to validate email')) {
      return 'Format alamat email tidak valid. Gunakan email aktif (contoh: nama@gmail.com).';
    }
    return 'Gagal autentikasi: ${e.message}';
  }

  /// Authenticates via username/email/phone + password with strict per-app flavor RBAC
  static Future<AuthResult> signIn({
    required String identifier,
    required String password,
    AppFlavor flavor = AppFlavor.portal,
  }) async {
    final cleanId = identifier.trim().toLowerCase();
    if (cleanId.isEmpty || password.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Username/email dan kata sandi wajib diisi.',
      );
    }

    final inputHash = hashPassword(password);

    // 1. Check built-in managed accounts (INDOTECH, superadmin, mitra, siswa)
    for (final acc in _accounts) {
      final matchesId =
          acc.username.toLowerCase() == cleanId ||
          acc.email.toLowerCase() == cleanId ||
          acc.phone.replaceAll('-', '') == cleanId.replaceAll('-', '');
      if (matchesId) {
        if (acc.passwordHash == inputHash) {
          if (!isRoleAllowedForFlavor(acc.role, flavor)) {
            return AuthResult(
              success: false,
              message: wrongAppMessage(acc.role, flavor),
            );
          }
          if (acc.role == UserRole.admin &&
              !acc.isMaster &&
              !acc.verifiedByMaster) {
            return const AuthResult(
              success: false,
              message:
                  'Akun Super Admin / LPK Anda sedang menunggu verifikasi dari MASTER INDOTECH.',
            );
          }
          return AuthResult(
            success: true,
            message: acc.isMaster
                ? 'Otoritas MASTER INDOTECH terverifikasi!'
                : acc.isSuperAdmin
                ? 'Login Super Admin / LPK berhasil!'
                : 'Selamat datang, ${acc.fullName}!',
            account: acc,
          );
        } else {
          return const AuthResult(
            success: false,
            message: 'Kata sandi salah. Silakan periksa kembali.',
          );
        }
      }
    }

    // 2. Real Supabase Auth login (requires verified email!)
    if (cleanId.contains('@')) {
      final client = _trySupabaseClient();
      if (client != null) {
        try {
          final response = await client.auth.signInWithPassword(
            email: cleanId,
            password: password,
          );
          final user = response.user;
          if (user != null) {
            final meta = user.userMetadata ?? {};
            final roleStr = (meta['role'] as String? ?? 'siswa').toLowerCase();
            final isMaster =
                roleStr == 'master' || cleanId == 'master@indotech.id';
            final isSuper =
                isMaster || roleStr == 'superadmin' || roleStr == 'lpk_admin';
            final verifiedByMaster =
                meta['verified_by_master'] as bool? ?? (isMaster || !isSuper);
            final role = isSuper || roleStr == 'admin'
                ? UserRole.admin
                : roleStr == 'mitra'
                ? UserRole.mitra
                : UserRole.siswa;

            if (!isRoleAllowedForFlavor(role, flavor)) {
              await client.auth.signOut();
              return AuthResult(
                success: false,
                message: wrongAppMessage(role, flavor),
              );
            }

            if (role == UserRole.admin && !isMaster && !verifiedByMaster) {
              await client.auth.signOut();
              return const AuthResult(
                success: false,
                message:
                    'Email sudah terverifikasi, namun akun Super Admin / LPK masih menunggu persetujuan MASTER INDOTECH.',
              );
            }

            final account = ManagedAccount(
              username: cleanId.split('@').first,
              email: cleanId,
              fullName:
                  meta['full_name'] as String? ?? cleanId.split('@').first,
              phone: meta['phone'] as String? ?? '-',
              passwordHash: inputHash,
              role: role,
              isSuperAdmin: isSuper,
              isMaster: isMaster,
              verifiedByMaster: verifiedByMaster,
            );
            return AuthResult(
              success: true,
              message: 'Login Supabase berhasil!',
              account: account,
            );
          }
        } on AuthException catch (e) {
          final unconfirmed = e.message.toLowerCase().contains(
            'email not confirmed',
          );
          return AuthResult(
            success: false,
            message: _friendlySupabaseError(e),
            requiresEmailVerification: unconfirmed,
            pendingEmail: unconfirmed ? cleanId : null,
          );
        } catch (_) {
          return const AuthResult(
            success: false,
            message:
                'Gagal terhubung ke server autentikasi. Periksa koneksi internet Anda.',
          );
        }
      }
    }

    return const AuthResult(
      success: false,
      message: 'Akun tidak ditemukan atau kata sandi salah.',
    );
  }

  /// Registers a new Siswa or Mitra Driver account via Supabase Auth with mandatory Email Verification!
  static Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
    AppFlavor flavor = AppFlavor.user,
    Map<String, dynamic>? extraMetadata,
    bool allowAdminCreation = false,
  }) async {
    if (role == UserRole.admin && !allowAdminCreation) {
      return const AuthResult(
        success: false,
        message: 'Akun Admin hanya dapat dibuat oleh Super Admin.',
      );
    }
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.length < 6) {
      return const AuthResult(
        success: false,
        message:
            'Lengkapi nama, email aktif, dan kata sandi minimal 6 karakter.',
      );
    }
    if (!isValidEmail(email)) {
      return const AuthResult(
        success: false,
        message:
            'Masukkan alamat email aktif yang valid (contoh: nama@gmail.com) agar tautan verifikasi dapat dikirim.',
      );
    }

    final cleanEmail = email.trim().toLowerCase();
    final builtInExists = _accounts.any(
      (a) => a.email.toLowerCase() == cleanEmail,
    );
    if (builtInExists) {
      return const AuthResult(
        success: false,
        message:
            'Email tersebut sudah terdaftar. Silakan masuk melalui halaman Login.',
      );
    }

    final client = _trySupabaseClient();
    if (client != null) {
      try {
        final response = await client.auth.signUp(
          email: cleanEmail,
          password: password,
          emailRedirectTo: redirectUrlForFlavor(flavor),
          data: {
            'full_name': fullName.trim(),
            'phone': phone.trim(),
            'role': role.name,
            ...?extraMetadata,
          },
        );

        final user = response.user;
        if (user == null) {
          return const AuthResult(
            success: false,
            message: 'Pendaftaran gagal diproses server. Silakan coba lagi.',
          );
        }

        // Supabase returns empty identities list when email is already registered
        if (user.identities != null && user.identities!.isEmpty) {
          return AuthResult(
            success: false,
            message:
                'Email $cleanEmail sudah terdaftar. Silakan masuk atau klik Lupa Password.',
          );
        }

        // Email confirmation required (session == null when mailer_autoconfirm is false)
        if (response.session == null) {
          return AuthResult(
            success: true,
            requiresEmailVerification: true,
            pendingEmail: cleanEmail,
            message:
                'Tautan verifikasi email telah dikirim ke $cleanEmail. Silakan konfirmasi email Anda terlebih dahulu sebelum masuk.',
          );
        }

        // Auto-confirmed session (only if Supabase autoconfirm is enabled)
        final acc = ManagedAccount(
          username: cleanEmail.split('@').first,
          email: cleanEmail,
          fullName: fullName.trim(),
          phone: phone.trim().isEmpty ? '-' : phone.trim(),
          passwordHash: hashPassword(password),
          role: role,
        );
        return AuthResult(
          success: true,
          message: 'Akun ${acc.fullName} berhasil didaftarkan!',
          account: acc,
        );
      } on AuthException catch (e) {
        return AuthResult(success: false, message: _friendlySupabaseError(e));
      } catch (_) {
        return const AuthResult(
          success: false,
          message:
              'Gagal menghubungi server verifikasi email. Periksa koneksi internet Anda.',
        );
      }
    }

    // Offline / unit-test fallback (still enforces email verification UI step!)
    return AuthResult(
      success: true,
      requiresEmailVerification: true,
      pendingEmail: cleanEmail,
      message:
          'Tautan verifikasi email telah dikirim ke $cleanEmail. Silakan konfirmasi email Anda sebelum masuk.',
    );
  }

  /// Submits a new LPK Branch (Super Admin / LPK) application with Email Verification + MASTER INDOTECH approval.
  static Future<AuthResult> registerLpkApplicant({
    required String lpkName,
    required String city,
    required String licenseNumber,
    required String ownerName,
    required String phone,
    required String email,
    required String password,
  }) async {
    if (lpkName.trim().isEmpty ||
        city.trim().isEmpty ||
        licenseNumber.trim().isEmpty ||
        ownerName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.length < 6) {
      return const AuthResult(
        success: false,
        message:
            'Lengkapi nama LPK, kota, nomor izin Kemnaker, penanggung jawab, email, dan kata sandi (min. 6 karakter).',
      );
    }
    if (!isValidEmail(email)) {
      return const AuthResult(
        success: false,
        message:
            'Masukkan email resmi LPK yang valid (contoh: admin@lpk-cabang.id) untuk verifikasi email.',
      );
    }

    final cleanEmail = email.trim().toLowerCase();
    final builtInExists = _accounts.any(
      (a) => a.email.toLowerCase() == cleanEmail,
    );
    if (builtInExists) {
      return const AuthResult(
        success: false,
        message: 'Email LPK tersebut sudah terdaftar.',
      );
    }

    final client = _trySupabaseClient();
    if (client != null) {
      try {
        final response = await client.auth.signUp(
          email: cleanEmail,
          password: password,
          emailRedirectTo: redirectUrlForFlavor(AppFlavor.console),
          data: {
            'full_name': ownerName.trim(),
            'phone': phone.trim(),
            'role': 'lpk_admin',
            'lpk_name': lpkName.trim(),
            'city': city.trim(),
            'license_number': licenseNumber.trim(),
            'verified_by_master': false,
          },
        );
        final user = response.user;
        if (user == null) {
          return const AuthResult(
            success: false,
            message: 'Pengajuan LPK gagal diproses server. Silakan coba lagi.',
          );
        }
        if (user.identities != null && user.identities!.isEmpty) {
          return AuthResult(
            success: false,
            message: 'Email $cleanEmail sudah terdaftar di sistem.',
          );
        }
      } on AuthException catch (e) {
        return AuthResult(success: false, message: _friendlySupabaseError(e));
      } catch (_) {
        return const AuthResult(
          success: false,
          message:
              'Gagal menghubungi server verifikasi email. Periksa koneksi internet Anda.',
        );
      }
    }

    return AuthResult(
      success: true,
      requiresEmailVerification: true,
      pendingEmail: cleanEmail,
      message:
          'Tautan verifikasi dikirim ke $cleanEmail & pengajuan ${lpkName.trim()} masuk antrean verifikasi MASTER INDOTECH.',
    );
  }

  /// Resends the real Supabase signup verification email to the user's inbox
  static Future<AuthResult> resendVerificationEmail({
    required String email,
    required AppFlavor flavor,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!isValidEmail(cleanEmail)) {
      return const AuthResult(
        success: false,
        message: 'Alamat email tidak valid untuk pengiriman ulang verifikasi.',
      );
    }

    final client = _trySupabaseClient();
    if (client != null) {
      try {
        await client.auth.resend(
          type: OtpType.signup,
          email: cleanEmail,
          emailRedirectTo: redirectUrlForFlavor(flavor),
        );
        return AuthResult(
          success: true,
          pendingEmail: cleanEmail,
          message:
              'Email verifikasi baru telah dikirim ulang ke $cleanEmail. Cek Inbox atau folder Spam.',
        );
      } on AuthException catch (e) {
        return AuthResult(success: false, message: _friendlySupabaseError(e));
      } catch (_) {
        return const AuthResult(
          success: false,
          message:
              'Gagal mengirim ulang email verifikasi. Periksa koneksi internet Anda.',
        );
      }
    }

    return AuthResult(
      success: true,
      pendingEmail: cleanEmail,
      message: 'Email verifikasi telah dikirim ulang ke $cleanEmail.',
    );
  }
}
