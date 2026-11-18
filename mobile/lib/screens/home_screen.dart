import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final Function(Instructor, DrivingPackage?) onBookInstructor;
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToSchedule;
  final VoidCallback onNavigateToProgress;

  const HomeScreen({
    super.key,
    required this.onBookInstructor,
    required this.onNavigateToSearch,
    required this.onNavigateToSchedule,
    required this.onNavigateToProgress,
  });

  @override
  Widget build(BuildContext context) {
    final activeInstructor = mockInstructors[0];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        // Hero Glass Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: GlassCardDecoration(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Pelatihan Mengemudi Terstandar & Jemput di Rumah',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  text: 'Belajar Nyetir Bersama\n',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  children: [
                    TextSpan(
                      text: 'Instruktur Terdekat',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'LPK Indotech menghadirkan kurikulum resmi dengan mitra instruktur lapangan jemput di rumah. Siap dampingi ujian SIM A sampai lulus.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNavigateToSearch,
                      icon: const Icon(Icons.explore_rounded, size: 16),
                      label: const Text('Cari Terdekat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        shadowColor: AppColors.primaryGlow.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNavigateToSchedule,
                      icon: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primaryLight),
                      label: const Text('Jadwal Saya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMain,
                        side: BorderSide(color: Colors.white.withOpacity(0.15)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Radar Instruktur Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'RADAR INSTRUKTUR AKTIF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onNavigateToSearch,
              child: const Text(
                'Lihat Semua (4) ›',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal Instructor Cards
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mockInstructors.length,
            itemBuilder: (context, index) {
              final inst = mockInstructors[index];
              return Container(
                width: 240,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: GlassCardDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            inst.avatar,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inst.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${inst.rating}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.amber),
                                  ),
                                  Text(
                                    ' (${inst.reviewsCount})',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSubtle),
                                  ),
                                ],
                              ),
                              Text(
                                '${inst.distanceKm} km • ${inst.locationName.split(",")[0]}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            inst.transmission,
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                          ),
                          Text(
                            'Rp ${inst.hourlyRate ~/ 1000}k/jam',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onBookInstructor(inst, null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          foregroundColor: AppColors.primaryLight,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                          ),
                        ),
                        child: const Text('Booking Sesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Active Session Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: GlassCardDecoration(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'STATUS PELATIHAN ANDA',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Aktif (Sesi 3 dari 5)',
                      style: TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Modul 3: Stop & Go Tanjakan Baturraden',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Instruktur: ${activeInstructor.name} • ${activeInstructor.carModel}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onNavigateToProgress,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMain,
                        side: BorderSide(color: Colors.white.withOpacity(0.12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Lihat Rapor', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNavigateToSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Booking Sesi 4', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Paket Kursus Mengemudi
        const Text(
          'Pilihan Paket Kursus Mengemudi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Kurikulum bertahap dari pemula hingga siap tes SIM A',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 12),

        ...mockPackages.map((pkg) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: GlassCardDecoration(
                color: pkg.popular ? const Color(0xCC20171D) : null,
                borderRadius: BorderRadius.circular(22),
                border: pkg.popular ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pkg.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      if (pkg.popular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FAVORIT',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  Text(pkg.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp ${pkg.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${pkg.sessions} Sesi (${pkg.hoursTotal} Jam)',
                        style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.cardBorder, height: 20),
                  ...pkg.features.take(4).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(f, style: const TextStyle(fontSize: 11, color: AppColors.textMain))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onBookInstructor(activeInstructor, pkg),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkg.popular ? AppColors.primary : AppColors.card,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                      ),
                      child: const Text('Pilih Paket Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
