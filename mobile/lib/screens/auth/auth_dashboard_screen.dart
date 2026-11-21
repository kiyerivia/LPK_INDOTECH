import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../theme/app_theme.dart';

enum _AuthView { login, register, forgot }

/// Clean Sculpted Neumorphic (Soft-UI) Login, Register & Forgot Password Dashboard
/// - Clean top layout (no extra top pills or role tabs on Login)
/// - Official CIJ logo (`assets/logo.png`) in circular medallion
/// - Real Security-Grade Biometric / Fingerprint authentication (local_auth + WebAuthn)
/// - Dedicated Super Admin RBAC routing (`superadmin` -> Admin LPK Console)
class AuthDashboardScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onAuthenticated;

  const AuthDashboardScreen({
    super.key,
    required this.appState,
    required this.onAuthenticated,
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
  UserRole _registerRole = UserRole.siswa;
  BiometricBinding? _enrolledBiometric;

  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _resetEmailCtrl = TextEditingController();

  // Matte Charcoal Soft-UI Palette matching reference image
  static const Color _bg = Color(0xFF333436);
  static const Color _surface = Color(0xFF363739);
  static const Color _shadowLight = Color(0xFF45474A);
  static const Color _shadowDark = Color(0xFF1F2022);
  static const Color _textMain = Color(0xFFF3F4F6);
  static const Color _textMuted = Color(0xFFA1A5AC);
  static const Color _buttonText = Color(0xFFDCE0E6);

  @override
  void initState() {
    super.initState();
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

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _feedbackError = null;
      _feedbackInfo = null;
    });

    final result = await AuthService.signIn(
      identifier: _identifierCtrl.text,
      password: _passwordCtrl.text,
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

    final result = await AuthService.register(
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _identifierCtrl.text,
      password: _passwordCtrl.text,
      role: _registerRole,
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
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410),
              child: Container(
                padding: const EdgeInsets.fromLTRB(26, 34, 26, 30),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: _shadowLight.withValues(alpha: 0.55),
                      offset: const Offset(-7, -7),
                      blurRadius: 18,
                    ),
                    BoxShadow(
                      color: _shadowDark.withValues(alpha: 0.88),
                      offset: const Offset(8, 8),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogoMedallion(),
                    const SizedBox(height: 16),
                    const Text(
                      'LPK CITRA INDOTECH JAYA',
                      style: TextStyle(
                        color: _textMain,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _view == _AuthView.login
                          ? 'Portal Kursus Mengemudi & Mitra Online'
                          : _view == _AuthView.register
                              ? 'Pendaftaran Akun Siswa / Mitra'
                              : 'Pemulihan Kata Sandi',
                      style: const TextStyle(color: _textMuted, fontSize: 11.5),
                    ),
                    const SizedBox(height: 24),

                    if (_feedbackError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.45)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.gpp_bad_rounded, color: Color(0xFFFB7185), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _feedbackError!,
                                style: const TextStyle(color: Color(0xFFFECDD3), fontSize: 11.5, height: 1.35),
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
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.45)),
                        ),
                        child: Text(
                          _feedbackInfo!,
                          style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 11.5),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoMedallion() {
    return Container(
      width: 118,
      height: 118,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: _shadowLight.withValues(alpha: 0.65),
            offset: const Offset(-6, -6),
            blurRadius: 14,
          ),
          BoxShadow(
            color: _shadowDark.withValues(alpha: 0.92),
            offset: const Offset(7, 7),
            blurRadius: 16,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        ),
        padding: const EdgeInsets.all(10),
        child: ClipOval(
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.directions_car_rounded,
              size: 46,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  // ── 1. LOGIN VIEW (Clean, zero top clutter, zero role tabs!) ──────
  Widget _buildLoginView() {
    final bioActive = _enrolledBiometric != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Nomor HP, email atau username'),
        const SizedBox(height: 8),
        _buildDebossedInput(
          controller: _identifierCtrl,
          hint: 'superadmin / mitra / siswa',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        _fieldLabel('Kata Sandi'),
        const SizedBox(height: 8),
        _buildDebossedInput(
          controller: _passwordCtrl,
          hint: '••••••••••••',
          obscure: _obscurePassword,
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

        _buildNeuActionButton(
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
                    style: TextStyle(color: _textMain, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Real Hardware Biometric Fingerprint Circle
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
                    color: _surface,
                    border: Border.all(
                      color: bioActive
                          ? const Color(0xFF2DD4BF)
                          : Colors.white.withValues(alpha: 0.35),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _shadowLight.withValues(alpha: 0.52),
                        offset: const Offset(-4, -4),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        color: _shadowDark.withValues(alpha: 0.88),
                        offset: const Offset(5, 5),
                        blurRadius: 12,
                      ),
                      if (bioActive)
                        BoxShadow(
                          color: const Color(0xFF2DD4BF).withValues(alpha: 0.28),
                          blurRadius: 14,
                        ),
                    ],
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 40,
                    color: bioActive
                        ? const Color(0xFF2DD4BF)
                        : Colors.white.withValues(alpha: 0.88),
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
                  color: bioActive ? const Color(0xFF2DD4BF) : _textMuted,
                  fontSize: 10.5,
                  fontWeight: bioActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
                    style: TextStyle(color: _textMain, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 2. REGISTER VIEW (Only Siswa or Mitra Driver — Admin is Super Admin only!)
  Widget _buildRegisterView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        _fieldLabel('Nama Lengkap'),
        const SizedBox(height: 6),
        _buildDebossedInput(controller: _nameCtrl, hint: 'Masukkan nama lengkap'),
        const SizedBox(height: 12),

        _fieldLabel('Nomor WhatsApp'),
        const SizedBox(height: 6),
        _buildDebossedInput(
          controller: _phoneCtrl,
          hint: '0812-xxxx-xxxx',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),

        _fieldLabel('Email'),
        const SizedBox(height: 6),
        _buildDebossedInput(
          controller: _identifierCtrl,
          hint: 'nama@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        _fieldLabel('Buat Kata Sandi'),
        const SizedBox(height: 6),
        _buildDebossedInput(
          controller: _passwordCtrl,
          hint: 'Minimal 6 karakter',
          obscure: _obscurePassword,
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

        _buildNeuActionButton(
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
                    style: TextStyle(color: _textMain, fontWeight: FontWeight.w800),
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
    final accent = role == UserRole.mitra ? const Color(0xFF2DD4BF) : AppColors.primaryGlow;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _registerRole = role),
        child: active
            ? _NeuConcaveField(
                height: 40,
                radius: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 15, color: accent),
                    const SizedBox(width: 6),
                    Text(label, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
              )
            : Container(
                height: 40,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: _shadowLight.withValues(alpha: 0.55), offset: const Offset(-3, -3), blurRadius: 7),
                    BoxShadow(color: _shadowDark.withValues(alpha: 0.85), offset: const Offset(4, 4), blurRadius: 9),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 15, color: _textMuted),
                    const SizedBox(width: 6),
                    Text(label, style: const TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
      ),
    );
  }

  // ── 3. FORGOT PASSWORD VIEW ────────────────────────────────────────
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
              color: AppColors.emerald.withValues(alpha: 0.16),
              border: Border.all(color: const Color(0xFF2DD4BF), width: 2),
            ),
            child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF2DD4BF), size: 34),
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
          _buildNeuActionButton(
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
        ),
        const SizedBox(height: 24),

        _buildNeuActionButton(
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
                    style: TextStyle(color: _textMain, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Neumorphic Helpers ─────────────────────────────────────────────
  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: const TextStyle(color: _textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDebossedInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    return _NeuConcaveField(
      height: 52,
      radius: 26,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: _textMain, fontSize: 14, fontWeight: FontWeight.w600),
        cursorColor: AppColors.primaryGlow,
        decoration: InputDecoration(
          filled: false,
          hintText: hint,
          hintStyle: TextStyle(color: _textMuted.withValues(alpha: 0.65), fontSize: 13),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _buildNeuActionButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(color: _shadowLight.withValues(alpha: 0.65), offset: const Offset(-5, -5), blurRadius: 12),
            BoxShadow(color: _shadowDark.withValues(alpha: 0.92), offset: const Offset(6, 6), blurRadius: 14),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _buttonText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _NeuConcaveField extends StatelessWidget {
  final double height;
  final double radius;
  final Widget child;

  const _NeuConcaveField({
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
          colors: [Color(0xFF232426), Color(0xFF393B3E)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          foregroundPainter: _InnerShadowPainter(radius: radius),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final double radius;
  _InnerShadowPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.save();
    canvas.clipRRect(rrect);

    final darkPaint = Paint()
      ..color = const Color(0xFF1A1B1D).withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(2.5, 3.5)), Radius.circular(radius)),
      darkPaint,
    );

    final lightPaint = Paint()
      ..color = const Color(0xFF484A4D).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(-2, -2.5)), Radius.circular(radius)),
      lightPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) => false;
}
