import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class SiswaProfileScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onOpenAuth;

  const SiswaProfileScreen({
    super.key,
    required this.appState,
    required this.onOpenAuth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AvatarInitial(
                  initial: appState.userName.isNotEmpty ? appState.userName[0].toUpperCase() : 'S',
                  size: 68,
                  online: true,
                ),
                const SizedBox(height: 12),
                Text(
                  appState.userName,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(appState.userEmail, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 10),
                StatusPill(
                  label: appState.isLoggedIn ? 'Akun Terhubung Supabase' : 'Mode Demo Siswa',
                  color: appState.isLoggedIn ? AppColors.emerald : AppColors.primary,
                  icon: Icons.verified_user_rounded,
                ),
                if (!appState.isLoggedIn) ...[
                  const SizedBox(height: 14),
                  NeonButton(
                    label: 'Login / Daftar Akun Supabase',
                    icon: Icons.login_rounded,
                    width: double.infinity,
                    onPressed: onOpenAuth,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          GlassCard(
            highlight: true,
            highlightColor: AppColors.emerald,
            padding: const EdgeInsets.all(16),
            onTap: () => appState.setRole(UserRole.mitra),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.local_taxi_rounded, color: AppColors.emerald),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Punya Mobil & Pengalaman Driver Online?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Gabung jadi Mitra Instruktur LPK — Bagi hasil 60% otomatis!', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.emerald, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 14),

          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tile(Icons.location_on_outlined, 'Alamat Penjemputan Utama', appState.studentLocation, () {}),
                _divider(),
                _tile(Icons.receipt_long_outlined, 'Riwayat Pembayaran', '${appState.orders.length} transaksi tercatat', () {}),
                _divider(),
                _tile(Icons.shield_outlined, 'Standar Keamanan Rem Ganda', 'Semua mobil mitra wajib lulus uji LPK', () {}),
                _divider(),
                _tile(Icons.help_outline_rounded, 'Bantuan Admin LPK Purwokerto', 'WhatsApp CS 08:00 - 20:00 WIB', () {}),
              ],
            ),
          ),

          if (appState.isLoggedIn) ...[
            const SizedBox(height: 14),
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                title: const Text('Keluar Akun', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 14)),
                onTap: appState.logout,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 21),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 54);
}
