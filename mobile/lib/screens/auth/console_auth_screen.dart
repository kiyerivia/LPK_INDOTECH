import 'package:flutter/material.dart';
import '../../config/app_version.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../theme/app_theme.dart';
import 'auth_components.dart';

enum _ConsoleAuthMode { login, registerLpk, forgot }

/// Dedicated Executive Login & LPK Branch Registration Dashboard for App 3:
/// CIJ Command Center (`cij-console.vercel.app`)
/// Visual Identity: Bright Executive Crimson–Royal Indigo–Gold split-screen on desktop, stacked on mobile.
/// Supports:
///   1. INDOTECH (Master) Login
///   2. LPK (Super Admin) Login
///   3. New LPK Branch Application (requires verification by MASTER INDOTECH)
class ConsoleAuthScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onAuthenticated;

  const ConsoleAuthScreen({
    super.key,
    required this.appState,
    required this.onAuthenticated,
  });

  @override
  State<ConsoleAuthScreen> createState() => _ConsoleAuthScreenState();
}

class _ConsoleAuthScreenState extends State<ConsoleAuthScreen> {
  _ConsoleAuthMode _mode = _ConsoleAuthMode.login;
  bool _obscurePassword = true;
  bool _loading = false;
  bool _resending = false;
  bool _resetSent = false;
  bool _lpkSubmitted = false;
  int _failedAttempts = 0;
  String? _error;
  String? _resendInfo;
  String? _pendingEmail;
  String _submittedLpkName = '';
  BiometricBinding? _enrolledBiometric;

  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _lpkNameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _resetCtrl = TextEditingController();

  static const Color _crimson = Color(0xFFB91C1C);
  static const Color _indigo = Color(0xFF4338CA);
  static const Color _indigoBright = Color(0xFF6366F1);
  static const Color _gold = Color(0xFFD97706);
  static const Color _indigoBorder = Color(0xFFC7D2FE);

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    final b = await BiometricService.getEnrolledBinding();
    if (mounted) setState(() => _enrolledBiometric = b);
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    _lpkNameCtrl.dispose();
    _cityCtrl.dispose();
    _licenseCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _resetCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final attemptedId = _idCtrl.text.trim();
    final result = await AuthService.signIn(
      identifier: _idCtrl.text,
      password: _passCtrl.text,
      flavor: AppFlavor.console,
    );
    if (!mounted) return;

    if (!result.success || result.account == null) {
      _idCtrl.clear();
      _passCtrl.clear();
      setState(() {
        _loading = false;
        _resendInfo = null;
        if (result.requiresEmailVerification && result.pendingEmail != null) {
          _pendingEmail = result.pendingEmail;
          _error = result.message;
        } else {
          _failedAttempts += 1;
          if (_failedAttempts >= 5) {
            _failedAttempts = 0;
            _resetSent = false;
            if (attemptedId.isNotEmpty) _resetCtrl.text = attemptedId;
            _mode = _ConsoleAuthMode.forgot;
            _error = 'Anda sudah 5x salah memasukkan akun/kata sandi. Silakan pulihkan akses Console Anda.';
          } else {
            _error = '${result.message} (Percobaan $_failedAttempts/5)';
          }
        }
      });
      return;
    }

    _failedAttempts = 0;

    final acc = result.account!;
    widget.appState.login(
      name: acc.fullName,
      email: acc.email,
      username: acc.username,
      role: acc.role,
      superAdmin: acc.isSuperAdmin,
      master: acc.isMaster,
    );
    setState(() => _loading = false);
    widget.onAuthenticated();
  }

  Future<void> _handleBiometric() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final bio = await BiometricService.authenticateWithBiometrics();
    if (!mounted) return;

    if (!bio.success || bio.binding == null) {
      setState(() {
        _loading = false;
        _error = bio.message;
      });
      return;
    }

    final b = bio.binding!;
    if (!AuthService.isRoleAllowedForFlavor(b.role, AppFlavor.console)) {
      setState(() {
        _loading = false;
        _error = AuthService.wrongAppMessage(b.role, AppFlavor.console);
      });
      return;
    }

    widget.appState.login(
      name: b.fullName,
      email: b.email,
      username: b.username,
      role: b.role,
      superAdmin: b.isSuperAdmin,
      master: b.isMaster,
    );
    setState(() => _loading = false);
    widget.onAuthenticated();
  }

  Future<void> _handleRegisterLpk() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.registerLpkApplicant(
      lpkName: _lpkNameCtrl.text,
      city: _cityCtrl.text,
      licenseNumber: _licenseCtrl.text,
      ownerName: _ownerNameCtrl.text,
      phone: _phoneCtrl.text,
      email: _idCtrl.text,
      password: _passCtrl.text,
    );
    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _loading = false;
        _error = result.message;
      });
      return;
    }

    final branchName = _lpkNameCtrl.text.trim();
    widget.appState.registerLpkBranch(
      name: branchName,
      city: _cityCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      ownerPhone: _phoneCtrl.text.trim().isEmpty ? '-' : _phoneCtrl.text.trim(),
    );

    setState(() {
      _loading = false;
      _lpkSubmitted = true;
      _submittedLpkName = branchName;
      _pendingEmail = result.pendingEmail ?? _idCtrl.text.trim().toLowerCase();
    });
  }

  Future<void> _handleResendVerification() async {
    final email = _pendingEmail ?? _idCtrl.text.trim().toLowerCase();
    setState(() {
      _resending = true;
      _error = null;
      _resendInfo = null;
    });
    final res = await AuthService.resendVerificationEmail(email: email, flavor: AppFlavor.console);
    if (!mounted) return;
    setState(() {
      _resending = false;
      if (res.success) {
        _resendInfo = res.message;
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _handleForgot() async {
    final target = _resetCtrl.text.trim();
    if (target.isEmpty) {
      setState(() => _error = 'Masukkan email resmi Master / Super Admin LPK.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await AuthComponents.triggerPasswordReset(target);
    if (mounted) {
      setState(() {
        _loading = false;
        _resetSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 820;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFEEF2FF),
              Color(0xFFFFFBEB),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_indigoBright.withValues(alpha: 0.22), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -70,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_crimson.withValues(alpha: 0.16), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 920 : 440),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 5, child: _buildGovernancePanel()),
                              const SizedBox(width: 24),
                              Expanded(flex: 5, child: _buildAuthCard(compactHeader: true)),
                            ],
                          )
                        : _buildAuthCard(compactHeader: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernancePanel() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: _indigo.withValues(alpha: 0.10), blurRadius: 32, offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthComponents.logoBanner(width: 200, height: 120, fallbackColor: _crimson),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_crimson, _indigo]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'CIJ COMMAND CENTER • HOLDING & LPK',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pusat Kendali Otoritas\nINDOTECH & Jaringan LPK',
            style: TextStyle(color: AuthComponents.textMain, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelola verifikasi cabang LPK berizin Kemnaker, audit KYC Mitra Driver ber-rem ganda, dan transparansi Smart Split 60/27/13.',
            style: TextStyle(color: AuthComponents.textMuted, fontSize: 12.5, height: 1.45),
          ),
          const SizedBox(height: 18),
          _tierRow('1', 'INDOTECH (Master)', 'Otoritas tertinggi: verifikasi LPK, approval Super Admin & fee 13%', _crimson),
          const SizedBox(height: 10),
          _tierRow('2', 'LPK (Super Admin)', 'Operasional cabang: KYC Mitra, kelulusan & E-Sertifikat, omzet 27%', _indigo),
          const SizedBox(height: 10),
          _tierRow('3', 'Mitra Driver (CIJ Partner)', 'Aplikasi terpisah di cij-partner.vercel.app (insentif 60%)', AppColors.emerald),
          const SizedBox(height: 10),
          _tierRow('4', 'Konsumen / Siswa (CIJ Driving)', 'Aplikasi terpisah di cij-driving.vercel.app', _gold),
        ],
      ),
    );
  }

  Widget _tierRow(String num, String title, String subtitle, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(num, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AuthComponents.textMain, fontSize: 12.5, fontWeight: FontWeight.w800)),
              Text(subtitle, style: const TextStyle(color: AuthComponents.textMuted, fontSize: 11, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard({required bool compactHeader}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 18),
          BoxShadow(color: _indigo.withValues(alpha: 0.13), offset: const Offset(0, 14), blurRadius: 34),
          BoxShadow(color: _crimson.withValues(alpha: 0.10), offset: const Offset(8, 10), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 5,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [_crimson, _indigo, _gold]),
            ),
          ),
          if (!compactHeader) ...[
            AuthComponents.logoBanner(width: 204, height: 124, fallbackColor: _crimson),
            const SizedBox(height: 4),
          ],
          AuthComponents.appTitle('CIJ Master'),
          if (_mode == _ConsoleAuthMode.registerLpk) ...[
            const SizedBox(height: 4),
            const Text(
              'Pendaftaran Cabang LPK / Super Admin Baru',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 18),

          if (_error != null) ...[
            AuthComponents.errorBanner(_error!),
            if (_pendingEmail != null && _mode == _ConsoleAuthMode.login) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: _resending ? null : _handleResendVerification,
                  child: Text(
                    _resending
                        ? 'Mengirim ulang tautan verifikasi...'
                        : 'Kirim ulang email verifikasi ke $_pendingEmail →',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _indigo,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
          if (_resendInfo != null && _mode == _ConsoleAuthMode.login)
            AuthComponents.infoBanner(_resendInfo!, color: AppColors.emerald),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: KeyedSubtree(
              key: ValueKey('${_mode.name}-$_resetSent-$_lpkSubmitted'),
              child: _mode == _ConsoleAuthMode.login
                  ? _buildLoginForm()
                  : _mode == _ConsoleAuthMode.registerLpk
                      ? _buildRegisterLpkForm()
                      : _buildForgotForm(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppVersions.console.fullLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AuthComponents.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final bioActive = _enrolledBiometric != null &&
        AuthService.isRoleAllowedForFlavor(_enrolledBiometric!.role, AppFlavor.console);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthComponents.fieldLabel('Username / Email Otoritas'),
        const SizedBox(height: 7),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'INDOTECH / superadmin',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.admin_panel_settings_outlined,
        ),
        const SizedBox(height: 14),

        AuthComponents.fieldLabel('Kata Sandi'),
        const SizedBox(height: 7),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: '••••••••••••',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          obscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          onSubmitted: (_) {
            if (!_loading) _handleLogin();
          },
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AuthComponents.textMuted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),

        AuthComponents.gradientButton(
          label: _loading ? 'Memverifikasi Otoritas...' : 'Masuk ke CIJ Master',
          icon: Icons.workspace_premium_rounded,
          onTap: _loading ? null : _handleLogin,
        ),
        const SizedBox(height: 14),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _resendInfo = null;
              _lpkSubmitted = false;
              _mode = _ConsoleAuthMode.registerLpk;
            }),
            child: const Text(
              'Daftar Akun Master',
              style: TextStyle(
                color: _indigo,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _resetSent = false;
              _mode = _ConsoleAuthMode.forgot;
            }),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Lupa kredensial Console? ',
                style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5),
                children: [
                  TextSpan(
                    text: 'Pemulihan akun.',
                    style: TextStyle(color: _indigo, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        AuthComponents.biometricButton(
          bioActive: bioActive,
          activeName: _enrolledBiometric?.fullName ?? '',
          primaryColor: _indigo,
          ringColor: _crimson,
          onTap: _loading ? null : _handleBiometric,
        ),
      ],
    );
  }

  Widget _buildRegisterLpkForm() {
    if (_lpkSubmitted) {
      return AuthComponents.emailVerificationView(
        email: _pendingEmail ?? _idCtrl.text.trim(),
        accentColor: _indigo,
        title: 'Verifikasi Email & Antrean Master',
        subtitle:
            'Pengajuan $_submittedLpkName terkirim! Konfirmasi email resmi LPK Anda sekarang, lalu tunggu persetujuan izin Kemnaker oleh MASTER INDOTECH.',
        resending: _resending,
        resendInfo: _resendInfo,
        onResend: _handleResendVerification,
        onBackToLogin: () => setState(() {
          _lpkSubmitted = false;
          _error = null;
          _resendInfo = null;
          _passCtrl.clear();
          _mode = _ConsoleAuthMode.login;
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthComponents.infoBanner(
          'Pendaftaran Super Admin / LPK baru wajib diverifikasi oleh MASTER INDOTECH sebelum aktif.',
          color: _indigo,
        ),

        AuthComponents.fieldLabel('Nama Lembaga / LPK'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _lpkNameCtrl,
          hint: 'Contoh: LPK Karya Mandiri Mengemudi',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          prefixIcon: Icons.apartment_rounded,
        ),
        const SizedBox(height: 10),

        AuthComponents.fieldLabel('Kota / Kabupaten Operasional'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _cityCtrl,
          hint: 'Contoh: Purwokerto, Banyumas',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          prefixIcon: Icons.location_city_rounded,
        ),
        const SizedBox(height: 10),

        AuthComponents.fieldLabel('Nomor Izin LPK Kemnaker / NIB'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _licenseCtrl,
          hint: 'KEMNAKER/563/LPK/2026',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          prefixIcon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 10),

        AuthComponents.fieldLabel('Nama Penanggung Jawab (Super Admin LPK)'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _ownerNameCtrl,
          hint: 'Nama lengkap pimpinan / admin LPK',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 10),

        AuthComponents.fieldLabel('Nomor WhatsApp Resmi LPK'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _phoneCtrl,
          hint: '0811-xxxx-xxxx',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 10),

        AuthComponents.fieldLabel('Email Resmi LPK'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'admin@lpk-cabang.id',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 10),

        AuthComponents.fieldLabel('Buat Kata Sandi Akun LPK'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: 'Minimal 6 karakter',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          obscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AuthComponents.textMuted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 18),

        AuthComponents.gradientButton(
          label: _loading ? 'Mengirim Pengajuan...' : 'Ajukan Pendaftaran LPK Baru',
          icon: Icons.domain_add_rounded,
          onTap: _loading ? null : _handleRegisterLpk,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _resendInfo = null;
              _lpkSubmitted = false;
              _mode = _ConsoleAuthMode.login;
            }),
            child: RichText(
              text: const TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: AuthComponents.textMuted, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Masuk ke CIJ Master',
                    style: TextStyle(color: _indigo, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotForm() {
    if (_resetSent) {
      return Column(
        children: [
          const SizedBox(height: 6),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.emerald, width: 2),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: AppColors.emerald, size: 32),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tautan Pemulihan Terkirim!',
            style: TextStyle(color: AuthComponents.textMain, fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Instruksi reset kredensial Console telah dikirim ke ${_resetCtrl.text.trim()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuthComponents.textMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          AuthComponents.gradientButton(
            label: 'Kembali ke Masuk Console',
            gradientColors: const [_crimson, _indigo],
            shadowColor: _indigo,
            onTap: () => setState(() {
              _resetSent = false;
              _mode = _ConsoleAuthMode.login;
            }),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pemulihan Akses Command Center',
          style: TextStyle(color: AuthComponents.textMain, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Masukkan email resmi Master INDOTECH atau Super Admin LPK untuk menerima tautan reset.',
          style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5, height: 1.4),
        ),
        const SizedBox(height: 14),
        AuthComponents.fieldLabel('Email Resmi Console'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _resetCtrl,
          hint: 'superadmin@lpk-cij.id',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: const Color(0xFFFAF9FF),
          prefixIcon: Icons.mark_email_unread_outlined,
        ),
        const SizedBox(height: 18),
        AuthComponents.gradientButton(
          label: _loading ? 'Mengirim...' : 'Kirim Tautan Pemulihan',
          gradientColors: const [_crimson, _indigo],
          shadowColor: _indigo,
          onTap: _loading ? null : _handleForgot,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _mode = _ConsoleAuthMode.login;
            }),
            child: const Text(
              '← Kembali ke Masuk Console',
              style: TextStyle(color: _indigo, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
