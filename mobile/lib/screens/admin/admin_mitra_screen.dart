import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminMitraScreen extends StatelessWidget {
  final AppState appState;

  const AdminMitraScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verifikasi Mitra Baru (KYC & Uji Rem Ganda)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Setujui calon driver mitra agar otomatis masuk ke radar pencarian instruktur terdekat siswa.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),

          if (appState.pendingMitras.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'Belum ada pengajuan KYC mitra driver baru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            ...appState.pendingMitras.map((m) {
            final approved = m.status == 'approved';
            return GlassCard(
              highlight: !approved,
              highlightColor: AppColors.amber,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${m.id} • ${m.area}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                            Text(m.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                            Text(m.driverBackground, style: const TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: approved ? 'AKTIF DI RADAR' : 'PERLU VERIFIKASI',
                        color: approved ? AppColors.emerald : AppColors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InfoRow(icon: Icons.badge_rounded, label: 'Lisensi SIM', value: m.simType),
                  InfoRow(icon: Icons.directions_car_rounded, label: 'Kendaraan', value: m.carInfo),
                  const InfoRow(icon: Icons.verified_user_rounded, label: 'Rem Ganda & KTP', value: 'Lulus Uji Safety LPK', valueColor: AppColors.emerald),
                  const SizedBox(height: 12),
                  if (!approved)
                    NeonButton(
                      label: 'Setujui & Aktifkan ke Radar Siswa',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.emerald,
                      width: double.infinity,
                      onPressed: () {
                        appState.approveMitra(m.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${m.name} resmi diverifikasi & masuk ke Radar Siswa!'),
                            backgroundColor: AppColors.emerald,
                          ),
                        );
                      },
                    )
                  else
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Mitra sudah aktif dan tampil di pencarian siswa Purwokerto.',
                            style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),
          Text('Mitra Driver Aktif (${appState.instructors.length})', style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (appState.instructors.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'Belum ada mitra driver aktif di radar. Setujui pengajuan KYC mitra untuk mengaktifkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            ...appState.instructors.map((inst) => GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    AvatarInitial(initial: inst.initial, size: 42, online: inst.isOnline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inst.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${inst.carModel} - ${inst.area} (${inst.rating})', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    const StatusPill(label: 'Rem Ganda', color: AppColors.emerald),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
