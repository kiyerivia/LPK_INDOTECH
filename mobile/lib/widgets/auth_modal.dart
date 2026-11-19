import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class AuthModal extends StatefulWidget {
  final AppState appState;

  const AuthModal({super.key, required this.appState});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _obscurePass = true;
  UserRole _selectedRole = UserRole.siswa;
  bool _loading = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedRole = widget.appState.currentRole;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _namaCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit({bool demo = false}) async {
    setState(() => _loading = true);

    final email = _emailCtrl.text.trim().isNotEmpty
        ? _emailCtrl.text.trim()
        : '${_selectedRole.name}@lpk-indotech.id';
    final name = _namaCtrl.text.trim().isNotEmpty
        ? _namaCtrl.text.trim()
        : _selectedRole == UserRole.mitra
            ? 'Bambang Sugiantoro'
            : _selectedRole == UserRole.admin
                ? 'Admin LPK HQ'
                : 'Dimas Aditya';

    if (!demo && _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.length >= 6) {
      try {
        final client = Supabase.instance.client;
        if (_tabController.index == 0) {
          await client.auth.signInWithPassword(email: email, password: _passCtrl.text);
        } else {
          await client.auth.signUp(
            email: email,
            password: _passCtrl.text,
            data: {'full_name': name, 'role': _selectedRole.name, 'phone': _teleponCtrl.text},
          );
        }
      } catch (_) {}
    } else {
      await Future.delayed(const Duration(milliseconds: 350));
    }

    widget.appState.login(name: name, email: email, role: _selectedRole);

    if (mounted) {
      setState(() => _loading = false);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LPK Driving Partner',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Supabase Auth • Mode Demo Aktif',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            const Text(
              'Masuk sebagai:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _roleChip(UserRole.siswa, 'Siswa', Icons.school_rounded, AppColors.primary),
                const SizedBox(width: 8),
                _roleChip(UserRole.mitra, 'Mitra Driver', Icons.local_taxi_rounded, AppColors.emerald),
                const SizedBox(width: 8),
                _roleChip(UserRole.admin, 'Admin LPK', Icons.admin_panel_settings_rounded, AppColors.purple),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [Tab(text: 'Masuk'), Tab(text: 'Daftar Baru')],
              ),
            ),
            const SizedBox(height: 16),

            if (_tabController.index == 1) ...[
              TextField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _teleponCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. WhatsApp Aktif',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
            ],

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),

            const SizedBox(height: 18),
            NeonButton(
              label: _loading
                  ? 'Memproses...'
                  : _tabController.index == 0
                      ? 'Masuk Akun'
                      : 'Daftar Sekarang',
              onPressed: _loading ? null : () => _submit(),
              width: double.infinity,
              icon: _tabController.index == 0 ? Icons.login_rounded : Icons.person_add_rounded,
            ),
            const SizedBox(height: 10),
            NeonButton(
              label: 'Masuk Cepat (Mode Demo ${_selectedRole.name.toUpperCase()})',
              onPressed: _loading ? null : () => _submit(demo: true),
              width: double.infinity,
              outlined: true,
              icon: Icons.bolt_rounded,
              color: AppColors.emerald,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(UserRole role, String label, IconData icon, Color color) {
    final selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 17, color: selected ? color : AppColors.textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? color : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
