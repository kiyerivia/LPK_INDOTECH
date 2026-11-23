import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_navbar.dart';
import '../screens/auth/auth_dashboard_screen.dart';
import '../screens/master/master_overview_screen.dart';
import '../screens/master/master_lpk_screen.dart';
import '../screens/admin/admin_overview_screen.dart';
import '../screens/admin/admin_mitra_screen.dart';
import '../screens/admin/admin_siswa_screen.dart';
import '../screens/admin/admin_config_screen.dart';

/// App 3: CIJ Command Center — Web/Desktop Console for:
///   1. INDOTECH (Master) -> Verifies LPK branches, global fees, Super Admin LPK accounts
///   2. LPK (Super Admin) -> Manages its LPK operations, Mitra KYC, Certificates & Omzet
class ConsoleApp extends StatelessWidget {
  final AppState? sharedState;
  final VoidCallback? onBackToPortal;

  const ConsoleApp({super.key, this.sharedState, this.onBackToPortal});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIJ Command Center — INDOTECH Master & LPK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ConsoleAppShell(sharedState: sharedState, onBackToPortal: onBackToPortal),
    );
  }
}

class ConsoleAppShell extends StatefulWidget {
  final AppState? sharedState;
  final VoidCallback? onBackToPortal;

  const ConsoleAppShell({super.key, this.sharedState, this.onBackToPortal});

  @override
  State<ConsoleAppShell> createState() => _ConsoleAppShellState();
}

class _ConsoleAppShellState extends State<ConsoleAppShell> {
  late final AppState _appState;
  late final bool _ownsState;
  int _tab = 0;
  bool _masterViewingLpkMode = false;

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

  void _logout() {
    _appState.logout();
    setState(() {
      _tab = 0;
      _masterViewingLpkMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loggedInAsConsole = _appState.isLoggedIn && _appState.currentRole == UserRole.admin;
    if (!loggedInAsConsole) {
      return AuthDashboardScreen(
        appState: _appState,
        flavor: AppFlavor.console,
        onAuthenticated: () => setState(() {
          _tab = 0;
          _masterViewingLpkMode = false;
        }),
        onBackToPortal: widget.onBackToPortal,
      );
    }

    final showMasterTabs = _appState.isMaster && !_masterViewingLpkMode;
    final pendingLpks = _appState.lpkBranches.where((b) => b.status == 'pending').length;
    final pendingKyc = _appState.pendingMitras.where((m) => m.status == 'pending').length;

    final tabs = showMasterTabs
        ? [
            const NavTabItem(label: 'Nasional', icon: Icons.public_rounded),
            NavTabItem(label: 'Verif LPK', icon: Icons.domain_verification_rounded, badgeCount: pendingLpks),
            NavTabItem(label: 'Audit', icon: Icons.how_to_reg_rounded, badgeCount: pendingKyc),
            const NavTabItem(label: 'Master', icon: Icons.workspace_premium_rounded),
          ]
        : [
            const NavTabItem(label: 'Omzet', icon: Icons.analytics_rounded),
            NavTabItem(label: 'Mitra', icon: Icons.how_to_reg_rounded, badgeCount: pendingKyc),
            const NavTabItem(label: 'Siswa', icon: Icons.school_rounded),
            const NavTabItem(label: 'Atur', icon: Icons.tune_rounded),
          ];

    Widget screen;
    if (showMasterTabs) {
      switch (_tab) {
        case 0:
          screen = MasterOverviewScreen(
            appState: _appState,
            onOpenLpkVerification: () => setState(() => _tab = 1),
          );
          break;
        case 1:
          screen = MasterLpkScreen(appState: _appState);
          break;
        case 2:
          screen = AdminMitraScreen(appState: _appState);
          break;
        default:
          screen = AdminConfigScreen(appState: _appState);
      }
    } else {
      switch (_tab) {
        case 0:
          screen = AdminOverviewScreen(appState: _appState);
          break;
        case 1:
          screen = AdminMitraScreen(appState: _appState);
          break;
        case 2:
          screen = AdminSiswaScreen(appState: _appState);
          break;
        default:
          screen = AdminConfigScreen(appState: _appState);
      }
    }

    final accent = showMasterTabs ? const Color(0xFFDC2626) : AppColors.purple;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F7FE), Color(0xFFF0F2FC), Color(0xFFFFFBF4)],
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
                    colors: [accent.withValues(alpha: 0.14), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(accent, showMasterTabs),
                  if (_appState.isMaster) _buildMasterLevelToggle(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey('${showMasterTabs ? "master" : "lpk"}-$_tab'),
                        child: screen,
                      ),
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
                accentColor: accent,
                onTabSelected: (i) => setState(() => _tab = i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accent, bool showMasterTabs) {
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
              border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.2),
            ),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(Icons.admin_panel_settings_rounded, color: accent, size: 21),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: showMasterTabs ? 'MASTER ' : 'LPK ',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 15),
                    children: [
                      TextSpan(
                        text: showMasterTabs ? 'INDOTECH' : 'SUPER ADMIN',
                        style: TextStyle(color: accent),
                      ),
                    ],
                  ),
                ),
                Text(
                  showMasterTabs
                      ? 'Otoritas Verifikasi LPK & Holding Nasional'
                      : 'Pusat Operasional LPK Citra Indotech Jaya',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _appState.isMaster ? Icons.workspace_premium_rounded : Icons.admin_panel_settings_rounded,
                    size: 14,
                    color: _appState.isMaster ? AppColors.amber : AppColors.purple,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _appState.isMaster ? 'MASTER' : 'LPK Admin',
                    style: TextStyle(
                      color: _appState.isMaster ? AppColors.amber : AppColors.textPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.logout_rounded, size: 14, color: AppColors.danger),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Exclusive to MASTER INDOTECH: switch between National Master View and Branch LPK Super Admin View
  Widget _buildMasterLevelToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _masterViewingLpkMode = false;
                _tab = 0;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: !_masterViewingLpkMode
                      ? const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFF59E0B)])
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 14, color: !_masterViewingLpkMode ? Colors.white : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '1. INDOTECH Master',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: !_masterViewingLpkMode ? Colors.white : AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _masterViewingLpkMode = true;
                _tab = 0;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: _masterViewingLpkMode
                      ? const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)])
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, size: 14, color: _masterViewingLpkMode ? Colors.white : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '2. LPK Super Admin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _masterViewingLpkMode ? Colors.white : AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
