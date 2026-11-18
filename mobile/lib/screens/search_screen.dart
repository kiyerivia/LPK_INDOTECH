import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final Function(Instructor) onBookInstructor;
  final String searchQuery;

  const SearchScreen({
    super.key,
    required this.onBookInstructor,
    this.searchQuery = '',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedRadius = 5;
  String _selectedTransmission = 'all';

  @override
  Widget build(BuildContext context) {
    final filtered = mockInstructors.where((inst) {
      if (inst.distanceKm > _selectedRadius) return false;
      if (_selectedTransmission != 'all') {
        if (!inst.transmission.toLowerCase().contains(_selectedTransmission.toLowerCase())) {
          return false;
        }
      }
      if (widget.searchQuery.isNotEmpty) {
        final q = widget.searchQuery.toLowerCase();
        return inst.name.toLowerCase().contains(q) ||
            inst.locationName.toLowerCase().contains(q) ||
            inst.carModel.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        // Title & Geolocation status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cari Instruktur Terdekat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Grendeng, Purwokerto Utara',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed_rounded, size: 11, color: AppColors.emerald),
                  SizedBox(width: 4),
                  Text('GPS Aktif', style: TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Simulated Radar Grid Container
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Concentric radar rings
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1),
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
                ),
              ),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                ),
              ),

              // Student Center Marker
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGlow.withOpacity(0.8),
                          blurRadius: 16,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Kamu', style: TextStyle(fontSize: 9, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              // Surrounding Instructor Pins
              Positioned(
                top: 25,
                left: 45,
                child: _buildRadarPin('Bambang (1.8km)', true),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: _buildRadarPin('Dewi (2.4km)', false),
              ),
              Positioned(
                bottom: 30,
                left: 60,
                child: _buildRadarPin('Hendra (3.5km)', false),
              ),
              Positioned(
                bottom: 25,
                right: 50,
                child: _buildRadarPin('Ahmad (4.1km)', false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Filter Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Radius Chips
            Row(
              children: [3, 5, 10].map((r) {
                final isSelected = _selectedRadius == r;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRadius = r),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                    ),
                    child: Text(
                      '$r km',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Transmission Chips
            Row(
              children: ['all', 'Manual', 'Matic'].map((t) {
                final isSelected = _selectedTransmission == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTransmission = t),
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.5) : AppColors.cardBorder),
                    ),
                    child: Text(
                      t == 'all' ? 'Semua' : t,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryLight : AppColors.textSubtle,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Instructors List
        ...filtered.map((inst) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: GlassCardDecoration(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          inst.avatar,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inst.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text('${inst.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.amber)),
                                const SizedBox(width: 6),
                                Text('• ${inst.distanceKm} km dari posisimu', style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Text(
                              '${inst.carModel} (${inst.carPlate})',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        inst.dualPedal,
                        style: const TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.cardBorder, height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tarif per Jam:', style: TextStyle(fontSize: 10, color: AppColors.textSubtle)),
                          Text(
                            'Rp ${inst.hourlyRate.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => widget.onBookInstructor(inst),
                        icon: const Icon(Icons.calendar_today_rounded, size: 13),
                        label: const Text('Booking Jadwal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRadarPin(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xCC18181B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? Colors.white : Colors.white.withOpacity(0.15)),
        boxShadow: active
            ? [
                BoxShadow(color: AppColors.primaryGlow.withOpacity(0.6), blurRadius: 10),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}
