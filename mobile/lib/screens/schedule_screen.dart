import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatelessWidget {
  final VoidCallback onBookMore;

  const ScheduleScreen({super.key, required this.onBookMore});

  @override
  Widget build(BuildContext context) {
    final inst = mockInstructors[0];

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
                  'Jadwal Pelatihan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Door-to-door dengan buffer perjalanan 30 menit',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            IconButton(
              onPressed: onBookMore,
              icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Upcoming Session Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: GlassCardDecoration(
            color: const Color(0xCC1F161A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'SESI TERDEKAT BERIKUTNYA',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryLight, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Terkonfirmasi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Besok, 08:00 - 10:00 WIB',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Modul 3: Stop & Go Tanjakan Baturraden',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Kost Putri Melati, Jl. Kampus Grendeng No. 12, Purwokerto Utara',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.cardBorder, height: 20),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(inst.avatar, width: 36, height: 36, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inst.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('${inst.carModel} • ${inst.carPlate}', style: const TextStyle(fontSize: 10, color: AppColors.textSubtle)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menghubungi instruktur via WhatsApp LPK Indotech...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Chat WA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Riwayat & Rencana Sesi',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        _buildTimelineItem(
          title: 'Modul 4: Master Parkir Seri & Paralel',
          date: 'Sabtu, 21 Nov 2026 (10:30 WIB)',
          instructor: 'Bambang Sugiantoro (Avanza)',
          isCompleted: false,
        ),
        _buildTimelineItem(
          title: 'Modul 2: Manuver Belok & Haluan Jalan Sempit',
          date: '14 Nov 2026 (08:00 WIB)',
          instructor: 'Bambang Sugiantoro • Skor 90/100',
          isCompleted: true,
        ),
        _buildTimelineItem(
          title: 'Modul 1: Kokpit & Kontrol Pedal',
          date: '12 Nov 2026 (08:00 WIB)',
          instructor: 'Bambang Sugiantoro • Skor 95/100',
          isCompleted: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String instructor,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: GlassCardDecoration(
        color: isCompleted ? Colors.white.withOpacity(0.02) : null,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
            color: isCompleted ? AppColors.emerald : AppColors.primaryLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(instructor, style: const TextStyle(fontSize: 10, color: AppColors.textSubtle)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
