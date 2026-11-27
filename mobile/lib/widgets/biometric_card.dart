import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/biometric_service.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Reusable Biometric Security Card for enrolling or revoking hardware fingerprint/passkey login
class BiometricSecurityCard extends StatefulWidget {
  final AppState appState;

  const BiometricSecurityCard({super.key, required this.appState});

  @override
  State<BiometricSecurityCard> createState() => _BiometricSecurityCardState();
}

class _BiometricSecurityCardState extends State<BiometricSecurityCard> {
  BiometricBinding? _binding;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final b = await BiometricService.getEnrolledBinding();
    if (mounted) setState(() => _binding = b);
  }

  bool get _isBoundToCurrentUser =>
      _binding != null && _binding!.email.toLowerCase() == widget.appState.userEmail.toLowerCase();

  Future<void> _toggle(bool enable) async {
    setState(() => _busy = true);
    if (enable) {
      final res = await BiometricService.enrollForUser(
        username: widget.appState.currentUsername,
        email: widget.appState.userEmail,
        fullName: widget.appState.userName,
        role: widget.appState.currentRole,
        isSuperAdmin: widget.appState.isSuperAdmin,
        isMaster: widget.appState.isMaster,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: res.success ? AppColors.emerald : AppColors.danger,
          ),
        );
      }
    } else {
      await BiometricService.revokeBiometric();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login sidik jari telah dinonaktifkan pada perangkat ini.'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    }
    await _refresh();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final active = _isBoundToCurrentUser;

    return GlassCard(
      highlight: active,
      highlightColor: AppColors.emerald,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (active ? AppColors.emerald : AppColors.primary).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: active ? AppColors.emerald : AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login Sidik Jari',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? 'Aktif untuk ${widget.appState.userName}'
                      : 'Aktifkan sidik jari untuk masuk lebih cepat',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: active,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.emerald,
            onChanged: _busy ? null : _toggle,
          ),
        ],
      ),
    );
  }
}
