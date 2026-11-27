import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminOverviewScreen extends StatelessWidget {
  final AppState appState;

  const AdminOverviewScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final monthlyOmzet = appState.totalBranchOmzet;
    final mitraPayout = (monthlyOmzet * appState.mitraSplitPercent / 100).round();
    final lpkShare = (monthlyOmzet * appState.lpkSplitPercent / 100).round();
    final platformShare = monthlyOmzet - mitraPayout - lpkShare;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matte CIJ Red LPK Overview Banner (Solid Doff, No Gradient)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.matteBanner(color: AppColors.primary, radius: 18),
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
                      child: const Text('Admin LPK', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Total Omzet Bulan Ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(formatRupiah(monthlyOmzet), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text(
                  'LPK Citra Indotech Jaya',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _kpi('Mitra Aktif', '${appState.instructors.length} Driver', 'Rem ganda terverifikasi', AppColors.emerald),
              const SizedBox(width: 10),
              _kpi('Siswa Aktif', '${appState.activeStudentCount} Siswa', '${appState.graduations.where((g) => g.approved).length} lulus sertifikat', AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kpi('Order Aktif', '${appState.orders.length} Order', 'Jadwal berjalan', AppColors.primaryDark),
              const SizedBox(width: 10),
              _kpi('Antrean KYC', '${appState.pendingMitras.where((m) => m.status == 'pending').length} Mitra', 'Menunggu verifikasi', AppColors.amber),
            ],
          ),

          const SizedBox(height: 16),

          const Text('Distribusi Bagi Hasil', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _splitBar(
                  'Mitra Instruktur (${appState.mitraSplitPercent}%)',
                  formatRupiah(mitraPayout),
                  appState.mitraSplitPercent / 100,
                  AppColors.emerald,
                ),
                const SizedBox(height: 12),
                _splitBar(
                  'LPK (${appState.lpkSplitPercent}%)',
                  formatRupiah(lpkShare),
                  appState.lpkSplitPercent / 100,
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _splitBar(
                  'Platform & Asuransi (${appState.platformSplitPercent}%)',
                  formatRupiah(platformShare),
                  appState.platformSplitPercent / 100,
                  AppColors.amber,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('Pantauan Jadwal & Order Live', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (appState.orders.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'Belum ada transaksi atau jadwal order masuk. Order dari CIJ Driving akan muncul real-time di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            ...appState.orders.take(4).map((o) => GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${o.studentName} → ${o.instructorName}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('${o.packageName} • ${o.timeSlot}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    StatusPill(label: o.stage.name.toUpperCase(), color: AppColors.purple),
                  ],
                ),
              )),
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

  Widget _splitBar(String label, String amount, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700))),
            Text(amount, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: AppColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
