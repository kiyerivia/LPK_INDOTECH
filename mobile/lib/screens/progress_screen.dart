import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rapor & Sertifikasi LPK',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kurikulum Resmi Terakreditasi Kemnaker RI',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showCertificateDialog(context),
              icon: const Icon(Icons.military_tech_rounded, size: 16),
              label: const Text('E-Sertifikat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Overall Kemahiran Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: GlassCardDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tingkat Kemahiran:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('92.5 / 100 (Sangat Baik)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Text('60%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  SizedBox(width: 8),
                  Text('(3 dari 5 Modul Selesai)', style: TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.6,
                  minHeight: 8,
                  backgroundColor: Color(0xFF27272A),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Checklist Modul Kurikulum Lapangan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...mockModules.map((m) {
          final isDone = m.status == 'completed';
          final isInProgress = m.status == 'in_progress';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: GlassCardDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isInProgress ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.emerald.withOpacity(0.15)
                            : isInProgress
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isDone ? 'Lulus' : isInProgress ? 'Sedang Dijalankan' : 'Menunggu',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isDone ? AppColors.emerald : isInProgress ? AppColors.primaryLight : AppColors.textSubtle,
                        ),
                      ),
                    ),
                    if (m.score != null)
                      Text(
                        'Skor: ${m.score}/100',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emerald, fontFamily: 'monospace'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(m.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                if (m.instructorNotes != null) ...[
                  const Divider(color: AppColors.cardBorder, height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.rate_review_rounded, size: 12, color: AppColors.primaryLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '"${m.instructorNotes}"',
                          style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textMain),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showCertificateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F13),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.amber.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withOpacity(0.15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.amber, size: 40),
              const SizedBox(height: 8),
              const Text(
                'LPK INDOTECH PURWOKERTO',
                style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppColors.amber, fontWeight: FontWeight.bold),
              ),
              const Text(
                'SERTIFIKAT KELULUSAN MENGEMUDI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'No: LPK-IND/SIM-A/2026/XI-0842 • Terakreditasi Kemnaker',
                style: TextStyle(fontSize: 9, color: AppColors.textSubtle, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text('Diberikan secara sah kepada:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    SizedBox(height: 2),
                    Text(
                      'Dimas Aditya Pratama',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Telah menyelesaikan pelatihan mengemudi roda 4 kurikulum standar internasional & siap uji kompetensi SIM A.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: const [
                      Text('Instruktur', style: TextStyle(fontSize: 9, color: AppColors.textSubtle)),
                      SizedBox(height: 4),
                      Text('Bambang S.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_rounded, color: Colors.black, size: 36),
                  ),
                  Column(
                    children: const [
                      Text('Direktur LPK', style: TextStyle(fontSize: 9, color: AppColors.textSubtle)),
                      SizedBox(height: 4),
                      Text('Drs. H. M. Indotech', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.amber)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
