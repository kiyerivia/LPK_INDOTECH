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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F9FF), Color(0xFFEDF4FD), Color(0xFFF3F6FC)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.primary.withValues(alpha: 0.16), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.28), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 21),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'CIJ ',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 15),
                    children: [
                      TextSpan(text: 'DRIVING', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
                const Text(
                  'Aplikasi Konsumen • Kursus Mengemudi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    _appState.userName.split(' ').first,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.logout_rounded, size: 14, color: AppColors.danger),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
