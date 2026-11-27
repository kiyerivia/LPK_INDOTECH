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
          // Matte CIJ Red Hero Banner (Solid Doff, No Gradient)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.matteBanner(color: AppColors.primary, radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () => _pickArea(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.navBarActiveIcon, size: 14),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  appState.studentLocation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'LPK Resmi',
                        style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Halo, ${appState.userName.trim().isNotEmpty ? appState.userName.trim().split(' ').first : 'Siswa'}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pesan Instruktur Mengemudi\nTerdekat di Sekitar Anda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${activeDrivers.length} instruktur bersertifikat rem ganda tersedia dalam radius 3-10 km.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onOpenSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.18),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.radar_rounded, size: 18),
                    label: const Text(
                      'Cari Instruktur Terdekat',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader(title: 'Tahapan Pelatihan'),
          SizedBox(
            height: 74,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _flowChip('Lokasi', 'Radius 3-10 km', Icons.radar_rounded, false, onOpenSearch),
                _flowChip('Booking', '${appState.orders.length} Order', Icons.calendar_today_rounded, appState.orders.isNotEmpty, onOpenSchedule),
                _flowChip('Latihan', '$completedModules/5 Modul', Icons.directions_car_rounded, completedModules > 0, onOpenSchedule),
                _flowChip('Sertifikat', completedModules > 0 ? 'Nilai ${appState.studentAvgScore.toStringAsFixed(0)}' : 'Belum ada nilai', Icons.workspace_premium_rounded, appState.studentCertApproved, onOpenReport),
                _flowChip('Proses SIM A', 'Satpas Banyumas', Icons.badge_rounded, false, onOpenReport),
              ],
            ),
          ),

          // Instruktur Terdekat Aktif
          SectionHeader(
            title: 'Instruktur Terdekat Aktif',
            actionLabel: 'Buka Radar',
            onAction: onOpenSearch,
          ),
          if (activeDrivers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.radar_rounded, color: AppColors.primary, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum Ada Mitra Instruktur Aktif',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mitra driver yang sudah lulus KYC & uji rem ganda dari Admin LPK akan otomatis muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          else
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
                  onTap: () {
                    if (activeDrivers.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Belum ada mitra instruktur aktif untuk paket ini. Cek Radar GPS secara berkala.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                      return;
                    }
                    onBook(activeDrivers.first, pkg);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      pkg.name,
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15),
                                    ),
                                    if (pkg.isPopular)
                                      const StatusPill(label: 'Best Seller', color: AppColors.amber),
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
                              f,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w600),
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
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.72),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Text('Pilih Area Lokasi', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ...appState.serviceAreas.where((a) => a.active).map((area) {
                  final selected = appState.studentLocation == area.name;
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(
                      Icons.location_on_rounded,
                      color: selected ? AppColors.primary : AppColors.textMuted,
                    ),
                    title: Text(area.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                    subtitle: Text('${area.activeDrivers} mitra driver aktif', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.emerald) : null,
                    onTap: () {
                      appState.setStudentLocation(area.name);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
