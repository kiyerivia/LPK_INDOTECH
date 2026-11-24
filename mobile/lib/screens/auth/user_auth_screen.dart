import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../theme/app_theme.dart';
import 'auth_components.dart';

enum _UserAuthMode { login, register, forgot }

/// Dedicated Login & Register Dashboard for App 1: CIJ Driving (`cij-driving.vercel.app`)
/// Visual Identity: Bright Radiant CIJ Red–Yellow Soft-UI tailored for Consumer / Siswa.
class UserAuthScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onAuthenticated;

  const UserAuthScreen({
    super.key,
    required this.appState,
    required this.onAuthenticated,
  });

  @override
  State<UserAuthScreen> createState() => _UserAuthScreenState();
}

class _UserAuthScreenState extends State<UserAuthScreen> {
  _UserAuthMode _mode = _UserAuthMode.login;
  bool _obscurePassword = true;
  bool _loading = false;
  bool _resetSent = false;
  String? _error;
  String _selectedTransmission = 'Manual (MT)';
  String _selectedArea = 'Purwokerto Utara';
  BiometricBinding? _enrolledBiometric;

  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _resetCtrl = TextEditingController();

  static const Color _cijRed = Color(0xFFDC2626);
  static const Color _cijRedBright = Color(0xFFEF4444);
  static const Color _cijGold = Color(0xFFF59E0B);
  static const Color _cijYellow = Color(0xFFFACC15);
  static const Color _warmBorder = Color(0xFFE5C9B0);

  static const List<String> _transmissions = ['Manual (MT)', 'Matic (AT)', 'Keduanya'];
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
    _resetCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.signIn(
      identifier: _idCtrl.text,
      password: _passCtrl.text,
      flavor: AppFlavor.user,
    );
    if (!mounted) return;

    if (!result.success || result.account == null) {
      setState(() {
        _loading = false;
        _error = result.message;
      });
      return;
    }

    final acc = result.account!;
    widget.appState.login(
      name: acc.fullName,
      email: acc.email,
      username: acc.username,
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
    if (!AuthService.isRoleAllowedForFlavor(b.role, AppFlavor.user)) {
      setState(() {
        _loading = false;
        _error = AuthService.wrongAppMessage(b.role, AppFlavor.user);
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
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.register(
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _idCtrl.text,
      password: _passCtrl.text,
      role: UserRole.siswa,
      allowAdminCreation: false,
    );
    if (!mounted) return;

    if (!result.success || result.account == null) {
      setState(() {
        _loading = false;
        _error = result.message;
      });
      return;
    }

    final acc = result.account!;
    widget.appState.setStudentLocation(_selectedArea);
    widget.appState.login(
      name: acc.fullName,
      email: acc.email,
      username: acc.username,
      role: UserRole.siswa,
    );
    setState(() => _loading = false);
    widget.onAuthenticated();
  }

  Future<void> _handleForgot() async {
    final target = _resetCtrl.text.trim();
    if (target.isEmpty) {
      setState(() => _error = 'Masukkan email atau nomor WhatsApp terdaftar.');
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
                    colors: [_cijYellow.withValues(alpha: 0.36), Colors.transparent],
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
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 18),
                          BoxShadow(color: _cijRed.withValues(alpha: 0.11), offset: const Offset(0, 14), blurRadius: 34),
                          BoxShadow(color: _cijGold.withValues(alpha: 0.16), offset: const Offset(8, 10), blurRadius: 24),
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
                              gradient: const LinearGradient(colors: [_cijRed, _cijGold, _cijYellow]),
                            ),
                          ),
                          AuthComponents.logoBanner(width: 224, height: 138, fallbackColor: _cijRed),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _cijRed.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _cijGold.withValues(alpha: 0.55)),
                            ),
                            child: const Text(
                              'CIJ DRIVING • APLIKASI KONSUMEN / SISWA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _cijRed,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_mode != _UserAuthMode.forgot) ...[
                            AuthComponents.modeSwitcher(
                              isLogin: _mode == _UserAuthMode.login,
                              loginLabel: 'Masuk Siswa',
                              registerLabel: 'Daftar Siswa',
                              activeGradient: const [_cijRed, _cijGold],
                              activeShadow: _cijRed,
                              trackBg: const Color(0xFFFFF8EE),
                              trackBorder: _warmBorder,
                              onSelectLogin: (login) => setState(() {
                                _error = null;
                                _mode = login ? _UserAuthMode.login : _UserAuthMode.register;
                              }),
                            ),
                            const SizedBox(height: 18),
                          ],

                          if (_error != null) AuthComponents.errorBanner(_error!),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            child: KeyedSubtree(
                              key: ValueKey('${_mode.name}-$_resetSent'),
                              child: _mode == _UserAuthMode.login
                                  ? _buildLoginForm()
                                  : _mode == _UserAuthMode.register
                                      ? _buildRegisterForm()
                                      : _buildForgotForm(),
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
        AuthService.isRoleAllowedForFlavor(_enrolledBiometric!.role, AppFlavor.user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            AuthComponents.featureChip(Icons.radar_rounded, 'GPS Radar Instruktur', _cijRed),
            AuthComponents.featureChip(Icons.verified_user_rounded, 'Rem Ganda Aman', _cijGold),
            AuthComponents.featureChip(Icons.badge_rounded, 'Pendampingan SIM A', AppColors.primary),
          ],
        ),
        const SizedBox(height: 18),

        AuthComponents.fieldLabel('Nomor HP, email atau username'),
        const SizedBox(height: 7),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'siswa / siswa@lpk-cij.id',
          accentColor: _cijRed,
          borderTint: _warmBorder,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        AuthComponents.fieldLabel('Kata Sandi'),
        const SizedBox(height: 7),
        AuthComponents.softInput(
          controller: _passCtrl,
          hint: '••••••••••••',
          accentColor: _cijRed,
          borderTint: _warmBorder,
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
          label: _loading ? 'Memverifikasi...' : 'Masuk ke CIJ Driving',
          gradientColors: const [_cijRed, _cijRedBright, _cijGold],
          shadowColor: _cijRed,
          icon: Icons.directions_car_rounded,
          onTap: _loading ? null : _handleLogin,
        ),
        const SizedBox(height: 14),

        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _resetSent = false;
              _mode = _UserAuthMode.forgot;
            }),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Lupa detail login? ',
                style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5),
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
        const SizedBox(height: 18),

        AuthComponents.biometricButton(
          bioActive: bioActive,
          activeName: _enrolledBiometric?.fullName ?? '',
          primaryColor: _cijRed,
          ringColor: _cijGold,
          onTap: _loading ? null : _handleBiometric,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthComponents.fieldLabel('Nama Lengkap Siswa'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _nameCtrl,
          hint: 'Contoh: Dimas Aditya',
          accentColor: _cijRed,
          borderTint: _warmBorder,
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Nomor WhatsApp'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _phoneCtrl,
          hint: '0812-xxxx-xxxx',
          accentColor: _cijRed,
          borderTint: _warmBorder,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Email'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _idCtrl,
          hint: 'nama@email.com',
          accentColor: _cijRed,
          borderTint: _warmBorder,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Pilihan Transmisi Belajar'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _transmissions.map((t) {
            final active = _selectedTransmission == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedTransmission = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: active ? const LinearGradient(colors: [_cijRed, _cijGold]) : null,
                  color: active ? null : const Color(0xFFFFFBF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: active ? Colors.transparent : _warmBorder.withValues(alpha: 0.7)),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: active ? Colors.white : AuthComponents.textMain,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 11),

        AuthComponents.fieldLabel('Area Jemput Latihan'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _warmBorder.withValues(alpha: 0.6), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedArea,
              isExpanded: true,
              icon: const Icon(Icons.location_on_outlined, color: _cijRed, size: 19),
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
          accentColor: _cijRed,
          borderTint: _warmBorder,
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
          label: _loading ? 'Mendaftarkan...' : 'Daftar Akun Siswa',
          gradientColors: const [_cijRed, _cijRedBright, _cijGold],
          shadowColor: _cijRed,
          icon: Icons.person_add_alt_1_rounded,
          onTap: _loading ? null : _handleRegister,
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
            'Tautan Reset Terkirim!',
            style: TextStyle(color: AuthComponents.textMain, fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Instruksi pemulihan kata sandi siswa telah dikirim ke ${_resetCtrl.text.trim()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuthComponents.textMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          AuthComponents.gradientButton(
            label: 'Kembali ke Masuk Siswa',
            gradientColors: const [_cijRed, _cijGold],
            shadowColor: _cijRed,
            onTap: () => setState(() {
              _resetSent = false;
              _mode = _UserAuthMode.login;
            }),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pemulihan Kata Sandi Siswa',
          style: TextStyle(color: AuthComponents.textMain, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Masukkan email atau WhatsApp terdaftar untuk menerima tautan reset kata sandi.',
          style: TextStyle(color: AuthComponents.textMuted, fontSize: 11.5, height: 1.4),
        ),
        const SizedBox(height: 14),
        AuthComponents.fieldLabel('Email / Nomor WhatsApp'),
        const SizedBox(height: 6),
        AuthComponents.softInput(
          controller: _resetCtrl,
          hint: 'siswa@lpk-cij.id atau 0812-xxxx',
          accentColor: _cijRed,
          borderTint: _warmBorder,
          prefixIcon: Icons.mark_email_unread_outlined,
        ),
        const SizedBox(height: 18),
        AuthComponents.gradientButton(
          label: _loading ? 'Mengirim...' : 'Kirim Tautan Reset',
          gradientColors: const [_cijRed, _cijGold],
          shadowColor: _cijRed,
          onTap: _loading ? null : _handleForgot,
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _error = null;
              _mode = _UserAuthMode.login;
            }),
            child: const Text(
              '← Kembali ke Masuk Siswa',
              style: TextStyle(color: _cijRed, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
