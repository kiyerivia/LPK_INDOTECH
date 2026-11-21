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

  const AuthResult({
    required this.success,
    required this.message,
    this.account,
  });
}

/// Secure Role-Based Auth Service with Dedicated Super Admin Account & Salted SHA-256 Hashing
class AuthService {
  static const String _salt = 'LPK_CIJ_PURWOKERTO_2026_SALT';

  static String hashPassword(String rawPassword) {
    return sha256.convert(utf8.encode('$_salt::$rawPassword')).toString();
  }

  /// Built-in & runtime-registered accounts (MASTER INDOTECH > Super Admin > Mitra > Siswa)
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
    final idx = _accounts.indexWhere((a) => a.username.toLowerCase() == username.toLowerCase());
    if (idx != -1 && !_accounts[idx].isMaster) {
      _accounts[idx] = _accounts[idx].copyWith(verifiedByMaster: verified);
    }
  }

  /// Authenticates via username/email/phone + password (checks Super Admin, registered accounts, and Supabase Auth)
  static Future<AuthResult> signIn({
    required String identifier,
    required String password,
  }) async {
    final cleanId = identifier.trim().toLowerCase();
    if (cleanId.isEmpty || password.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Username/email dan kata sandi wajib diisi.',
      );
    }

    final inputHash = hashPassword(password);

    // 1. Check managed local / built-in accounts (including Super Admin)
    for (final acc in _accounts) {
      final matchesId = acc.username.toLowerCase() == cleanId ||
          acc.email.toLowerCase() == cleanId ||
          acc.phone.replaceAll('-', '') == cleanId.replaceAll('-', '');
      if (matchesId) {
        if (acc.passwordHash == inputHash) {
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

    // 2. Try Supabase Auth if it's an email address
    if (cleanId.contains('@')) {
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: cleanId,
          password: password,
        );
        final user = response.user;
        if (user != null) {
          final meta = user.userMetadata ?? {};
          final roleStr = (meta['role'] as String? ?? 'siswa').toLowerCase();
          final isSuper = roleStr == 'superadmin' || cleanId == 'superadmin@lpk-cij.id';
          final role = isSuper || roleStr == 'admin'
              ? UserRole.admin
              : roleStr == 'mitra'
                  ? UserRole.mitra
                  : UserRole.siswa;

          final account = ManagedAccount(
            username: cleanId.split('@').first,
            email: cleanId,
            fullName: meta['full_name'] as String? ?? cleanId.split('@').first,
            phone: meta['phone'] as String? ?? '-',
            passwordHash: inputHash,
            role: role,
            isSuperAdmin: isSuper,
          );
          return AuthResult(
            success: true,
            message: 'Login Supabase berhasil!',
            account: account,
          );
        }
      } catch (_) {
        // Fall through to invalid credentials error
      }
    }

    return const AuthResult(
      success: false,
      message: 'Akun tidak ditemukan atau kata sandi salah.',
    );
  }

  /// Registers a new Siswa or Mitra Driver account (Admin creation is restricted to Super Admin only!)
  static Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
    bool allowAdminCreation = false,
  }) async {
    if (role == UserRole.admin && !allowAdminCreation) {
      return const AuthResult(
        success: false,
        message: 'Akun Admin hanya dapat dibuat oleh Super Admin.',
      );
    }
    if (fullName.trim().isEmpty || email.trim().isEmpty || password.length < 6) {
      return const AuthResult(
        success: false,
        message: 'Lengkapi nama, email, dan kata sandi minimal 6 karakter.',
      );
    }

    final cleanEmail = email.trim().toLowerCase();
    final username = cleanEmail.contains('@') ? cleanEmail.split('@').first : cleanEmail;
    final alreadyExists = _accounts.any(
      (a) => a.email.toLowerCase() == cleanEmail || a.username.toLowerCase() == username,
    );
    if (alreadyExists) {
      return const AuthResult(
        success: false,
        message: 'Email atau username sudah terdaftar.',
      );
    }

    // Attempt Supabase signUp (gracefully succeeds locally if offline/schema pending)
    if (cleanEmail.contains('@')) {
      try {
        await Supabase.instance.client.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {
            'full_name': fullName.trim(),
            'phone': phone.trim(),
            'role': role.name,
          },
        );
      } catch (_) {}
    }

    final newAccount = ManagedAccount(
      username: username,
      email: cleanEmail,
      fullName: fullName.trim(),
      phone: phone.trim().isEmpty ? '-' : phone.trim(),
      passwordHash: hashPassword(password),
      role: role,
      isSuperAdmin: false,
      isMaster: false,
      verifiedByMaster: role != UserRole.admin, // New Admins await MASTER INDOTECH verification
    );
    _accounts.add(newAccount);

    return AuthResult(
      success: true,
      message: 'Akun ${newAccount.fullName} berhasil didaftarkan!',
      account: newAccount,
    );
  }
}
