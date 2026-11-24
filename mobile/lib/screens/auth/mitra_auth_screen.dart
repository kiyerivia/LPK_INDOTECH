import 'package:flutter/material.dart';
import '../../config/app_version.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../theme/app_theme.dart';
import 'auth_components.dart';

enum _MitraAuthMode { login, register, verifyEmail, forgot }

/// Dedicated Login & Register Dashboard for App 2: CIJ Partner (`cij-partner.vercel.app`)
/// Visual Identity: Bright GoPartner Emerald–Teal–Gold Soft-UI tailored for Mitra Driver / Instruktur.
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
  String? _resendInfo;
  String? _pendingEmail;
  String _selectedTransmission = 'Manual & Matic';
  String _selectedArea = 'Purwokerto Utara';
  BiometricBinding? _enrolledBiometric;

  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _carCtrl = TextEditingController();
  final _simCtrl = TextEditingController();
  final _resetCtrl = TextEditingController();

  static const Color _emeraldDeep = Color(0xFF047857);
  static const Color _emerald = Color(0xFF059669);
  static const Color _teal = Color(0xFF0D9488);
  static const Color _gold = Color(0xFFF59E0B);
  static const Color _mintBorder = Color(0xFFA7F3D0);

  static const List<String> _transmissions = ['Manual (MT)', 'Matic (AT)', 'Manual & Matic'];
  static const List<String> _areas = [
    'Purwokerto Utara',
    'Purwokerto Timur',
    'Purwokerto Selatan',
    'Purwokerto Barat',
    'Sokaraja',
    'Baturraden',
  ];

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
    _carCtrl.dispose();
    _simCtrl.dispose();
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
      flavor: AppFlavor.mitra,
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
            _mode = _MitraAuthMode.forgot;
            _error = 'Anda sudah 5x salah memasukkan akun/kata sandi. Silakan pulihkan kata sandi Mitra Anda.';
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

    widget.appState.login(
      name: b.fullName,
      email: b.email,
      username: b.username,
      role: b.role,
    );
    setState(() => _loading = false);
    widget.onAuthenticated();
  }

  Future<void> _handleRegister() async {
    if (_carCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Masukkan tipe armada & plat nomor (contoh: Toyota Avanza • R 1234 AB).');
      return;
    }
    if (!_dualBrakeConfirmed) {
      setState(() => _error = 'Wajib konfirmasi standar keselamatan Rem Ganda (Dual Brake) & SIM A aktif.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _resendInfo = null;
    });

    final result = await AuthService.register(
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _idCtrl.text,
      password: _passCtrl.text,
      role: UserRole.mitra,
      flavor: AppFlavor.mitra,
      extraMetadata: {
        'car_info': '${_carCtrl.text.trim()} ($_selectedTransmission)',
        'sim_type': _simCtrl.text.trim().isEmpty ? 'SIM A Aktif' : _simCtrl.text.trim(),
        'area': _selectedArea,
        'dual_brake': true,
      },
      allowAdminCreation: false,
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
      phone: _phoneCtrl.text.trim().isEmpty ? '-' : _phoneCtrl.text.trim(),
      carInfo: '${_carCtrl.text.trim()} ($_selectedTransmission)',
      simType: _simCtrl.text.trim().isEmpty ? 'SIM A Aktif' : _simCtrl.text.trim(),
      area: _selectedArea,
    );

    if (result.requiresEmailVerification) {
      setState(() {
        _loading = false;
        _pendingEmail = result.pendingEmail ?? _idCtrl.text.trim().toLowerCase();
        _mode = _MitraAuthMode.verifyEmail;
      });
      return;
    }

    if (result.account != null) {
      final acc = result.account!;
      widget.appState.login(
        name: acc.fullName,
        email: acc.email,
        username: acc.username,
        role: UserRole.mitra,
      );
      setState(() => _loading = false);
      widget.onAuthenticated();
    }
  }

  Future<void> _handleResendVerification() async {
    final email = _pendingEmail ?? _idCtrl.text.trim().toLowerCase();
    setState(() {
      _resending = true;
      _error = null;
      _resendInfo = null;
    });
    final res = await AuthService.resendVerificationEmail(email: email, flavor: AppFlavor.mitra);
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
                          Container(
                            width: 64,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(colors: [_emeraldDeep, _teal, _gold]),
                            ),
                          ),
                          AuthComponents.logoBanner(width: 210, height: 126, fallbackColor: _emerald),
                          const SizedBox(height: 4),
                          AuthComponents.appTitle('CIJ Mitra'),
                          if (_mode == _MitraAuthMode.register) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'Pendaftaran Mitra Driver (Smart Split 60% Mitra)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                          const SizedBox(height: 18),

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
                          if (_resendInfo != null && _mode == _MitraAuthMode.login)
                            AuthComponents.infoBanner(_resendInfo!, color: _emeraldDeep),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            child: KeyedSubtree(
                              key: ValueKey('${_mode.name}-$_resetSent'),
                              child: _mode == _MitraAuthMode.login
                                  ? _buildLoginForm()
                                  : _mode == _MitraAuthMode.register
                                      ? _buildRegisterForm()
                                      : _mode == _MitraAuthMode.verifyEmail
                                          ? AuthComponents.emailVerificationView(
                                              email: _pendingEmail ?? _idCtrl.text.trim(),
                                              accentColor: _emeraldDeep,
                                              title: 'Verifikasi Email Mitra',
                                              subtitle:
                                                  'Pengajuan KYC Mitra Driver Anda telah diterima! Konfirmasi alamat email Anda terlebih dahulu sebelum masuk ke CIJ Partner.',
                                              resending: _resending,
                                              resendInfo: _resendInfo,
                                              onResend: _handleResendVerification,
                                              onBackToLogin: () => setState(() {
                                                _error = null;
                                                _resendInfo = null;
                                                _passCtrl.clear();
                                                _mode = _MitraAuthMode.login;
                                              }),
                                            )
                                          : _buildForgotForm(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppVersions.partner.fullLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AuthComponents.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
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
        AuthComponents.fieldLabel('ID Mitra, Nomor HP atau Email'),
        const SizedBox(height: 7),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'mitra / mitra@lpk-cij.id',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 14),

        AuthComponents.fieldLabel('Kata Sandi Mitra'),
        const SizedBox(height: 7),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: '••••••••••••',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
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
          label: _loading ? 'Memverifikasi...' : 'Masuk ke CIJ Mitra',
          icon: Icons.local_taxi_rounded,
          onTap: _loading ? null : _handleLogin,
        ),
        const SizedBox(height: 14),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _resendInfo = null;
              _mode = _MitraAuthMode.register;
            }),
            child: const Text(
              'Daftar Akun Mitra',
              style: TextStyle(
                color: _emeraldDeep,
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
              _mode = _MitraAuthMode.forgot;
            }),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Kendala login Mitra? ',
                style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5),
                children: [
                  TextSpan(
                    text: 'Bantuan / Reset kata sandi.',
                    style: TextStyle(color: _emeraldDeep, fontWeight: FontWeight.w800),
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
          primaryColor: _emeraldDeep,
          ringColor: _emerald,
          onTap: _loading ? null : _handleBiometric,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthComponents.fieldLabel('Nama Lengkap Instruktur / Driver'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _nameCtrl,
          hint: 'Contoh: Bambang Sugiantoro',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Nomor WhatsApp Aktif'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _phoneCtrl,
          hint: '0812-xxxx-xxxx',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Email Mitra'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'mitra.baru@email.com',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Armada & Plat Nomor'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _carCtrl,
          hint: 'Toyota Avanza • R 1842 BS',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
          prefixIcon: Icons.directions_car_filled_outlined,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Nomor / Jenis SIM Aktif'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _simCtrl,
          hint: 'SIM A Umum / SIM A Aktif s/d 2029',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
          prefixIcon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Transmisi Armada'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _transmissions.map((t) {
            final active = _selectedTransmission == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedTransmission = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [AuthComponents.matteTop, AuthComponents.matteBottom],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: active ? null : const Color(0xFFF7FEFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? AuthComponents.matteBorder : _mintBorder,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: active ? Colors.white : AuthComponents.textMain,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Zona Operasi Utama'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FEFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _mintBorder, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedArea,
              isExpanded: true,
              icon: const Icon(Icons.my_location_rounded, color: _emerald, size: 19),
              style: const TextStyle(color: AuthComponents.textMain, fontSize: 13, fontWeight: FontWeight.w600),
              items: _areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedArea = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Buat Kata Sandi'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: 'Minimal 6 karakter',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
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
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => setState(() => _dualBrakeConfirmed = !_dualBrakeConfirmed),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _dualBrakeConfirmed ? _emerald.withValues(alpha: 0.08) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _dualBrakeConfirmed ? _emerald.withValues(alpha: 0.4) : AppColors.danger.withValues(alpha: 0.4),
              ),
            ),
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
                    'Armada siap / terpasang Pedal Rem Ganda (Dual Brake) & SIM A aktif (wajib inspeksi LPK).',
                    style: TextStyle(color: AuthComponents.textMain, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        AuthComponents.gradientButton(
          label: _loading ? 'Mendaftarkan Mitra...' : 'Daftar & Ajukan KYC Mitra',
          icon: Icons.verified_user_rounded,
          onTap: _loading ? null : _handleRegister,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _resendInfo = null;
              _mode = _MitraAuthMode.login;
            }),
            child: RichText(
              text: const TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: AuthComponents.textMuted, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Masuk ke CIJ Mitra',
                    style: TextStyle(color: _emeraldDeep, fontWeight: FontWeight.w800),
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
              color: _emerald.withValues(alpha: 0.14),
              border: Border.all(color: _emerald, width: 2),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: _emerald, size: 32),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tautan Reset Mitra Terkirim!',
            style: TextStyle(color: AuthComponents.textMain, fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Instruksi reset kata sandi mitra telah dikirim ke ${_resetCtrl.text.trim()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuthComponents.textMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          AuthComponents.gradientButton(
            label: 'Kembali ke Masuk Mitra',
            gradientColors: const [_emeraldDeep, _teal],
            shadowColor: _emerald,
            onTap: () => setState(() {
              _resetSent = false;
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
          'Pemulihan Kata Sandi Mitra Driver',
          style: TextStyle(color: AuthComponents.textMain, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Masukkan email atau nomor WhatsApp Mitra terdaftar untuk reset kata sandi.',
          style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5, height: 1.4),
        ),
        const SizedBox(height: 14),
        AuthComponents.fieldLabel('Email / Nomor WhatsApp Mitra'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _resetCtrl,
          hint: 'mitra@lpk-cij.id atau 0812-xxxx',
          accentColor: _emerald,
          borderTint: _mintBorder,
          fillColor: const Color(0xFFF7FEFC),
          prefixIcon: Icons.mark_email_unread_outlined,
        ),
        const SizedBox(height: 18),
        AuthComponents.gradientButton(
          label: _loading ? 'Mengirim...' : 'Kirim Tautan Reset',
          gradientColors: const [_emeraldDeep, _teal],
          shadowColor: _emerald,
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
              '← Kembali ke Masuk Mitra',
              style: TextStyle(color: _emeraldDeep, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
