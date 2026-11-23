import 'package:flutter/material.dart';
import 'apps/console_app.dart';
import 'apps/mitra_app.dart';
import 'apps/user_app.dart';
import 'models/app_models.dart';
import 'services/bootstrap.dart';
import 'theme/app_theme.dart';

/// Default Entry Point — CIJ Ecosystem Portal Launcher (Opsi A: 3 Separate Apps)
/// Allows launching each standalone app directly from one link for demos, while
/// production builds can target `main_user.dart`, `main_mitra.dart`, or `main_console.dart`.
Future<void> main() async {
  await initCijPlatform();
  runApp(const LPKIndotechApp());
}

class LPKIndotechApp extends StatefulWidget {
  const LPKIndotechApp({super.key});

  @override
  State<LPKIndotechApp> createState() => _LPKIndotechAppState();
}

class _LPKIndotechAppState extends State<LPKIndotechApp> {
  final AppState _sharedState = AppState();
  AppFlavor? _activeApp;

  @override
  void dispose() {
    _sharedState.dispose();
    super.dispose();
  }

  void _openApp(AppFlavor app) {
    _sharedState.logout();
    setState(() => _activeApp = app);
  }

  void _backToPortal() {
    _sharedState.logout();
    setState(() => _activeApp = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeApp == AppFlavor.user) {
      return UserApp(sharedState: _sharedState, onBackToPortal: _backToPortal);
    }
    if (_activeApp == AppFlavor.mitra) {
      return MitraApp(sharedState: _sharedState, onBackToPortal: _backToPortal);
    }
    if (_activeApp == AppFlavor.console) {
      return ConsoleApp(sharedState: _sharedState, onBackToPortal: _backToPortal);
    }

    return MaterialApp(
      title: 'LPK INDOTECH — Ekosistem Driving Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _EcosystemPortalScreen(onSelectApp: _openApp),
    );
  }
}

class _EcosystemPortalScreen extends StatelessWidget {
  final ValueChanged<AppFlavor> onSelectApp;

  const _EcosystemPortalScreen({required this.onSelectApp});

  static const Color _cijRed = Color(0xFFDC2626);
  static const Color _cijGold = Color(0xFFF59E0B);
  static const Color _cijYellow = Color(0xFFFACC15);

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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _cijRed.withValues(alpha: 0.10),
                        offset: const Offset(0, 14),
                        blurRadius: 34,
                      ),
                      BoxShadow(
                        color: _cijGold.withValues(alpha: 0.16),
                        offset: const Offset(8, 10),
                        blurRadius: 24,
                      ),
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
                      Image.asset(
                        'assets/logo.png',
                        width: 220,
                        height: 138,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.directions_car_rounded,
                          size: 64,
                          color: _cijRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pilih Aplikasi Ekosistem Driving Partner',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '3 aplikasi terpisah ala Gojek yang terhubung ke 1 database Supabase',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                      ),
                      const SizedBox(height: 22),

                      _appCard(
                        icon: Icons.directions_car_rounded,
                        color: AppColors.primary,
                        badge: 'APP 1 • KONSUMEN / USER',
                        title: 'CIJ Driving (Siswa)',
                        subtitle: 'Radar GPS cari instruktur terdekat, booking jadwal, tracking sesi, rapor & SIM A',
                        onTap: () => onSelectApp(AppFlavor.user),
                      ),
                      const SizedBox(height: 12),

                      _appCard(
                        icon: Icons.local_taxi_rounded,
                        color: AppColors.emerald,
                        badge: 'APP 2 • MITRA DRIVER',
                        title: 'CIJ Partner (Instruktur)',
                        subtitle: 'ON BID / Offline, terima order masuk, jemput siswa, input nilai & dompet 60%',
                        onTap: () => onSelectApp(AppFlavor.mitra),
                      ),
                      const SizedBox(height: 12),

                      _appCard(
                        icon: Icons.workspace_premium_rounded,
                        color: _cijRed,
                        badge: 'APP 3 • MASTER & SUPER ADMIN',
                        title: 'CIJ Command Center',
                        subtitle: '1. INDOTECH (Master Verifikasi LPK) & 2. LPK (Super Admin Operasional)',
                        onTap: () => onSelectApp(AppFlavor.console),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appCard({
    required IconData icon,
    required Color color,
    required String badge,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.28), width: 1.3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.09),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, Color.lerp(color, Colors.amber, 0.25)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge,
                    style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded, size: 15, color: color),
          ],
        ),
      ),
    );
  }
}
