import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminSiswaScreen extends StatelessWidget {
  final AppState appState;

  const AdminSiswaScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kelulusan & Otorisasi Sertifikat Resmi LPK', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Admin LPK menentukan kelulusan akhir dan menerbitkan E-Sertifikat untuk syarat pendampingan SIM A.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),

          if (appState.graduations.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada data kelulusan atau pengajuan E-Sertifikat siswa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            ...appState.graduations.map((g) => GlassCard(
                highlight: !g.approved,
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
                              Text(g.studentName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                              Text('Instruktur: ${g.instructorName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            ],
                          ),
                        ),
                        StatusPill(label: 'Skor ${g.avgScore.toStringAsFixed(1)}', color: AppColors.emerald),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InfoRow(icon: Icons.badge_rounded, label: 'Status SIM A', value: g.simStep),
                    InfoRow(icon: Icons.qr_code_rounded, label: 'No. Sertifikat', value: g.certNumber),
                    const SizedBox(height: 12),
                    if (!g.approved)
                      NeonButton(
                        label: 'Otorisasi Lulus & Cetak E-Sertifikat',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.amber,
                        width: double.infinity,
                        onPressed: () {
                          appState.approveGraduation(g.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sertifikat ${g.studentName} diterbitkan & siap diunduh siswa!'),
                              backgroundColor: AppColors.emerald,
                            ),
                          );
                        },
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: AppColors.emerald, size: 17),
                          SizedBox(width: 6),
                          Text('E-Sertifikat Terbit & Aktif', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
