import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_navbar.dart';
import '../screens/auth/mitra_auth_screen.dart';
import '../screens/mitra/mitra_order_screen.dart';
import '../screens/mitra/mitra_eval_screen.dart';
import '../screens/mitra/mitra_wallet_screen.dart';
import '../screens/mitra/mitra_profile_screen.dart';

/// App 2: CIJ Partner — Aplikasi Mitra Driver / Instruktur (ala GoPartner / Gojek Driver)
/// Strictly isolated to Mitra Driver accounts & field operations.
class MitraApp extends StatelessWidget {
  final AppState? sharedState;
  final VoidCallback? onBackToPortal;

  const MitraApp({super.key, this.sharedState, this.onBackToPortal});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIJ Partner — Aplikasi Mitra Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MitraAppShell(sharedState: sharedState, onBackToPortal: onBackToPortal),
    );
  }
}

class MitraAppShell extends StatefulWidget {
  final AppState? sharedState;
  final VoidCallback? onBackToPortal;

  const MitraAppShell({super.key, this.sharedState, this.onBackToPortal});

  @override
  State<MitraAppShell> createState() => _MitraAppShellState();
}

class _MitraAppShellState extends State<MitraAppShell> {
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

  void _logout() {
    _appState.logout();
    setState(() => _tab = 0);
  }

  @override
  Widget build(BuildContext context) {
    final loggedInAsMitra = _appState.isLoggedIn && _appState.currentRole == UserRole.mitra;
    if (!loggedInAsMitra) {
      return MitraAuthScreen(
        appState: _appState,
        onAuthenticated: () => setState(() => _tab = 0),
      );
    }

    final pendingOrders = _appState.orders.where((o) => o.stage == TripStage.pending).length;
    final tabs = [
      NavTabItem(label: 'Order', icon: Icons.local_taxi_rounded, badgeCount: pendingOrders),
      const NavTabItem(label: 'Nilai', icon: Icons.fact_check_rounded),
      const NavTabItem(label: 'Dompet', icon: Icons.account_balance_wallet_rounded),
      const NavTabItem(label: 'Mitra', icon: Icons.verified_user_rounded),
    ];

    Widget screen;
    switch (_tab) {
      case 0:
        screen = MitraOrderScreen(appState: _appState, onGoToEval: () => setState(() => _tab = 1));
        break;
      case 1:
        screen = MitraEvalScreen(appState: _appState);
        break;
      case 2:
        screen = MitraWalletScreen(appState: _appState);
        break;
      default:
        screen = MitraProfileScreen(appState: _appState);
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
                    child: KeyedSubtree(key: ValueKey('mitra-$_tab'), child: screen),
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
              errorBuilder: (_, _, _) => const Icon(Icons.local_taxi_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIJ Mitra',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
                Text(
                  'Mitra Instruktur',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
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
                    _appState.userName.trim().isNotEmpty ? _appState.userName.trim().split(' ').first : 'Mitra',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w700),
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
}
