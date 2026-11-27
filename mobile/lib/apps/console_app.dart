import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_navbar.dart';
import '../screens/auth/console_auth_screen.dart';
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
      return ConsoleAuthScreen(
        appState: _appState,
        onAuthenticated: () => setState(() {
          _tab = 0;
          _masterViewingLpkMode = false;
        }),
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

    final accent = showMasterTabs ? AppColors.primary : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(accent, showMasterTabs),
                if (_appState.isMaster) _buildMasterLevelToggle(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
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
    );
  }

  Widget _buildHeader(Color accent, bool showMasterTabs) {
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
              errorBuilder: (_, _, _) => Icon(Icons.admin_panel_settings_rounded, color: accent, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showMasterTabs ? 'CIJ Master' : 'LPK Admin',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                Text(
                  showMasterTabs
                      ? 'Indotech Pusat'
                      : 'LPK Citra Indotech Jaya',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F1D1A).withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _appState.isMaster ? 'Master' : 'Admin LPK',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.logout_rounded, size: 15, color: AppColors.danger),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterLevelToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
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
                  color: !_masterViewingLpkMode ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: !_masterViewingLpkMode
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'INDOTECH Master',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: !_masterViewingLpkMode ? Colors.white : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
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
                  color: _masterViewingLpkMode ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _masterViewingLpkMode
                      ? [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Admin LPK',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _masterViewingLpkMode ? Colors.white : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
