import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_navbar.dart';
import '../widgets/booking_sheet.dart';
import '../screens/auth/user_auth_screen.dart';
import '../screens/siswa/siswa_home_screen.dart';
import '../screens/siswa/siswa_search_screen.dart';
import '../screens/siswa/siswa_schedule_screen.dart';
import '../screens/siswa/siswa_report_screen.dart';
import '../screens/siswa/siswa_profile_screen.dart';

/// App 1: CIJ Driving — Aplikasi Konsumen / Siswa (ala Gojek Pengguna)
/// Strictly isolated to Consumer / Siswa accounts & features.
class UserApp extends StatelessWidget {
  final AppState? sharedState;
  final VoidCallback? onBackToPortal;

  const UserApp({super.key, this.sharedState, this.onBackToPortal});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIJ Driving — Aplikasi Konsumen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: UserAppShell(sharedState: sharedState, onBackToPortal: onBackToPortal),
    );
  }
}

class UserAppShell extends StatefulWidget {
  final AppState? sharedState;
  final VoidCallback? onBackToPortal;

  const UserAppShell({super.key, this.sharedState, this.onBackToPortal});

  @override
  State<UserAppShell> createState() => _UserAppShellState();
}

class _UserAppShellState extends State<UserAppShell> {
  late final AppState _appState;
  late final bool _ownsState;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _ownsState = widget.sharedState == null;
    _appState = widget.sharedState ?? AppState();
    _appState.addListener(_onChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onChanged);
    if (_ownsState) _appState.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
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
      setState(() => _tab = 2);
    }
  }

  void _logout() {
    _appState.logout();
    setState(() => _tab = 0);
  }

  @override
  Widget build(BuildContext context) {
    final loggedInAsUser = _appState.isLoggedIn && _appState.currentRole == UserRole.siswa;
    if (!loggedInAsUser) {
      return UserAuthScreen(
        appState: _appState,
        onAuthenticated: () => setState(() => _tab = 0),
      );
    }

    const tabs = [
      NavTabItem(label: 'Beranda', icon: Icons.home_rounded),
      NavTabItem(label: 'Cari', icon: Icons.radar_rounded),
      NavTabItem(label: 'Jadwal', icon: Icons.calendar_month_rounded),
      NavTabItem(label: 'Rapor', icon: Icons.workspace_premium_rounded),
      NavTabItem(label: 'Profil', icon: Icons.person_rounded),
    ];

    Widget screen;
    switch (_tab) {
      case 0:
        screen = SiswaHomeScreen(
          appState: _appState,
          onOpenSearch: () => setState(() => _tab = 1),
          onOpenSchedule: () => setState(() => _tab = 2),
          onOpenReport: () => setState(() => _tab = 3),
          onBook: _openBooking,
        );
        break;
      case 1:
        screen = SiswaSearchScreen(appState: _appState, onBook: (inst) => _openBooking(inst));
        break;
      case 2:
        screen = SiswaScheduleScreen(appState: _appState, onBookMore: () => setState(() => _tab = 1));
        break;
      case 3:
        screen = SiswaReportScreen(appState: _appState);
        break;
      default:
        screen = SiswaProfileScreen(appState: _appState, onOpenAuth: _logout);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(key: ValueKey('user-$_tab'), child: screen),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NeonArchNavbar(
              tabs: tabs,
              currentIndex: _tab,
              accentColor: AppColors.primary,
              onTabSelected: (i) => setState(() => _tab = i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F1D1A).withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIJ Driving',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                Text(
                  'Kursus Mengemudi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
