import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class SiswaHomeScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenReport;
  final void Function(Instructor instructor, [DrivingPackage? pkg]) onBook;

  const SiswaHomeScreen({
    super.key,
    required this.appState,
    required this.onOpenSearch,
    required this.onOpenSchedule,
    required this.onOpenReport,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final activeDrivers = appState.instructors.where((i) => i.isOnline).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final completedModules = appState.modules.where((m) => m.completed).length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Futuristic Gradient Hero Card (Soft Indigo → Electric Sky Blue)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1D4ED8), // Deep Royal Blue
                  Color(0xFF2563EB), // Electric Blue
                  Color(0xFF0EA5E9), // Futuristic Sky Cyan
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickArea(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.my_location_rounded, color: Colors.white, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              appState.studentLocation,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('LPK Resmi', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Halo, ${appState.userName.split(' ').first}!',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pesan Instruktur Mengemudi\nTerdekat Seperti Ojol',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${activeDrivers.length} mitra driver terverifikasi rem ganda aktif di radius 3–10 km dari lokasimu.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onOpenSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.radar_rounded, size: 18),
                    label: const Text(
                      'Cari Instruktur Terdekat (Radar GPS)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alur Kursus → SIM A Strip
          const SectionHeader(title: 'Alur Driving Partner LPK'),
          SizedBox(
            height: 76,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _flowChip('1. Lokasi', 'Radius 3-10km', Icons.radar_rounded, true, onOpenSearch),
                _flowChip('2. Booking', 'Pilih Jadwal', Icons.calendar_today_rounded, true, onOpenSchedule),
                _flowChip('3. Latihan', '$completedModules/5 Modul', Icons.directions_car_rounded, true, onOpenSchedule),
                _flowChip('4. Ujian & Sertifikat', 'Nilai ${appState.studentAvgScore.toStringAsFixed(0)}', Icons.workspace_premium_rounded, appState.studentCertApproved, onOpenReport),
                _flowChip('5. Proses SIM A', 'Satpas Banyumas', Icons.badge_rounded, false, onOpenReport),
              ],
            ),
          ),

          // 5 Instruktur Terdekat
          SectionHeader(
            title: '5 Instruktur Terdekat Aktif',
            actionLabel: 'Buka Radar',
            onAction: onOpenSearch,
          ),
          SizedBox(
            height: 205,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activeDrivers.take(5).length,
              itemBuilder: (_, idx) {
                final inst = activeDrivers[idx];
                return GestureDetector(
                  onTap: () => onBook(inst),
                  child: Container(
                    width: 222,
                    margin: const EdgeInsets.only(right: 12, top: 2, bottom: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: AppTheme.glassCard(radius: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarInitial(initial: inst.initial, size: 40, online: inst.isOnline),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inst.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppColors.amber, size: 13),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          '${inst.rating} (${inst.reviews})',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          inst.originDriver,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${inst.carModel} (${inst.plateNumber})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.near_me_rounded, color: AppColors.emerald, size: 13),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${inst.distanceKm} km • ${inst.etaMinutes} mnt',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 12),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                'Rem Ganda LPK',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Booking',
                                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Paket Pelatihan
          const SectionHeader(title: 'Paket Kursus & Pendampingan SIM'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: appState.packages.map((pkg) {
                return GlassCard(
                  highlight: pkg.isPopular,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  onTap: () => onBook(activeDrivers.first, pkg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      pkg.name,
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15),
                                    ),
                                    if (pkg.isPopular) ...[
                                      const SizedBox(width: 8),
                                      const StatusPill(label: 'Best Seller', color: AppColors.amber),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  pkg.description,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatRupiah(pkg.price),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${pkg.sessions}x pertemuan',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: pkg.features.take(3).map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✓ $f',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 108),
        ],
      ),
    );
  }

  Widget _flowChip(String title, String sub, IconData icon, bool done, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 136,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(11),
        decoration: AppTheme.glassCard(
          radius: 16,
          borderColor: done ? AppColors.emerald.withValues(alpha: 0.4) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: done ? AppColors.emerald : AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _pickArea(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Area Lokasi Kamu (Purwokerto)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...appState.serviceAreas.where((a) => a.active).map((area) {
              final selected = appState.studentLocation == area.name;
              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.location_on_rounded,
                  color: selected ? AppColors.emerald : AppColors.textMuted,
                ),
                title: Text(area.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                subtitle: Text('${area.activeDrivers} mitra driver aktif', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                trailing: selected ? const Icon(Icons.check_circle, color: AppColors.emerald) : null,
                onTap: () {
                  appState.setStudentLocation(area.name);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
