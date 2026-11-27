import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Holding / National Overview exclusively for 1. INDOTECH (Master)
class MasterOverviewScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onOpenLpkVerification;

  const MasterOverviewScreen({
    super.key,
    required this.appState,
    required this.onOpenLpkVerification,
  });

  @override
  Widget build(BuildContext context) {
    final totalOmzet = appState.totalNationalOmzet;
    final platformFee = (totalOmzet * appState.platformSplitPercent / 100).round();
    final verifiedLpks = appState.lpkBranches.where((b) => b.status == 'verified').length;
    final pendingLpks = appState.lpkBranches.where((b) => b.status == 'pending').length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matte Deep Crimson Master Banner (Solid Doff, No Gradient)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.matteBanner(color: AppColors.primaryDark, radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('MASTER INDOTECH HQ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$verifiedLpks LPK Aktif',
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Total Omzet Nasional', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatRupiah(totalOmzet), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  'Fee platform INDOTECH (${appState.platformSplitPercent}%): ${formatRupiah(platformFee)} / bulan',
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _kpi('LPK Terverifikasi', '$verifiedLpks LPK', '$pendingLpks menunggu verif', AppColors.amber),
              const SizedBox(width: 10),
              _kpi('Total Mitra Driver', '${appState.totalNationalDrivers} Driver', 'Lintas cabang LPK', AppColors.emerald),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kpi('Total Konsumen', '${appState.totalNationalStudents} Siswa', 'Aktif pelatihan', AppColors.primary),
              const SizedBox(width: 10),
              _kpi('Global Fee Master', '${appState.platformSplitPercent}%', 'Auto-split platform', AppColors.purple),
            ],
          ),

          if (pendingLpks > 0) ...[
            const SizedBox(height: 14),
            GlassCard(
              highlight: true,
              highlightColor: AppColors.amber,
              padding: const EdgeInsets.all(15),
              onTap: onOpenLpkVerification,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.verified_outlined, color: AppColors.amber, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$pendingLpks Pengajuan LPK Menunggu Verifikasi Master',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Ketuk untuk memeriksa izin Kemnaker & mengaktifkan cabang LPK.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.amber, size: 15),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text('Performa LPK di Bawah Naungan INDOTECH', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          ...appState.lpkBranches.map((lpk) {
            final isVerified = lpk.status == 'verified';
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AvatarInitial(
                    initial: lpk.name.trim().isNotEmpty ? lpk.name.trim()[0].toUpperCase() : 'L',
                    size: 42,
                    online: isVerified,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lpk.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('${lpk.city} - ${lpk.activeDrivers} Mitra, ${lpk.activeStudents} Siswa', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 3),
                        Text('Omzet: ${formatRupiah(lpk.monthlyOmzet)}', style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 11)),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: isVerified ? 'Terverifikasi' : lpk.status == 'pending' ? 'Pending' : 'Ditangguhkan',
                    color: isVerified ? AppColors.emerald : lpk.status == 'pending' ? AppColors.amber : AppColors.danger,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _kpi(String title, String val, String sub, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
