import 'package:flutter/material.dart';
import '../../config/app_version.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/otp_service.dart';
import '../../theme/app_theme.dart';
import 'auth_components.dart';

enum _MitraAuthMode { login, register, forgot }

/// Dedicated Login & Sequential Dual-OTP Register Dashboard for App 2: CIJ Mitra (`cij-partner.vercel.app`)
class MitraAuthScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onAuthenticated;

  const MitraAuthScreen({
    super.key,
    required this.appState,
    required this.onAuthenticated,
  });

  @override
  State<MitraAuthScreen> createState() => _MitraAuthScreenState();
}

class _MitraAuthScreenState extends State<MitraAuthScreen> {
  _MitraAuthMode _mode = _MitraAuthMode.login;
  bool _obscurePassword = true;
  bool _loading = false;
  bool _resending = false;
  bool _resetSent = false;
  bool _dualBrakeConfirmed = true;
  int _failedAttempts = 0;
  String? _error;
  String? _infoBanner;
  String? _pendingEmail;
  BiometricBinding? _enrolledBiometric;

  // Sequential Dual-OTP states for Mitra Registration
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
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _phoneOtpCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _emailOtpCtrl = TextEditingController();
  final _carCtrl = TextEditingController();
  final _simCtrl = TextEditingController();
  final _resetCtrl = TextEditingController();

  static const Color _emeraldDeep = Color(0xFF047857);
  static const Color _emerald = Color(0xFF059669);
  static const Color _gold = Color(0xFFF59E0B);
  static const Color _mintBorder = Color(0xFFA7F3D0);

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
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _phoneOtpCtrl.dispose();
    _regEmailCtrl.dispose();
    _emailOtpCtrl.dispose();
    _carCtrl.dispose();
    _simCtrl.dispose();
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
      flavor: AppFlavor.mitra,
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
            _mode = _MitraAuthMode.forgot;
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
    if (!AuthService.isRoleAllowedForFlavor(b.role, AppFlavor.mitra)) {
      setState(() {
        _loading = false;
        _error = AuthService.wrongAppMessage(b.role, AppFlavor.mitra);
      });
      return;
    }

    _failedAttempts = 0;
    widget.appState.login(
      name: b.fullName,
      email: b.email,
      username: b.username,
      role: b.role,
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
        _infoBanner = 'Nomor WhatsApp terverifikasi. Lanjutkan verifikasi email.';
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _handleSendEmailOtp() async {
    if (!_phoneVerified) {
      setState(() => _error = 'Verifikasi OTP Nomor WhatsApp terlebih dahulu.');
      return;
    }
    setState(() {
      _sendingEmailOtp = true;
      _error = null;
      _infoBanner = null;
    });
    final res = await OtpService.sendEmailOtp(
      rawEmail: _regEmailCtrl.text,
      flavor: AppFlavor.mitra,
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
        _infoBanner = 'WhatsApp dan email terverifikasi. Lengkapi data kendaraan dan kata sandi.';
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_phoneVerified || !_emailVerified) {
      setState(() => _error = 'Verifikasi OTP Nomor WhatsApp dan OTP Email terlebih dahulu.');
      return;
    }
    if (_carCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Masukkan jenis kendaraan dan plat nomor.');
      return;
    }
    if (!_dualBrakeConfirmed) {
      setState(() => _error = 'Wajib konfirmasi standar keselamatan Rem Ganda (Dual Brake) & SIM A aktif.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _infoBanner = null;
    });

    final carInfo = _carCtrl.text.trim();
    final simInfo = _simCtrl.text.trim().isEmpty ? 'SIM A Aktif' : _simCtrl.text.trim();

    final result = await AuthService.completeOtpRegistration(
      fullName: _nameCtrl.text,
      verifiedPhone: _verifiedPhone,
      verifiedEmail: _verifiedEmail,
      password: _passCtrl.text,
      role: UserRole.mitra,
      extraMetadata: {
        'car_info': carInfo,
        'sim_type': simInfo,
        'dual_brake': true,
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

    widget.appState.registerNewMitraApplication(
      name: _nameCtrl.text.trim(),
      phone: _verifiedPhone,
      carInfo: carInfo,
      simType: simInfo,
      area: 'Purwokerto Utara',
    );

    final createdEmail = _verifiedEmail;
    _resetRegisterOtpState();
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _regEmailCtrl.clear();
    _carCtrl.clear();
    _simCtrl.clear();
    _passCtrl.clear();
    _idCtrl.text = createdEmail;

    setState(() {
      _loading = false;
      _mode = _MitraAuthMode.login;
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
    final res = await AuthService.resendVerificationEmail(email: email, flavor: AppFlavor.mitra);
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
      setState(() => _error = 'Masukkan email atau nomor WhatsApp Mitra terdaftar.');
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
              Color(0xFFECFDF5),
              Color(0xFFF0FDFA),
              Color(0xFFFEF9C3),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_emerald.withValues(alpha: 0.22), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -70,
              child: Container(
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_gold.withValues(alpha: 0.28), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 18),
                          BoxShadow(color: _emerald.withValues(alpha: 0.14), offset: const Offset(0, 14), blurRadius: 34),
                          BoxShadow(color: _gold.withValues(alpha: 0.14), offset: const Offset(8, 10), blurRadius: 24),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthComponents.logoBanner(width: 210, height: 128, fallbackColor: _emerald),
                          const SizedBox(height: 4),
                          AuthComponents.appTitle('CIJ Mitra'),
                          if (_mode == _MitraAuthMode.register) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'Daftar Akun Mitra',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AuthComponents.textMuted, fontSize: 12.5, fontWeight: FontWeight.w500),
                            ),
                          ],
                          const SizedBox(height: 20),

                          if (_error != null) ...[
                            AuthComponents.errorBanner(_error!),
                            if (_pendingEmail != null && _mode == _MitraAuthMode.login) ...[
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
                                      color: _emeraldDeep,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                          if (_infoBanner != null) AuthComponents.infoBanner(_infoBanner!, color: _emeraldDeep),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            child: KeyedSubtree(
                              key: ValueKey('${_mode.name}-$_resetSent'),
                              child: _mode == _MitraAuthMode.login
                                  ? _buildLoginForm()
                                  : _mode == _MitraAuthMode.register
                                      ? _buildRegisterForm()
                                      : _buildForgotForm(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppVersions.partner.shortLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AuthComponents.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final bioActive = _enrolledBiometric != null &&
        AuthService.isRoleAllowedForFlavor(_enrolledBiometric!.role, AppFlavor.mitra);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthComponents.fieldLabel('Email atau Nomor HP'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'Masukkan email atau nomor HP',
          accentColor: _emerald,
          borderTint: _mintBorder,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        AuthComponents.fieldLabel('Kata Sandi'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: 'Masukkan kata sandi',
          accentColor: _emerald,
          borderTint: _mintBorder,
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
              _mode = _MitraAuthMode.forgot;
            }),
            child: const Text(
              'Lupa kata sandi?',
              style: TextStyle(
                color: _emeraldDeep,
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
              _mode = _MitraAuthMode.register;
            }),
            child: const Text(
              'Daftar Akun Mitra',
              style: TextStyle(
                color: _emeraldDeep,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        AuthComponents.biometricButton(
          bioActive: bioActive,
          activeName: _enrolledBiometric?.fullName ?? '',
          primaryColor: _emeraldDeep,
          ringColor: _emerald,
          onTap: _loading ? null : _handleBiometric,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    final bothVerified = _phoneVerified && _emailVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthComponents.fieldLabel('Nama Lengkap'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _nameCtrl,
          hint: 'Masukkan nama lengkap',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: Colors.white,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Nomor WhatsApp'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _phoneCtrl,
          hint: '0812-xxxx-xxxx',
          accentColor: _emerald,
          borderTint: _phoneVerified ? AppColors.emerald : _mintBorder,
          fillColor: Colors.white,
          enabled: !_phoneVerified,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          suffix: AuthComponents.otpFieldSuffix(
            verified: _phoneVerified,
            sending: _sendingPhoneOtp,
            enabled: true,
            accentColor: _emeraldDeep,
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
            accentColor: _emeraldDeep,
            borderTint: _mintBorder,
            verifying: _verifyingPhoneOtp,
            resending: _sendingPhoneOtp,
            sandboxCode: _phoneSandboxCode,
            onVerify: _handleVerifyPhoneOtp,
            onResend: _handleSendPhoneOtp,
          ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Email'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _regEmailCtrl,
          hint: 'nama@email.com',
          accentColor: _emerald,
          borderTint: _emailVerified ? AppColors.emerald : _mintBorder,
          fillColor: Colors.white,
          enabled: _phoneVerified && !_emailVerified,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          suffix: AuthComponents.otpFieldSuffix(
            verified: _emailVerified,
            sending: _sendingEmailOtp,
            enabled: _phoneVerified,
            accentColor: _emeraldDeep,
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
            accentColor: _emeraldDeep,
            borderTint: _mintBorder,
            verifying: _verifyingEmailOtp,
            resending: _sendingEmailOtp,
            sandboxCode: _emailSandboxCode,
            onVerify: _handleVerifyEmailOtp,
            onResend: _handleSendEmailOtp,
          ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Kendaraan & Plat Nomor'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _carCtrl,
          hint: 'Toyota Avanza - R 1842 BS',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: Colors.white,
          enabled: bothVerified,
          prefixIcon: Icons.directions_car_filled_outlined,
        ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Jenis SIM'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _simCtrl,
          hint: 'SIM A Aktif',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: Colors.white,
          enabled: bothVerified,
          prefixIcon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 12),

        AuthComponents.fieldLabel('Kata Sandi'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: 'Minimal 6 karakter',
          accentColor: _emerald,
          borderTint: _mintBorder,
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
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => setState(() => _dualBrakeConfirmed = !_dualBrakeConfirmed),
          child: Row(
            children: [
              Icon(
                _dualBrakeConfirmed ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: _dualBrakeConfirmed ? _emeraldDeep : AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Armada memiliki Pedal Rem Ganda dan SIM A aktif.',
                  style: TextStyle(color: AuthComponents.textMain, fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        AuthComponents.gradientButton(
          label: _loading ? 'Memproses...' : 'Daftar Mitra',
          onTap: (_loading || !bothVerified) ? null : _handleRegister,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _infoBanner = null;
              _mode = _MitraAuthMode.login;
            }),
            child: RichText(
              text: const TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: AuthComponents.textMuted, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Masuk',
                    style: TextStyle(color: _emeraldDeep, fontWeight: FontWeight.w700),
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
              color: _emerald.withValues(alpha: 0.12),
              border: Border.all(color: _emerald, width: 1.5),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: _emerald, size: 28),
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
              _mode = _MitraAuthMode.login;
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
          'Masukkan email atau nomor WhatsApp yang terdaftar untuk mengatur ulang kata sandi.',
          style: TextStyle(color: AuthComponents.textMuted, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 14),
        AuthComponents.fieldLabel('Email atau Nomor WhatsApp'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _resetCtrl,
          hint: 'nama@email.com',
          accentColor: _emerald,
          borderTint: _mintBorder,
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
              _mode = _MitraAuthMode.login;
            }),
            child: const Text(
              'Kembali ke Halaman Masuk',
              style: TextStyle(color: _emeraldDeep, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
