import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class SiswaReportScreen extends StatefulWidget {
  final AppState appState;

  const SiswaReportScreen({super.key, required this.appState});

  @override
  State<SiswaReportScreen> createState() => _SiswaReportScreenState();
}

class _SiswaReportScreenState extends State<SiswaReportScreen> {
  final List<bool> _simChecklist = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    final modules = widget.appState.modules;
    final doneCount = modules.where((m) => m.completed).length;
    final avg = widget.appState.studentAvgScore;
    final certApproved = widget.appState.studentCertApproved;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            highlight: true,
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text('Rapor Evaluasi Mengemudi LPK', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      doneCount > 0 ? avg.toStringAsFixed(1) : '—',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text('/100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StatusPill(
                  label: doneCount == 0
                      ? 'BELUM ADA NILAI • MULAI LATIHAN'
                      : avg >= 85
                          ? 'SANGAT BAIK • SIAP UJIAN SIM A'
                          : 'DALAM PROSES LATIHAN',
                  color: doneCount == 0 ? AppColors.textMuted : AppColors.emerald,
                  icon: Icons.emoji_events_rounded,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: doneCount / modules.length,
                    minHeight: 8,
                    backgroundColor: AppColors.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$doneCount dari ${modules.length} modul selesai', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('${((doneCount / modules.length) * 100).round()}%', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('Kurikulum & Nilai dari Instruktur', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          ...modules.asMap().entries.map((entry) {
            final idx = entry.key;
            final m = entry.value;
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: m.completed
                              ? AppColors.emerald.withValues(alpha: 0.14)
                              : AppColors.backgroundAlt,
                          border: Border.all(
                            color: m.completed ? AppColors.emerald : AppColors.borderSubtle,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: m.completed
                            ? const Icon(Icons.check_rounded, color: AppColors.emerald, size: 18)
                            : Text('${idx + 1}', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(m.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      if (m.score != null)
                        StatusPill(label: '${m.score}', color: AppColors.emerald)
                      else
                        const StatusPill(label: 'Belum', color: AppColors.textMuted),
                    ],
                  ),
                  if (m.instructorNotes != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Catatan Instruktur: "${m.instructorNotes}"',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          GlassCard(
            highlight: certApproved,
            highlightColor: AppColors.amber,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.amber, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('E-Sertifikat Kelulusan LPK', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                          Text(
                            certApproved
                                ? 'Nomor: LPK-IND/2026/SIM-A/0102 • Terverifikasi'
                                : 'Menunggu otorisasi kelulusan Admin LPK',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NeonButton(
                  label: certApproved ? 'Lihat & Unduh E-Sertifikat' : 'Menunggu Kelulusan Admin LPK',
                  icon: Icons.verified_rounded,
                  color: AppColors.amber,
                  width: double.infinity,
                  onPressed: certApproved ? () => _showCertificateModal(context) : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text('Pendampingan Proses SIM A (Satpas Banyumas)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Setelah lulus kursus LPK INDOTECH, siswa diarahkan dan didampingi ke proses pembuatan SIM A resmi:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 10),
                _simCheckItem(0, 'Sertifikat Lulus Pelatihan LPK INDOTECH'),
                _simCheckItem(1, 'e-KTP Asli + Fotokopi (Minimal usia 17 tahun)'),
                _simCheckItem(2, 'Surat Keterangan Sehat Jasmani & Tes Psikotes'),
                _simCheckItem(3, 'Pendaftaran Antrean & Uji Teori/Praktik di Satpas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _simCheckItem(int idx, String label) {
    final checked = _simChecklist[idx];
    return InkWell(
      onTap: () => setState(() => _simChecklist[idx] = !checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: checked ? AppColors.emerald : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: checked ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCertificateModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.amber.withValues(alpha: 0.45), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.amber, size: 52),
              const SizedBox(height: 8),
              const Text(
                'SERTIFIKAT KOMPETENSI MENGEMUDI',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              const Text('LPK INDOTECH PURWOKERTO', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              const Divider(height: 24),
              const Text('Diberikan kepada:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                widget.appState.userName,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Telah dinyatakan LULUS pelatihan mengemudi standar LPK dengan nilai rata-rata ${widget.appState.studentAvgScore.toStringAsFixed(1)}/100 dan direkomendasikan untuk pengajuan SIM A.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.45),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2_rounded, color: AppColors.textPrimary, size: 28),
                    SizedBox(width: 8),
                    Text('No. Reg: LPK-IND/2026/SIM-A/0102', style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeonButton(
                label: 'Tutup',
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
