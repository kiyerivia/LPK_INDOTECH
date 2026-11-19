import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.userName, required this.userRole, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AvatarInitial(initial: userName.isNotEmpty ? userName[0] : 'U', size: 72),
                const SizedBox(height: 12),
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 20)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(userRole == 'mitra' ? '🚗 Instruktur Mitra' : '📚 Siswa', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('3', 'Sesi Selesai', AppTheme.success),
                    _statItem('87', 'Nilai Rata-Rata', AppTheme.info),
                    _statItem('0', 'Sertifikat', AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu items
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _menuItem(Icons.person_outline, 'Edit Profil', () {}),
                _divider(),
                _menuItem(Icons.location_on_outlined, 'Alamat Tersimpan', () {}),
                _divider(),
                _menuItem(Icons.payment_outlined, 'Riwayat Pembayaran', () {}),
                _divider(),
                _menuItem(Icons.notifications_outlined, 'Notifikasi', () {}),
                _divider(),
                _menuItem(Icons.help_outline, 'Bantuan & FAQ', () {}),
                _divider(),
                _menuItem(Icons.info_outline, 'Tentang LPK INDOTECH', () {}),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Logout
          GlassCard(
            padding: EdgeInsets.zero,
            child: _menuItem(Icons.logout, 'Keluar', onLogout, color: AppTheme.primary),
          ),

          const SizedBox(height: 20),
          const Text('LPK INDOTECH Driving Partner v1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback? onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppTheme.textSecondary, size: 20),
      title: Text(label, style: TextStyle(color: color ?? AppTheme.textPrimary, fontSize: 14)),
      trailing: Icon(Icons.chevron_right, color: color ?? AppTheme.textSecondary, size: 18),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.white.withOpacity(0.07), indent: 52);
}
