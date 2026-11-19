import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/app_models.dart';
import 'theme/app_theme.dart';
import 'widgets/neon_navbar.dart';
import 'widgets/auth_modal.dart';
import 'widgets/booking_sheet.dart';
import 'screens/siswa/siswa_home_screen.dart';
import 'screens/siswa/siswa_search_screen.dart';
import 'screens/siswa/siswa_schedule_screen.dart';
import 'screens/siswa/siswa_report_screen.dart';
import 'screens/siswa/siswa_profile_screen.dart';
import 'screens/mitra/mitra_order_screen.dart';
import 'screens/mitra/mitra_eval_screen.dart';
import 'screens/mitra/mitra_wallet_screen.dart';
import 'screens/mitra/mitra_profile_screen.dart';
import 'screens/admin/admin_overview_screen.dart';
import 'screens/admin/admin_mitra_screen.dart';
import 'screens/admin/admin_siswa_screen.dart';
import 'screens/admin/admin_config_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Connect to Supabase (graceful fallback to Demo Mode if offline)
  try {
    await Supabase.initialize(
      url: 'https://cmtvzjcjinivkquhheqo.supabase.co',
      publishableKey: 'sb_publishable_xCwyI9klXX30unaDht3TPw_KidrW5o2',
    );
  } catch (e) {
    debugPrint('Supabase init notice: $e');
  }

  runApp(const LPKIndotechApp());
}

class LPKIndotechApp extends StatelessWidget {
  const LPKIndotechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LPK INDOTECH — Driving Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DrivingPartnerShell(),
    );
  }
}

class DrivingPartnerShell extends StatefulWidget {
  const DrivingPartnerShell({super.key});

  @override
  State<DrivingPartnerShell> createState() => _DrivingPartnerShellState();
}

class _DrivingPartnerShellState extends State<DrivingPartnerShell> {
  final AppState _appState = AppState();
  int _siswaTab = 0;
  int _mitraTab = 0;
  int _adminTab = 0;

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _appState.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _openAuth() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuthModal(appState: _appState),
    );
  }

  Future<void> _openBooking(Instructor instructor, [DrivingPackage? pkg]) async {
    final booked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingSheet(
        appState: _appState,
        instructor: instructor,
        initialPackage: pkg,
      ),
    );
    if (booked == true && mounted) {
      setState(() => _siswaTab = 2);
    }
  }

  int get _activeTabIndex {
    switch (_appState.currentRole) {
      case UserRole.siswa:
        return _siswaTab;
      case UserRole.mitra:
        return _mitraTab;
      case UserRole.admin:
        return _adminTab;
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      switch (_appState.currentRole) {
        case UserRole.siswa:
          _siswaTab = index;
          break;
        case UserRole.mitra:
          _mitraTab = index;
          break;
        case UserRole.admin:
          _adminTab = index;
          break;
      }
    });
  }

  Color get _roleAccent {
    switch (_appState.currentRole) {
      case UserRole.siswa:
        return AppColors.primary;
      case UserRole.mitra:
        return AppColors.emerald;
      case UserRole.admin:
        return AppColors.purple;
    }
  }

  List<NavTabItem> get _currentTabs {
    switch (_appState.currentRole) {
      case UserRole.siswa:
        return const [
          NavTabItem(label: 'Beranda', icon: Icons.home_rounded),
          NavTabItem(label: 'Cari', icon: Icons.radar_rounded),
          NavTabItem(label: 'Jadwal', icon: Icons.calendar_month_rounded),
          NavTabItem(label: 'Rapor', icon: Icons.workspace_premium_rounded),
          NavTabItem(label: 'Profil', icon: Icons.person_rounded),
        ];
      case UserRole.mitra:
        final pendingOrders = _appState.orders.where((o) => o.stage == TripStage.pending).length;
        return [
          NavTabItem(label: 'Order', icon: Icons.local_taxi_rounded, badgeCount: pendingOrders),
          const NavTabItem(label: 'Nilai', icon: Icons.fact_check_rounded),
          const NavTabItem(label: 'Dompet', icon: Icons.account_balance_wallet_rounded),
          const NavTabItem(label: 'Mitra', icon: Icons.verified_user_rounded),
        ];
      case UserRole.admin:
        final pendingKyc = _appState.pendingMitras.where((m) => m.status == 'pending').length;
        return [
          const NavTabItem(label: 'Omzet', icon: Icons.analytics_rounded),
          NavTabItem(label: 'Mitra', icon: Icons.how_to_reg_rounded, badgeCount: pendingKyc),
          const NavTabItem(label: 'Siswa', icon: Icons.school_rounded),
          const NavTabItem(label: 'Atur', icon: Icons.tune_rounded),
        ];
    }
  }

  Widget _buildActiveScreen() {
    switch (_appState.currentRole) {
      case UserRole.siswa:
        switch (_siswaTab) {
          case 0:
            return SiswaHomeScreen(
              appState: _appState,
              onOpenSearch: () => setState(() => _siswaTab = 1),
              onOpenSchedule: () => setState(() => _siswaTab = 2),
              onOpenReport: () => setState(() => _siswaTab = 3),
              onBook: _openBooking,
            );
          case 1:
            return SiswaSearchScreen(appState: _appState, onBook: (inst) => _openBooking(inst));
          case 2:
            return SiswaScheduleScreen(
              appState: _appState,
              onBookMore: () => setState(() => _siswaTab = 1),
            );
          case 3:
            return SiswaReportScreen(appState: _appState);
          default:
            return SiswaProfileScreen(appState: _appState, onOpenAuth: _openAuth);
        }

      case UserRole.mitra:
        switch (_mitraTab) {
          case 0:
            return MitraOrderScreen(
              appState: _appState,
              onGoToEval: () => setState(() => _mitraTab = 1),
            );
          case 1:
            return MitraEvalScreen(appState: _appState);
          case 2:
            return MitraWalletScreen(appState: _appState);
          default:
            return MitraProfileScreen(appState: _appState);
        }

      case UserRole.admin:
        switch (_adminTab) {
          case 0:
            return AdminOverviewScreen(appState: _appState);
          case 1:
            return AdminMitraScreen(appState: _appState);
          case 2:
            return AdminSiswaScreen(appState: _appState);
          default:
            return AdminConfigScreen(appState: _appState);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F9FF),
              Color(0xFFEDF4FD),
              Color(0xFFF3F6FC),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Soft Aurora Pastel Futuristic Glows
            Positioned(
              top: -90,
              left: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _roleAccent.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: -90,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.emerald.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Column
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildGlassyHeader(),
                  _buildRoleSwitcherBar(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey('${_appState.currentRole.name}-$_activeTabIndex'),
                        child: _buildActiveScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Frosted Pearl Glass Navbar with Neon Arch (Video V5)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NeonArchNavbar(
                tabs: _currentTabs,
                currentIndex: _activeTabIndex,
                accentColor: _roleAccent,
                onTabSelected: _onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassyHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_roleAccent, Color.lerp(_roleAccent, Colors.cyanAccent, 0.25)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: _roleAccent.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'LPK ',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 15),
                    children: [
                      TextSpan(text: 'DRIVING PARTNER', style: TextStyle(color: _roleAccent)),
                    ],
                  ),
                ),
                const Text(
                  'Kursus Mengemudi & Mitra Online • Purwokerto',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _openAuth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _appState.isLoggedIn ? Icons.verified_user_rounded : Icons.account_circle_rounded,
                    size: 16,
                    color: _appState.isLoggedIn ? AppColors.emerald : _roleAccent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _appState.isLoggedIn ? _appState.userName.split(' ').first : 'Masuk',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSwitcherBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _rolePill(UserRole.siswa, 'Siswa', Icons.school_rounded, AppColors.primary),
          _rolePill(UserRole.mitra, 'Mitra Driver', Icons.local_taxi_rounded, AppColors.emerald),
          _rolePill(UserRole.admin, 'Admin LPK', Icons.admin_panel_settings_rounded, AppColors.purple),
        ],
      ),
    );
  }

  Widget _rolePill(UserRole role, String label, IconData icon, Color color) {
    final active = _appState.currentRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _appState.setRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [color, Color.lerp(color, Colors.cyanAccent, 0.2)!])
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? Colors.white : AppColors.textMuted),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
