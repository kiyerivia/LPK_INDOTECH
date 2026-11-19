import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminConfigScreen extends StatelessWidget {
  final AppState appState;

  const AdminConfigScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengaturan Tarif & Bagi Hasil Otomatis', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bagian Mitra Driver:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('${appState.mitraSplitPercent}%', style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800)),
                  ],
                ),
                Slider(
                  value: appState.mitraSplitPercent.toDouble(),
                  min: 50,
                  max: 70,
                  divisions: 20,
                  activeColor: AppColors.emerald,
                  inactiveColor: AppColors.borderSubtle,
                  onChanged: (v) => appState.updateSplit(v.round(), appState.lpkSplitPercent),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bagian LPK INDOTECH:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('${appState.lpkSplitPercent}%', style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w800)),
                  ],
                ),
                Slider(
                  value: appState.lpkSplitPercent.toDouble(),
                  min: 15,
                  max: 35,
                  divisions: 20,
                  activeColor: AppColors.purple,
                  inactiveColor: AppColors.borderSubtle,
                  onChanged: (v) => appState.updateSplit(appState.mitraSplitPercent, v.round()),
                ),
                InfoRow(
                  icon: Icons.memory_rounded,
                  label: 'Platform & Asuransi (Otomatis)',
                  value: '${appState.platformSplitPercent}%',
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text('Kelola Wilayah Layanan Purwokerto', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: appState.serviceAreas.asMap().entries.map((entry) {
                final idx = entry.key;
                final area = entry.value;
                return SwitchListTile(
                  dense: true,
                  title: Text(area.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: Text('${area.activeDrivers} mitra driver terdaftar', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.emerald,
                  value: area.active,
                  onChanged: (_) => appState.toggleServiceArea(idx),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          const Text('Kurikulum Standar LPK (5 Modul)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...appState.modules.map((m) => GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.purple, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
                          Text(m.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
