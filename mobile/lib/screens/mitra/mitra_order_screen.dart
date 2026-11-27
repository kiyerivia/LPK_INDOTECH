import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class MitraOrderScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onGoToEval;

  const MitraOrderScreen({
    super.key,
    required this.appState,
    required this.onGoToEval,
  });

  @override
  Widget build(BuildContext context) {
    final pendingOrders = appState.orders.where((o) => o.stage == TripStage.pending).toList();
    final activeTrips = appState.orders
        .where((o) =>
            o.stage == TripStage.accepted ||
            o.stage == TripStage.onTheWay ||
            o.stage == TripStage.arrived ||
            o.stage == TripStage.training)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matte CIJ Driver Status Banner (Solid Doff, No Gradient)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.matteBanner(
              color: appState.mitraIsOnline ? AppColors.primary : const Color(0xFF44403C),
              radius: 18,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AvatarInitial(
                      initial: appState.userName.trim().isNotEmpty
                          ? appState.userName.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
                          : 'M',
                      size: 46,
                      online: appState.mitraIsOnline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  appState.userName.isNotEmpty ? appState.userName : 'Mitra Driver',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: AppColors.navBarActiveIcon, size: 16),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appState.mitraCarInfo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        appState.mitraIsOnline ? Icons.sensors_rounded : Icons.power_settings_new_rounded,
                        color: appState.mitraIsOnline ? AppColors.navBarActiveIcon : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.mitraIsOnline ? 'Online - Siap Terima Order' : 'Offline - Istirahat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                            Text(
                              appState.mitraIsOnline
                                  ? 'Radius layanan ${appState.mitraServiceRadius.toInt()} km (${appState.mitraServiceAreas.length} area)'
                                  : 'Aktifkan status online untuk menerima order pelatihan',
                              style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: appState.mitraIsOnline,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.navBarActiveIcon,
                        onChanged: appState.toggleMitraOnline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _miniMetric('Saldo Siap Cair', formatRupiah(appState.mitraWalletBalance), AppColors.emerald, Icons.account_balance_wallet_rounded),
              const SizedBox(width: 10),
              _miniMetric(
                appState.mitraEscrowBalance > 0 ? 'Dana Ditahan' : 'Bagi Hasil',
                appState.mitraEscrowBalance > 0 ? formatRupiah(appState.mitraEscrowBalance) : '${appState.mitraSplitPercent}% / Kursus',
                appState.mitraEscrowBalance > 0 ? AppColors.amber : AppColors.primary,
                appState.mitraEscrowBalance > 0 ? Icons.lock_clock_rounded : Icons.pie_chart_rounded,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: pendingOrders.isNotEmpty ? AppColors.primary : AppColors.textMuted, size: 18),
              const SizedBox(width: 6),
              Text(
                'Order Masuk (${pendingOrders.length})',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (!appState.mitraIsOnline)
            const GlassCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Status Anda sedang offline.\nAktifkan status online di atas untuk menerima order siswa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            )
          else if (pendingOrders.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada order baru saat ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            )
          else
            ...pendingOrders.map((order) => _buildIncomingOrderCard(context, order)),

          const SizedBox(height: 18),

          const Text('Order Aktif & Eksekusi Lapangan', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          if (activeTrips.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text('Tidak ada sesi berjalan saat ini.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            )
          else
            ...activeTrips.map((trip) => _buildActiveTripCard(context, trip)),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String val, Color color, IconData icon) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  Text(
                    val,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingOrderCard(BuildContext context, BookingOrder order) {
    return GlassCard(
      highlight: true,
      highlightColor: AppColors.primary,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Flexible(
                child: StatusPill(label: 'ORDER BARU', color: AppColors.primary, icon: Icons.bolt_rounded),
              ),
              const SizedBox(width: 8),
              Text(
                '+${formatRupiah(order.mitraEarning)}',
                style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(order.studentName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          InfoRow(icon: Icons.location_on_rounded, label: 'Jemput (${order.distanceKm} km)', value: order.pickupAddress),
          InfoRow(icon: Icons.school_rounded, label: 'Paket', value: '${order.packageName} (${order.transmission})'),
          InfoRow(icon: Icons.schedule_rounded, label: 'Jadwal', value: '${order.date.day}/${order.date.month}/${order.date.year} • ${order.timeSlot}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: NeonButton(
                  label: 'Terima Order',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.emerald,
                  onPressed: () {
                    appState.updateOrderStage(order.id, TripStage.accepted);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order ${order.studentName} diterima.'),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: NeonButton(
                  label: 'Tolak',
                  outlined: true,
                  color: AppColors.textSecondary,
                  onPressed: () => appState.updateOrderStage(order.id, TripStage.rejected),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripCard(BuildContext context, BookingOrder trip) {
    String actionLabel;
    TripStage nextStage;
    Color actionColor;
    String statusBadge;

    switch (trip.stage) {
      case TripStage.accepted:
        statusBadge = 'SIAP BERANGKAT';
        actionLabel = 'Berangkat ke Lokasi Siswa';
        nextStage = TripStage.onTheWay;
        actionColor = AppColors.primary;
        break;
      case TripStage.onTheWay:
        statusBadge = 'MENUJU LOKASI (${trip.distanceKm} KM)';
        actionLabel = 'Saya Sudah Tiba di Lokasi';
        nextStage = TripStage.arrived;
        actionColor = AppColors.amber;
        break;
      case TripStage.arrived:
        statusBadge = 'TIBA DI TITIK JEMPUT';
        actionLabel = 'Mulai Sesi Pelatihan (2 Jam)';
        nextStage = TripStage.training;
        actionColor = AppColors.purple;
        break;
      default:
        statusBadge = 'SEDANG MELATIH • AKTIF';
        actionLabel = 'Selesai Latihan & Isi Nilai';
        nextStage = TripStage.completed;
        actionColor = AppColors.emerald;
    }

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(label: statusBadge, color: actionColor, icon: Icons.directions_car_rounded),
              const Spacer(),
              Text(trip.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${trip.studentName} • Sesi #${trip.sessionIndex}',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          InfoRow(icon: Icons.location_on_rounded, label: 'Alamat Siswa', value: trip.pickupAddress),
          InfoRow(icon: Icons.access_time_rounded, label: 'Slot', value: trip.timeSlot),
          InfoRow(icon: Icons.payments_rounded, label: 'Insentif Cair Setelah Sesi', value: formatRupiah(trip.mitraEarning), valueColor: AppColors.emerald),
          const SizedBox(height: 12),
          NeonButton(
            label: actionLabel,
            icon: nextStage == TripStage.completed ? Icons.assignment_turned_in_rounded : Icons.navigation_rounded,
            color: actionColor,
            width: double.infinity,
            onPressed: () {
              appState.updateOrderStage(trip.id, nextStage);
              if (nextStage == TripStage.completed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sesi selesai! +${formatRupiah(trip.mitraEarning)} masuk ke Dompet Mitra.'),
                    backgroundColor: AppColors.emerald,
                  ),
                );
                onGoToEval();
              }
            },
          ),
        ],
      ),
    );
  }
}
