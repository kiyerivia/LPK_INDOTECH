import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class SiswaScheduleScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onBookMore;

  const SiswaScheduleScreen({
    super.key,
    required this.appState,
    required this.onBookMore,
  });

  String _stageText(TripStage stage) {
    switch (stage) {
      case TripStage.pending:
        return 'Menunggu Konfirmasi Mitra';
      case TripStage.accepted:
        return 'Terjadwal & Dikonfirmasi';
      case TripStage.onTheWay:
        return 'Mitra Menuju Lokasimu';
      case TripStage.arrived:
        return 'Mitra Tiba di Titik Jemput';
      case TripStage.training:
        return 'Sesi Latihan Berlangsung';
      case TripStage.completed:
        return 'Sesi Selesai';
      case TripStage.rejected:
        return 'Dialihkan ke Mitra Lain';
    }
  }

  Color _stageColor(TripStage stage) {
    switch (stage) {
      case TripStage.pending:
        return AppColors.amber;
      case TripStage.accepted:
        return AppColors.primary;
      case TripStage.onTheWay:
      case TripStage.arrived:
        return AppColors.primaryLight;
      case TripStage.training:
        return AppColors.purple;
      case TripStage.completed:
        return AppColors.emerald;
      case TripStage.rejected:
        return AppColors.textMuted;
    }
  }

  int _stageStepIndex(TripStage stage) {
    switch (stage) {
      case TripStage.pending:
        return 0;
      case TripStage.accepted:
        return 1;
      case TripStage.onTheWay:
        return 2;
      case TripStage.arrived:
      case TripStage.training:
        return 3;
      case TripStage.completed:
        return 4;
      case TripStage.rejected:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = appState.orders.where((o) => o.stage != TripStage.completed && o.stage != TripStage.rejected).toList();
    final pastOrders = appState.orders.where((o) => o.stage == TripStage.completed || o.stage == TripStage.rejected).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeOrders.isNotEmpty) ...[
            const Text('Order & Tracking Langsung', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...activeOrders.map((order) => _buildActiveCard(context, order)),
          ] else
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 42),
                  const SizedBox(height: 10),
                  const Text('Belum Ada Sesi Aktif', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Cari mitra instruktur terdekat dan booking jadwal latihanmu sekarang.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 14),
                  NeonButton(label: 'Cari Instruktur Terdekat', icon: Icons.radar_rounded, onPressed: onBookMore),
                ],
              ),
            ),

          const SizedBox(height: 16),
          const Text('Riwayat Pertemuan', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (pastOrders.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'Belum ada riwayat pertemuan. Riwayat akan tercatat otomatis setelah sesi selesai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            ...pastOrders.map((order) => GlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sesi #${order.sessionIndex}/${order.totalSessions} • ${order.packageName}',
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${order.instructorName} • ${order.timeSlot}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(label: _stageText(order.stage), color: _stageColor(order.stage)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context, BookingOrder order) {
    final step = _stageStepIndex(order.stage);
    const stepLabels = ['Order', 'Siap', 'Otw', 'Latihan', 'Selesai'];

    return GlassCard(
      highlight: true,
      highlightColor: _stageColor(order.stage),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
              const Spacer(),
              StatusPill(label: _stageText(order.stage), color: _stageColor(order.stage)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${order.packageName} (Sesi ${order.sessionIndex}/${order.totalSessions})',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.instructorName} • ${order.carInfo} (${order.transmission})',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),

          Row(
            children: List.generate(stepLabels.length, (i) {
              final reached = i <= step;
              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (i > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: reached ? AppColors.emerald : AppColors.borderSubtle,
                            ),
                          ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: reached ? AppColors.emerald : Colors.white,
                            border: Border.all(
                              color: reached ? AppColors.emerald : AppColors.borderSubtle,
                            ),
                          ),
                          child: reached
                              ? const Icon(Icons.check, size: 11, color: Colors.white)
                              : null,
                        ),
                        if (i < stepLabels.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: i < step ? AppColors.emerald : AppColors.borderSubtle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepLabels[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: reached ? FontWeight.w800 : FontWeight.w500,
                        color: reached ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 12),
          InfoRow(icon: Icons.location_on_rounded, label: 'Titik Jemput', value: order.pickupAddress),
          InfoRow(icon: Icons.access_time_rounded, label: 'Waktu Sesi', value: '${order.date.day}/${order.date.month}/${order.date.year} • ${order.timeSlot}'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: NeonButton(
                  label: 'Chat WA Mitra',
                  icon: Icons.chat_rounded,
                  color: AppColors.emerald,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menghubungi ${order.instructorName} via WhatsApp...'),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeonButton(
                  label: 'Share GPS',
                  icon: Icons.my_location_rounded,
                  outlined: true,
                  color: AppColors.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Titik GPS terkini berhasil dibagikan ke instruktur!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
