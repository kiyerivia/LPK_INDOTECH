import 'package:flutter/material.dart';
import '../models/data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active session card
          GlassCard(
            highlight: true,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_circle_filled, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('Sesi Mendatang', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    StatusBadge.fromStatus('dikonfirmasi'),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Paket Standar · Sesi ke-3', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('Pak Hendra Wijaya', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _infoChip(Icons.calendar_today, 'Besok'),
                    const SizedBox(width: 8),
                    _infoChip(Icons.access_time, '09:00 WIB'),
                    const SizedBox(width: 8),
                    _infoChip(Icons.timer, '2 jam'),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text('Lacak Lokasi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress bar
          const SectionHeader(title: '📊 Progress Latihan'),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paket Standar', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const Text('3/10 sesi', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('30% selesai · 7 sesi tersisa', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Riwayat
          const SectionHeader(title: '🕐 Riwayat Sesi'),
          ...mockBooking.map((b) => _bookingCard(b)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _bookingCard(Booking b) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: b.status == 'selesai' ? AppTheme.success.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(b.status == 'selesai' ? Icons.check_circle : Icons.schedule, color: b.status == 'selesai' ? AppTheme.success : AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sesi ke-${b.sesiKe} · ${b.paketNama}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13)),
                const SizedBox(height: 2),
                Text('${b.tanggal.day}/${b.tanggal.month}/${b.tanggal.year} · ${b.jam}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          StatusBadge.fromStatus(b.status),
        ],
      ),
    );
  }
}
