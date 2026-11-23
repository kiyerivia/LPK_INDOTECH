import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../theme/app_theme.dart';

enum _AuthView { login, register, forgot }

/// Bright & Radiant CIJ Red-Yellow Soft-UI Auth Dashboard
/// Adapts cleanly to each standalone app flavor:
/// - AppFlavor.user: CIJ Driving (Konsumen / Siswa)
/// - AppFlavor.mitra: CIJ Partner (Mitra Driver / Instruktur)
/// - AppFlavor.console: CIJ Command Center (INDOTECH Master & LPK Super Admin — no public signup)
class AuthDashboardScreen extends StatefulWidget {
  final AppState appState;
  final AppFlavor flavor;
  final VoidCallback onAuthenticated;
  final VoidCallback? onBackToPortal;

  const AuthDashboardScreen({
    super.key,
    required this.appState,
    this.flavor = AppFlavor.portal,
    required this.onAuthenticated,
    this.onBackToPortal,
  });

  @override
  State<AuthDashboardScreen> createState() => _AuthDashboardScreenState();
}

class _AuthDashboardScreenState extends State<AuthDashboardScreen> {
  _AuthView _view = _AuthView.login;
  bool _obscurePassword = true;
  bool _loading = false;
  bool _resetSent = false;
  String? _feedbackError;
  String? _feedbackInfo;
  late UserRole _registerRole;
  BiometricBinding? _enrolledBiometric;

  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _resetEmailCtrl = TextEditingController();

  static const Color _cijRed = Color(0xFFDC2626);
  static const Color _cijRedBright = Color(0xFFEF4444);
  static const Color _cijGold = Color(0xFFF59E0B);
  static const Color _cijYellow = Color(0xFFFACC15);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _shadowWarm = Color(0xFFE5C9B0);
  static const Color _textMain = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _registerRole = widget.flavor == AppFlavor.mitra ? UserRole.mitra : UserRole.siswa;
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final binding = await BiometricService.getEnrolledBinding();
    if (mounted) {
      setState(() => _enrolledBiometric = binding);
    }
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _resetEmailCtrl.dispose();
    super.dispose();
  }

  String get _flavorBadgeLabel {
    switch (widget.flavor) {
      case AppFlavor.user:
        return 'APLIKASI KONSUMEN / SISWA';
      case AppFlavor.mitra:
        return 'APLIKASI MITRA DRIVER';
      case AppFlavor.console:
        return 'INDOTECH MASTER & LPK CONSOLE';
      case AppFlavor.portal:
        return 'PORTAL DRIVING PARTNER';
    }
  }

  String get _loginHint {
    switch (widget.flavor) {
      case AppFlavor.user:
        return 'siswa / email@lpk-cij.id';
      case AppFlavor.mitra:
        return 'mitra / email@lpk-cij.id';
      case AppFlavor.console:
        return 'INDOTECH / superadmin';
      case AppFlavor.portal:
        return 'INDOTECH / superadmin / mitra / siswa';
    }
  }

  bool get _canPublicRegister => widget.flavor != AppFlavor.console;

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _feedbackError = null;
      _feedbackInfo = null;
    });

    final result = await AuthService.signIn(
      identifier: _identifierCtrl.text,
      password: _passwordCtrl.text,
      flavor: widget.flavor,
    );

    if (!mounted) return;

    if (!result.success || result.account == null) {
      setState(() {
        _loading = false;
        _feedbackError = result.message;
      });
      return;
    }

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

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _loading = true;
      _feedbackError = null;
      _feedbackInfo = null;
    });

    final bioResult = await BiometricService.authenticateWithBiometrics();
    if (!mounted) return;

    if (!bioResult.success || bioResult.binding == null) {
      setState(() {
        _loading = false;
        _feedbackError = bioResult.message;
      });
      return;
    }

    final b = bioResult.binding!;
    if (!AuthService.isRoleAllowedForFlavor(b.role, widget.flavor)) {
      setState(() {
        _loading = false;
        _feedbackError = AuthService.wrongAppMessage(b.role, widget.flavor);
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

  Future<void> _handleRegister() async {
    setState(() {
      _loading = true;
      _feedbackError = null;
      _feedbackInfo = null;
    });

    final roleToRegister = widget.flavor == AppFlavor.mitra
        ? UserRole.mitra
        : widget.flavor == AppFlavor.user
            ? UserRole.siswa
            : _registerRole;

    final result = await AuthService.register(
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _identifierCtrl.text,
      password: _passwordCtrl.text,
      role: roleToRegister,
      allowAdminCreation: false,
    );

    if (!mounted) return;

    if (!result.success || result.account == null) {
      setState(() {
        _loading = false;
        _feedbackError = result.message;
      });
      return;
    }

    final acc = result.account!;
    widget.appState.login(
      name: acc.fullName,
      email: acc.email,
      username: acc.username,
      role: acc.role,
      superAdmin: false,
    );

    setState(() => _loading = false);
    widget.onAuthenticated();
  }

  Future<void> _handleResetPassword() async {
    final target = _resetEmailCtrl.text.trim();
    if (target.isEmpty) {
      setState(() => _feedbackError = 'Masukkan email atau nomor WhatsApp terdaftar.');
      return;
    }

    setState(() {
      _loading = true;
      _feedbackError = null;
    });

    if (target.contains('@')) {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(target);
      } catch (_) {}
    } else {
      await Future.delayed(const Duration(milliseconds: 350));
    }

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
              Color(0xFFFFF5F5),
              Color(0xFFFFFBF0),
              Color(0xFFFFF3C4),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_cijRedBright.withValues(alpha: 0.22), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -70,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_cijYellow.withValues(alpha: 0.35), Colors.transparent],
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
                    constraints: const BoxConstraints(maxWidth: 410),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
                      decoration: BoxDecoration(
                        color: _surface.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 18),
                          BoxShadow(color: _cijRed.withValues(alpha: 0.10), offset: const Offset(0, 14), blurRadius: 34),
                          BoxShadow(color: _cijGold.withValues(alpha: 0.16), offset: const Offset(8, 10), blurRadius: 24),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(colors: [_cijRed, _cijGold, _cijYellow]),
                            ),
                          ),

                          _buildLogoBanner(),

                          if (widget.flavor != AppFlavor.portal) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _cijRed.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _cijGold.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                _flavorBadgeLabel,
                                style: const TextStyle(
                                  color: _cijRed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          ],

                          if (_view != _AuthView.login) ...[
                            const SizedBox(height: 6),
                            Text(
                              _view == _AuthView.register
                                  ? (widget.flavor == AppFlavor.mitra
                                      ? 'Pendaftaran Mitra Driver / Instruktur'
                                      : 'Pendaftaran Akun Konsumen / Siswa')
                                  : 'Pemulihan Kata Sandi',
                              style: const TextStyle(
                                color: _textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          if (_feedbackError != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: _cijRed.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _cijRed.withValues(alpha: 0.35)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.gpp_bad_rounded, color: _cijRed, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _feedbackError!,
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
                            ),
                          ],

                          if (_feedbackInfo != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                _feedbackInfo!,
                                style: const TextStyle(color: AppColors.emerald, fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            child: KeyedSubtree(
                              key: ValueKey('${_view.name}-$_resetSent'),
                              child: _view == _AuthView.login
                                  ? _buildLoginView()
                                  : _view == _AuthView.register
                                      ? _buildRegisterView()
                                      : _buildForgotView(),
                            ),
                          ),

                          if (widget.onBackToPortal != null) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: widget.onBackToPortal,
                              child: const Text(
                                '← Ganti Aplikasi (Portal Ekosistem CIJ)',
                                style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildLogoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Image.asset(
        'assets/logo.png',
        width: 240,
        height: 154,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(
          Icons.directions_car_rounded,
          size: 72,
          color: _cijRed,
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    final bioActive = _enrolledBiometric != null &&
        AuthService.isRoleAllowedForFlavor(_enrolledBiometric!.role, widget.flavor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Nomor HP, email atau username'),
        const SizedBox(height: 8),
        _buildDebossedInput(
          controller: _identifierCtrl,
          hint: _loginHint,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),

        _fieldLabel('Kata Sandi'),
        const SizedBox(height: 8),
        _buildDebossedInput(
          controller: _passwordCtrl,
          hint: '••••••••••••',
          obscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          onSubmitted: (_) {
            if (!_loading) _handleLogin();
          },
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _textMuted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 24),

        _buildActionButton(
          label: _loading ? 'Memverifikasi...' : 'Masuk',
          onTap: _loading ? null : _handleLogin,
        ),
        const SizedBox(height: 18),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _feedbackError = null;
              _resetSent = false;
              _view = _AuthView.forgot;
            }),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Lupa detail login? ',
                style: TextStyle(color: _textMuted, fontSize: 11.5),
                children: [
                  TextSpan(
                    text: 'Bantuan masuk / Lupa password.',
                    style: TextStyle(color: _cijRed, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _loading ? null : _handleBiometricLogin,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: bioActive ? AppColors.emerald : _cijGold,
                      width: 2.4,
                    ),
                    boxShadow: [
                      const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
                      BoxShadow(
                        color: (bioActive ? AppColors.emerald : _cijRed).withValues(alpha: 0.22),
                        offset: const Offset(4, 6),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 40,
                    color: bioActive ? AppColors.emerald : _cijRed,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bioActive
                    ? 'Sidik jari aktif: ${_enrolledBiometric!.fullName}'
                    : 'Verifikasi sidik jari perangkat (Biometrik)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: bioActive ? AppColors.emerald : _textMuted,
                  fontSize: 10.5,
                  fontWeight: bioActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        if (_canPublicRegister) ...[
          const SizedBox(height: 22),
          Center(
            child: GestureDetector(
              onTap: () => setState(() {
                _feedbackError = null;
                _view = _AuthView.register;
              }),
              child: RichText(
                text: const TextSpan(
                  text: 'Belum punya akun? ',
                  style: TextStyle(color: _textMuted, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Daftar sekarang',
                      style: TextStyle(color: _cijRed, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Akses khusus internal INDOTECH Master & Super Admin LPK',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 10.5, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRegisterView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.flavor == AppFlavor.portal) ...[
          _fieldLabel('Daftar Sebagai'),
          const SizedBox(height: 8),
          Row(
            children: [
              _registerRoleChip(UserRole.siswa, 'Siswa', Icons.school_rounded),
              const SizedBox(width: 12),
              _registerRoleChip(UserRole.mitra, 'Mitra Driver', Icons.local_taxi_rounded),
            ],
          ),
          const SizedBox(height: 14),
        ],

        _fieldLabel('Nama Lengkap'),
        const SizedBox(height: 6),
        _buildDebossedInput(
          controller: _nameCtrl,
          hint: 'Masukkan nama lengkap',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),

        _fieldLabel('Nomor WhatsApp'),
        const SizedBox(height: 6),
        _buildDebossedInput(
          controller: _phoneCtrl,
          hint: '0812-xxxx-xxxx',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 12),

        _fieldLabel('Email'),
        const SizedBox(height: 6),
        _buildDebossedInput(
          controller: _identifierCtrl,
          hint: 'nama@email.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 12),

        _fieldLabel('Buat Kata Sandi'),
        const SizedBox(height: 6),
        _buildDebossedInput(
          controller: _passwordCtrl,
          hint: 'Minimal 6 karakter',
          obscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _textMuted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 22),

        _buildActionButton(
          label: _loading ? 'Mendaftarkan...' : 'Daftar Akun',
          onTap: _loading ? null : _handleRegister,
        ),
        const SizedBox(height: 18),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _feedbackError = null;
              _view = _AuthView.login;
            }),
            child: RichText(
              text: const TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(color: _textMuted, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Masuk di sini',
                    style: TextStyle(color: _cijRed, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _registerRoleChip(UserRole role, String label, IconData icon) {
    final active = _registerRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _registerRole = role),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            gradient: active ? const LinearGradient(colors: [_cijRed, _cijGold]) : null,
            color: active ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? Colors.transparent : _shadowWarm.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: (active ? _cijRed : _shadowWarm).withValues(alpha: active ? 0.28 : 0.35),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: active ? Colors.white : _textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : _textMain,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotView() {
    if (_resetSent) {
      return Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.emerald, width: 2),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: AppColors.emerald, size: 34),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tautan Reset Terkirim!',
            style: TextStyle(color: _textMain, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Instruksi pemulihan kata sandi telah dikirim ke ${_resetEmailCtrl.text.trim()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textMuted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 22),
          _buildActionButton(
            label: 'Kembali ke Halaman Masuk',
            onTap: () => setState(() {
              _resetSent = false;
              _view = _AuthView.login;
            }),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Masukkan email atau nomor WhatsApp yang terdaftar untuk menerima tautan reset kata sandi.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textMuted, fontSize: 12, height: 1.45),
        ),
        const SizedBox(height: 20),

        _fieldLabel('Email atau Nomor WhatsApp'),
        const SizedBox(height: 8),
        _buildDebossedInput(
          controller: _resetEmailCtrl,
          hint: 'email@lpk-cij.id / 0812-xxxx',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mark_email_unread_outlined,
        ),
        const SizedBox(height: 24),

        _buildActionButton(
          label: _loading ? 'Mengirim...' : 'Kirim Link Reset',
          onTap: _loading ? null : _handleResetPassword,
        ),
        const SizedBox(height: 20),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _feedbackError = null;
              _view = _AuthView.login;
            }),
            child: RichText(
              text: const TextSpan(
                text: 'Ingat kata sandi kamu? ',
                style: TextStyle(color: _textMuted, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Kembali ke Masuk',
                    style: TextStyle(color: _cijRed, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: const TextStyle(color: _textMain, fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildDebossedInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    return _BrightConcaveField(
      height: 52,
      radius: 26,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: _textMain, fontSize: 14, fontWeight: FontWeight.w600),
        cursorColor: _cijRed,
        decoration: InputDecoration(
          filled: false,
          hintText: hint,
          hintStyle: TextStyle(color: _textMuted.withValues(alpha: 0.7), fontSize: 13),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: _cijRed.withValues(alpha: 0.75), size: 19)
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_cijRed, _cijRedBright, _cijGold],
          ),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(color: _cijRed.withValues(alpha: 0.32), offset: const Offset(0, 8), blurRadius: 18),
            BoxShadow(color: _cijYellow.withValues(alpha: 0.28), offset: const Offset(4, 2), blurRadius: 14),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _BrightConcaveField extends StatelessWidget {
  final double height;
  final double radius;
  final Widget child;

  const _BrightConcaveField({
    required this.height,
    required this.radius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF3E4), Color(0xFFFFFFFF)],
        ),
        border: Border.all(
          color: const Color(0xFFF3D5B5).withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          foregroundPainter: _BrightInnerShadowPainter(radius: radius),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _BrightInnerShadowPainter extends CustomPainter {
  final double radius;
  _BrightInnerShadowPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.save();
    canvas.clipRRect(rrect);

    final warmShadow = Paint()
      ..color = const Color(0xFFD9B696).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(2, 3)), Radius.circular(radius)),
      warmShadow,
    );

    final lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(-2, -2)), Radius.circular(radius)),
      lightPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrightInnerShadowPainter oldDelegate) => false;
}
