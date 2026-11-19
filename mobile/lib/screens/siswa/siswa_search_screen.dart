import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/radar_map.dart';

class SiswaSearchScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<Instructor> onBook;

  const SiswaSearchScreen({
    super.key,
    required this.appState,
    required this.onBook,
  });

  @override
  State<SiswaSearchScreen> createState() => _SiswaSearchScreenState();
}

class _SiswaSearchScreenState extends State<SiswaSearchScreen> {
  double _radiusKm = 5.0;
  String _transmission = 'Semua';
  String _query = '';
  Instructor? _selectedPin;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Instructor> get _nearestInstructors {
    final list = widget.appState.instructors.where((i) {
      final inRadius = i.distanceKm <= _radiusKm;
      final matchTrans = _transmission == 'Semua' || i.transmissions.contains(_transmission);
      final matchQuery = _query.isEmpty ||
          i.name.toLowerCase().contains(_query.toLowerCase()) ||
          i.area.toLowerCase().contains(_query.toLowerCase()) ||
          i.carModel.toLowerCase().contains(_query.toLowerCase());
      return inRadius && matchTrans && matchQuery;
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return list.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _nearestInstructors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Cari instruktur, mobil, atau wilayah Purwokerto...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          RadarDriverMap(
            instructors: results,
            radiusKm: _radiusKm,
            userArea: widget.appState.studentLocation,
            selectedInstructor: _selectedPin,
            onSelectInstructor: (inst) => setState(() => _selectedPin = inst),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    const Text('Radius Pencarian:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    ...[3.0, 5.0, 10.0].map((r) {
                      final sel = _radiusKm == r;
                      return GestureDetector(
                        onTap: () => setState(() => _radiusKm = r),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: sel
                                ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])
                                : null,
                            color: sel ? null : AppColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${r.toInt()} km',
                            style: TextStyle(
                              color: sel ? Colors.white : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['Semua', 'Manual', 'Matic'].map((t) {
                    final sel = _transmission == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _transmission = t),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary.withValues(alpha: 0.12) : AppColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? AppColors.primary : Colors.transparent),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t,
                            style: TextStyle(
                              color: sel ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Menampilkan ${results.length} Mitra Terdekat',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const Spacer(),
              const Text(
                'Urut: Jarak terdekat',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (results.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(28),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.location_off_rounded, color: AppColors.textMuted, size: 42),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada mitra aktif di radius ini.\nCoba perlebar radius ke 10 km.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ...results.map((inst) {
              final highlighted = _selectedPin?.id == inst.id;
              return GlassCard(
                highlight: highlighted,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarInitial(initial: inst.initial, size: 50, online: inst.isOnline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      inst.name,
                                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14),
                                    ),
                                  ),
                                  StatusPill(
                                    label: '${inst.distanceKm} km',
                                    color: AppColors.emerald,
                                    icon: Icons.near_me_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                inst.originDriver,
                                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${inst.carModel} • ${inst.plateNumber}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${inst.rating} (${inst.reviews} ulasan)',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 13),
                        const SizedBox(width: 3),
                        const Text('Rem Ganda', style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        ...inst.transmissions.map((t) => Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundAlt,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(t, style: const TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w700)),
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    NeonButton(
                      label: 'Pilih & Booking (${inst.etaMinutes} mnt tiba)',
                      icon: Icons.calendar_month_rounded,
                      width: double.infinity,
                      onPressed: () => widget.onBook(inst),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
