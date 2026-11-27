import 'package:flutter/material.dart';
import '../../config/app_version.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/otp_service.dart';
import '../../theme/app_theme.dart';
import 'auth_components.dart';

enum _ConsoleAuthMode { login, registerLpk, forgot }

/// Dedicated Executive Login & Sequential Dual-OTP LPK Registration Dashboard for App 3:
/// CIJ Master (`cij-console.vercel.app`)
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
  int _failedAttempts = 0;
  String? _error;
  String? _infoBanner;
  String? _pendingEmail;
  BiometricBinding? _enrolledBiometric;

  // Sequential Dual-OTP states for LPK Registration
  bool _phoneOtpSent = false;
  bool _phoneVerified = false;
  bool _sendingPhoneOtp = false;
  bool _verifyingPhoneOtp = false;
  String? _phoneSandboxCode;
  String _verifiedPhone = '';

  bool _emailOtpSent = false;
  bool _emailVerified = false;
  bool _sendingEmailOtp = false;
  bool _verifyingEmailOtp = false;
  String? _emailSandboxCode;
  String _verifiedEmail = '';

  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _lpkNameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _phoneOtpCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _emailOtpCtrl = TextEditingController();
  final _resetCtrl = TextEditingController();

  static const Color _crimson = Color(0xFFB91C1C);
  static const Color _indigo = Color(0xFF4338CA);
  static const Color _indigoBright = Color(0xFF6366F1);
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
    _phoneOtpCtrl.dispose();
    _regEmailCtrl.dispose();
    _emailOtpCtrl.dispose();
    _resetCtrl.dispose();
    super.dispose();
  }

  void _resetRegisterOtpState() {
    _phoneOtpSent = false;
    _phoneVerified = false;
    _sendingPhoneOtp = false;
    _verifyingPhoneOtp = false;
    _phoneSandboxCode = null;
    _verifiedPhone = '';
    _phoneOtpCtrl.clear();

    _emailOtpSent = false;
    _emailVerified = false;
    _sendingEmailOtp = false;
    _verifyingEmailOtp = false;
    _emailSandboxCode = null;
    _verifiedEmail = '';
    _emailOtpCtrl.clear();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
      _infoBanner = null;
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
            _error = 'Login gagal 5 kali. Silakan atur ulang kata sandi Anda.';
          } else {
            _error = '${result.message} ($_failedAttempts/5)';
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
      phone: acc.phone,
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
      _infoBanner = null;
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

    _failedAttempts = 0;
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

  Future<void> _handleSendPhoneOtp() async {
    setState(() {
      _sendingPhoneOtp = true;
      _error = null;
      _infoBanner = null;
    });
    final res = await OtpService.sendPhoneOtp(_phoneCtrl.text);
    if (!mounted) return;
    setState(() {
      _sendingPhoneOtp = false;
      if (res.success) {
        _phoneOtpSent = true;
        _phoneSandboxCode = res.sandboxPreviewCode;
        _infoBanner = res.message;
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _handleVerifyPhoneOtp() async {
    setState(() {
      _verifyingPhoneOtp = true;
      _error = null;
      _infoBanner = null;
    });
    final res = await OtpService.verifyPhoneOtp(
      rawPhone: _phoneCtrl.text,
      token: _phoneOtpCtrl.text,
    );
    if (!mounted) return;
    setState(() {
      _verifyingPhoneOtp = false;
      if (res.success) {
        _phoneVerified = true;
        _phoneOtpSent = false;
        _phoneSandboxCode = null;
        _verifiedPhone = OtpService.normalizeIndonesianPhone(_phoneCtrl.text) ?? _phoneCtrl.text.trim();
        _phoneOtpCtrl.clear();
        _infoBanner = 'Nomor WhatsApp terverifikasi. Lanjutkan verifikasi email LPK.';
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _handleSendEmailOtp() async {
    if (!_phoneVerified) {
      setState(() => _error = 'Verifikasi OTP Nomor WhatsApp resmi LPK terlebih dahulu.');
      return;
    }
    setState(() {
      _sendingEmailOtp = true;
      _error = null;
      _infoBanner = null;
    });
    final res = await OtpService.sendEmailOtp(
      rawEmail: _regEmailCtrl.text,
      flavor: AppFlavor.console,
    );
    if (!mounted) return;
    setState(() {
      _sendingEmailOtp = false;
      if (res.success) {
        _emailOtpSent = true;
        _emailSandboxCode = res.sandboxPreviewCode;
        _infoBanner = res.message;
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _handleVerifyEmailOtp() async {
    setState(() {
      _verifyingEmailOtp = true;
      _error = null;
      _infoBanner = null;
    });
    final res = await OtpService.verifyEmailOtp(
      rawEmail: _regEmailCtrl.text,
      token: _emailOtpCtrl.text,
    );
    if (!mounted) return;
    setState(() {
      _verifyingEmailOtp = false;
      if (res.success) {
        _emailVerified = true;
        _emailOtpSent = false;
        _emailSandboxCode = null;
        _verifiedEmail = _regEmailCtrl.text.trim().toLowerCase();
        _emailOtpCtrl.clear();
        _infoBanner = 'WhatsApp dan email terverifikasi. Lengkapi data LPK dan kata sandi.';
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _handleRegisterLpk() async {
    if (!_phoneVerified || !_emailVerified) {
      setState(() => _error = 'Verifikasi OTP Nomor WhatsApp dan OTP Email terlebih dahulu.');
      return;
    }
    if (_lpkNameCtrl.text.trim().isEmpty ||
        _cityCtrl.text.trim().isEmpty ||
        _licenseCtrl.text.trim().isEmpty ||
        _ownerNameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Lengkapi nama LPK, kota, nomor izin Kemnaker, dan nama penanggung jawab.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _infoBanner = null;
    });

    final branchName = _lpkNameCtrl.text.trim();
    final result = await AuthService.completeOtpRegistration(
      fullName: '${_ownerNameCtrl.text.trim()} ($branchName)',
      verifiedPhone: _verifiedPhone,
      verifiedEmail: _verifiedEmail,
      password: _passCtrl.text,
      role: UserRole.admin,
      isLpkApplicant: true,
      extraMetadata: {
        'lpk_name': branchName,
        'city': _cityCtrl.text.trim(),
        'license_number': _licenseCtrl.text.trim(),
      },
    );
    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _loading = false;
        _error = result.message;
      });
      return;
    }

    widget.appState.registerLpkBranch(
      name: branchName,
      city: _cityCtrl.text.trim(),
      licenseNumber: _licenseCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      ownerPhone: _verifiedPhone,
    );

    final createdEmail = _verifiedEmail;
    _resetRegisterOtpState();
    _lpkNameCtrl.clear();
    _cityCtrl.clear();
    _licenseCtrl.clear();
    _ownerNameCtrl.clear();
    _phoneCtrl.clear();
    _regEmailCtrl.clear();
    _passCtrl.clear();
    _idCtrl.text = createdEmail;

    setState(() {
      _loading = false;
      _mode = _ConsoleAuthMode.login;
      _infoBanner = result.message;
    });
  }

  Future<void> _handleResendVerification() async {
    final email = _pendingEmail ?? _idCtrl.text.trim().toLowerCase();
    setState(() {
      _resending = true;
      _error = null;
      _infoBanner = null;
    });
    final res = await AuthService.resendVerificationEmail(email: email, flavor: AppFlavor.console);
    if (!mounted) return;
    setState(() {
      _resending = false;
      if (res.success) {
        _infoBanner = res.message;
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
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildAuthCard(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
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
          AuthComponents.logoBanner(width: 210, height: 128, fallbackColor: _crimson),
          const SizedBox(height: 4),
          AuthComponents.appTitle('CIJ Master'),
          if (_mode == _ConsoleAuthMode.registerLpk) ...[
            const SizedBox(height: 4),
            const Text(
              'Daftar LPK Baru',
              textAlign: TextAlign.center,
              style: TextStyle(color: AuthComponents.textMuted, fontSize: 12.5, fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 20),

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
          if (_infoBanner != null) AuthComponents.infoBanner(_infoBanner!, color: AppColors.emerald),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: KeyedSubtree(
              key: ValueKey('${_mode.name}-$_resetSent'),
              child: _mode == _ConsoleAuthMode.login
                  ? _buildLoginForm()
                  : _mode == _ConsoleAuthMode.registerLpk
                      ? _buildRegisterLpkForm()
                      : _buildForgotForm(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppVersions.console.shortLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AuthComponents.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
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
        AuthComponents.fieldLabel('Username atau Email'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'Masukkan username atau email',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        AuthComponents.fieldLabel('Kata Sandi'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: 'Masukkan kata sandi',
          accentColor: _indigo,
          borderTint: _indigoBorder,
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
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _infoBanner = null;
              _resetSent = false;
              _mode = _ConsoleAuthMode.forgot;
            }),
            child: const Text(
              'Lupa kata sandi?',
              style: TextStyle(
                color: _indigo,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        AuthComponents.gradientButton(
          label: _loading ? 'Memproses...' : 'Masuk',
          onTap: _loading ? null : _handleLogin,
        ),
        const SizedBox(height: 16),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _infoBanner = null;
              _resetRegisterOtpState();
              _mode = _ConsoleAuthMode.registerLpk;
            }),
            child: const Text(
              'Daftar Akun Master',
              style: TextStyle(
                color: _indigo,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: _loading
                ? null
                : () {
                    _idCtrl.text = AuthService.demoMasterEmail;
                    _passCtrl.text = AuthService.demoMasterPassword;
                    _handleLogin();
                  },
            child: const Text(
              'Gunakan akun demo untuk login',
              style: TextStyle(
                color: AuthComponents.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
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
    final bothVerified = _phoneVerified && _emailVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthComponents.fieldLabel('Nomor WhatsApp LPK'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _phoneCtrl,
          hint: '0811-xxxx-xxxx',
          accentColor: _indigo,
          borderTint: _phoneVerified ? AppColors.emerald : _indigoBorder,
          fillColor: Colors.white,
          enabled: !_phoneVerified,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          suffix: AuthComponents.otpFieldSuffix(
            verified: _phoneVerified,
            sending: _sendingPhoneOtp,
            enabled: true,
            accentColor: _indigo,
            onSendOtp: _handleSendPhoneOtp,
            onChangeTarget: () => setState(() {
              _phoneVerified = false;
              _phoneOtpSent = false;
              _emailVerified = false;
              _emailOtpSent = false;
              _error = null;
              _infoBanner = null;
            }),
          ),
        ),
        if (_phoneOtpSent && !_phoneVerified)
          AuthComponents.otpVerifyBox(
            title: 'Kode OTP WhatsApp',
            otpController: _phoneOtpCtrl,
            accentColor: _indigo,
            borderTint: _indigoBorder,
            verifying: _verifyingPhoneOtp,
            resending: _sendingPhoneOtp,
            sandboxCode: _phoneSandboxCode,
            onVerify: _handleVerifyPhoneOtp,
            onResend: _handleSendPhoneOtp,
          ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Email LPK'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _regEmailCtrl,
          hint: 'admin@lpk-cabang.id',
          accentColor: _indigo,
          borderTint: _emailVerified ? AppColors.emerald : _indigoBorder,
          fillColor: Colors.white,
          enabled: _phoneVerified && !_emailVerified,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          suffix: AuthComponents.otpFieldSuffix(
            verified: _emailVerified,
            sending: _sendingEmailOtp,
            enabled: _phoneVerified,
            accentColor: _indigo,
            onSendOtp: _handleSendEmailOtp,
            onChangeTarget: () => setState(() {
              _emailVerified = false;
              _emailOtpSent = false;
              _error = null;
              _infoBanner = null;
            }),
          ),
        ),
        if (_emailOtpSent && !_emailVerified)
          AuthComponents.otpVerifyBox(
            title: 'Kode OTP Email',
            otpController: _emailOtpCtrl,
            accentColor: _indigo,
            borderTint: _indigoBorder,
            verifying: _verifyingEmailOtp,
            resending: _sendingEmailOtp,
            sandboxCode: _emailSandboxCode,
            onVerify: _handleVerifyEmailOtp,
            onResend: _handleSendEmailOtp,
          ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Nama LPK'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _lpkNameCtrl,
          hint: 'Masukkan nama lembaga',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: Colors.white,
          enabled: bothVerified,
          prefixIcon: Icons.apartment_rounded,
        ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Kota / Kabupaten'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _cityCtrl,
          hint: 'Contoh: Banyumas',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: Colors.white,
          enabled: bothVerified,
          prefixIcon: Icons.location_city_rounded,
        ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Nomor Izin Kemnaker / NIB'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _licenseCtrl,
          hint: 'KEMNAKER/563/LPK/2026',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: Colors.white,
          enabled: bothVerified,
          prefixIcon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Penanggung Jawab'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _ownerNameCtrl,
          hint: 'Nama pimpinan / admin LPK',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: Colors.white,
          enabled: bothVerified,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Kata Sandi'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: 'Minimal 6 karakter',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          fillColor: Colors.white,
          enabled: bothVerified,
          obscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: bothVerified
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AuthComponents.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
        ),
        const SizedBox(height: 20),

        AuthComponents.gradientButton(
          label: _loading ? 'Memproses...' : 'Ajukan Pendaftaran',
          onTap: (_loading || !bothVerified) ? null : _handleRegisterLpk,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _infoBanner = null;
              _mode = _ConsoleAuthMode.login;
            }),
            child: RichText(
              text: const TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: AuthComponents.textMuted, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Masuk',
                    style: TextStyle(color: _indigo, fontWeight: FontWeight.w700),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.emerald, width: 1.5),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: AppColors.emerald, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tautan Reset Terkirim',
            style: TextStyle(color: AuthComponents.textMain, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Instruksi pengaturan ulang kata sandi telah dikirim ke ${_resetCtrl.text.trim()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuthComponents.textMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          AuthComponents.gradientButton(
            label: 'Kembali ke Halaman Masuk',
            onTap: () => setState(() {
              _resetSent = false;
              _error = null;
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
          'Lupa Kata Sandi',
          style: TextStyle(color: AuthComponents.textMain, fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Masukkan email akun Master atau Admin LPK yang terdaftar untuk mengatur ulang kata sandi.',
          style: TextStyle(color: AuthComponents.textMuted, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 14),
        AuthComponents.fieldLabel('Email'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _resetCtrl,
          hint: 'nama@email.com',
          accentColor: _indigo,
          borderTint: _indigoBorder,
          prefixIcon: Icons.mark_email_unread_outlined,
        ),
        const SizedBox(height: 18),
        AuthComponents.gradientButton(
          label: _loading ? 'Mengirim...' : 'Kirim Tautan Reset',
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
              'Kembali ke Halaman Masuk',
              style: TextStyle(color: _indigo, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
