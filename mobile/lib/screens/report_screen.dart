import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'title': 'Teori Dasar Mengemudi', 'done': true, 'score': 90},
      {'title': 'Pengenalan Komponen Kendaraan', 'done': true, 'score': 85},
      {'title': 'Teknik Dasar Mengemudi', 'done': true, 'score': 88},
      {'title': 'Parkir & Manuver', 'done': false, 'score': null},
      {'title': 'Simulasi Ujian SIM', 'done': false, 'score': null},
    ];

    final avg = modules.where((m) => m['score'] != null).fold<double>(0, (s, m) => s + (m['score'] as int)) / modules.where((m) => m['score'] != null).length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score summary
          GlassCard(
            highlight: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Nilai Rata-Rata', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    const Text('/100', style: TextStyle(color: AppTheme.textSecondary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('🏆 Lulus — Sangat Baik', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('3/5', 'Modul Selesai', AppTheme.info),
                    _statItem('3', 'Sesi Selesai', AppTheme.success),
                    _statItem('30%', 'Progress', AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Modules
          const SectionHeader(title: '📚 Modul Kurikulum'),
          ...modules.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;
            final done = m['done'] as bool;
            final score = m['score'] as int?;
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppTheme.success.withOpacity(0.15) : Colors.white.withOpacity(0.07),
                      border: Border.all(color: done ? AppTheme.success : Colors.white.withOpacity(0.1)),
                    ),
                    alignment: Alignment.center,
                    child: done
                        ? const Icon(Icons.check, color: AppTheme.success, size: 18)
                        : Text('${i + 1}', style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(m['title'] as String, style: TextStyle(color: done ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
                  ),
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: score >= 85 ? AppTheme.success.withOpacity(0.15) : AppTheme.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$score', style: TextStyle(color: score >= 85 ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.bold)),
                    )
                  else
                    const Text('Belum', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // E-Sertifikat
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, color: AppTheme.warning, size: 44),
                const SizedBox(height: 10),
                const Text('E-Sertifikat', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Tersedia setelah lulus semua modul', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download Sertifikat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
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
}
