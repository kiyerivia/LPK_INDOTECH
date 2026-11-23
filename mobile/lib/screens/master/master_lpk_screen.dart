import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Multi-LPK Verification & Branch Management for 1. INDOTECH (Master)
class MasterLpkScreen extends StatelessWidget {
  final AppState appState;

  const MasterLpkScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verifikasi LPK (Otoritas Master)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('Verifikasi izin Kemnaker & aktifkan LPK cabang/mitra baru.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _openAddLpkSheet(context),
                child: const StatusPill(label: '+ LPK Baru', color: AppColors.amber, icon: Icons.add_business_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...appState.lpkBranches.map((lpk) {
            final isVerified = lpk.status == 'verified';
            final isPending = lpk.status == 'pending';
            return GlassCard(
              highlight: isPending,
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
                            Text('${lpk.id} • ${lpk.city}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                            Text(lpk.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: isVerified ? 'TERVERIFIKASI' : isPending ? 'MENUNGGU MASTER' : 'DITANGGUHKAN',
                        color: isVerified ? AppColors.emerald : isPending ? AppColors.amber : AppColors.danger,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InfoRow(icon: Icons.verified_user_rounded, label: 'No. Izin Kemnaker', value: lpk.licenseNumber),
                  InfoRow(icon: Icons.person_outline_rounded, label: 'Penanggung Jawab', value: '${lpk.ownerName} (${lpk.ownerPhone})'),
                  InfoRow(icon: Icons.analytics_outlined, label: 'Skala Operasional', value: '${lpk.activeDrivers} Mitra • ${lpk.activeStudents} Siswa'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!isVerified)
                        Expanded(
                          child: NeonButton(
                            label: 'Verifikasi & Aktifkan LPK',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.emerald,
                            onPressed: () {
                              appState.setLpkBranchStatus(lpk.id, 'verified');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${lpk.name} resmi diverifikasi oleh MASTER INDOTECH!'),
                                  backgroundColor: AppColors.emerald,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: NeonButton(
                            label: 'Tangguhkan Sementara',
                            icon: Icons.pause_circle_outline_rounded,
                            outlined: true,
                            color: AppColors.danger,
                            onPressed: () {
                              appState.setLpkBranchStatus(lpk.id, 'suspended');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${lpk.name} ditangguhkan sementara.'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openAddLpkSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final licCtrl = TextEditingController(text: 'KEMNAKER/2026/LPK-NEW');
    final ownerCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daftarkan LPK Mitra Baru', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama LPK')),
              const SizedBox(height: 10),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Kota / Kabupaten')),
              const SizedBox(height: 10),
              TextField(controller: licCtrl, decoration: const InputDecoration(labelText: 'No. Izin Operasional Kemnaker')),
              const SizedBox(height: 10),
              TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'Nama Kepala LPK / Super Admin')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. WhatsApp')),
              const SizedBox(height: 16),
              NeonButton(
                label: 'Simpan ke Antrean Verifikasi',
                icon: Icons.add_business_rounded,
                color: AppColors.amber,
                width: double.infinity,
                onPressed: () {
                  appState.registerLpkBranch(
                    name: nameCtrl.text.trim().isEmpty ? 'LPK Bintang Mengemudi' : nameCtrl.text.trim(),
                    city: cityCtrl.text.trim().isEmpty ? 'Banjarnegara' : cityCtrl.text.trim(),
                    licenseNumber: licCtrl.text.trim(),
                    ownerName: ownerCtrl.text.trim().isEmpty ? 'Admin Cabang Baru' : ownerCtrl.text.trim(),
                    ownerPhone: phoneCtrl.text.trim().isEmpty ? '0812-0000-1111' : phoneCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
