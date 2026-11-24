import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class MitraEvalScreen extends StatefulWidget {
  final AppState appState;

  const MitraEvalScreen({super.key, required this.appState});

  @override
  State<MitraEvalScreen> createState() => _MitraEvalScreenState();
}

class _MitraEvalScreenState extends State<MitraEvalScreen> {
  String _selectedModuleId = 'MOD-1';
  double _score = 80;
  final _notesCtrl = TextEditingController();

  final Map<String, bool> _skills = {
    'Penguasaan setir & posisi lajur': false,
    'Koordinasi pedal gas, rem & kopling': false,
    'Teknik stop & go tanjakan aman': false,
    'Parkir seri & paralel rapi': false,
    'Disiplin spion, sein & rambu lalu lintas': false,
    'Ketenangan & tidak panik di kemacetan': false,
  };

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.appState.submitEvaluation(
      moduleId: _selectedModuleId,
      score: _score.round(),
      notes: _notesCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nilai ${_score.round()}/100 berhasil dikirim ke Rapor Siswa & Admin LPK!'),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusPill(label: 'EVALUASI LAPANGAN', color: AppColors.emerald, icon: Icons.fact_check_rounded),
                const SizedBox(height: 8),
                const Text('Input Penilaian Siswa', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  widget.appState.orders.isEmpty
                      ? 'Belum ada sesi siswa aktif • Nilai yang dikirim akan tersinkron ke Rapor Siswa & Admin LPK.'
                      : 'Siswa: ${widget.appState.orders.first.studentName} • Nilai langsung tersinkron ke Rapor Siswa & diverifikasi Admin LPK.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 14),

                const Text('Pilih Modul yang Dinilai:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedModuleId,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                  items: widget.appState.modules
                      .map((m) => DropdownMenuItem(value: m.id, child: Text(m.title, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedModuleId = v);
                  },
                ),

                const SizedBox(height: 16),
                const Text('Checklist Keterampilan Lapangan:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ..._skills.entries.map((e) {
                  return InkWell(
                    onTap: () => setState(() => _skills[e.key] = !e.value),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: e.value
                            ? AppColors.emerald.withValues(alpha: 0.10)
                            : AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: e.value ? AppColors.emerald.withValues(alpha: 0.45) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            e.value ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            color: e.value ? AppColors.emerald : AppColors.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.key,
                              style: TextStyle(
                                color: e.value ? AppColors.textPrimary : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: e.value ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Skor Kelulusan Sesi:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(
                      '${_score.round()} / 100',
                      style: const TextStyle(color: AppColors.emerald, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Slider(
                  value: _score,
                  min: 60,
                  max: 100,
                  divisions: 40,
                  activeColor: AppColors.emerald,
                  inactiveColor: AppColors.borderSubtle,
                  onChanged: (v) => setState(() => _score = v),
                ),

                const SizedBox(height: 8),
                const Text('Catatan Evaluasi untuk Siswa:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Tulis catatan perbaikan & progres siswa...'),
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: 'Simpan & Kirim Nilai ke Rapor Siswa',
                  icon: Icons.send_rounded,
                  color: AppColors.emerald,
                  width: double.infinity,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
