import 'package:flutter/material.dart';
import '../models/data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/booking_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  double _radius = 5;
  String _transmisi = 'Semua';
  final _searchCtrl = TextEditingController();
  String _query = '';

  List<Instruktur> get _filtered {
    return mockInstruktur.where((i) {
      final matchRadius = i.jarak <= _radius;
      final matchTransmisi = _transmisi == 'Semua' || i.transmisi.contains(_transmisi);
      final matchQuery = _query.isEmpty || i.nama.toLowerCase().contains(_query.toLowerCase()) || i.wilayah.toLowerCase().contains(_query.toLowerCase());
      return matchRadius && matchTransmisi && matchQuery;
    }).toList()
      ..sort((a, b) => a.jarak.compareTo(b.jarak));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Cari nama instruktur atau wilayah...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.tune),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Radius filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.radar, color: AppTheme.primary, size: 18),
                const SizedBox(width: 10),
                Text('Radius: ${_radius.toInt()} km', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                Expanded(
                  child: Slider(
                    value: _radius,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppTheme.primary,
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Transmisi filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'Manual', 'Matic'].map((t) {
                final sel = _transmisi == t;
                return GestureDetector(
                  onTap: () => setState(() => _transmisi = t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppTheme.primary : Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(t, style: TextStyle(color: sel ? AppTheme.primary : AppTheme.textSecondary, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Result count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text('${_filtered.length} instruktur ditemukan', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),

        // List
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, color: AppTheme.textSecondary, size: 48),
                      SizedBox(height: 10),
                      Text('Tidak ada instruktur\ndi radius ini', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _instrukturCard(context, _filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _instrukturCard(BuildContext context, Instruktur inst) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BookingSheet(instruktur: inst),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AvatarInitial(initial: inst.foto, size: 54),
              if (inst.online)
                Positioned(
                  bottom: 2, right: 2,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: AppTheme.success, shape: BoxShape.circle, border: Border.all(color: AppTheme.bgDark, width: 2)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(inst.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text('${inst.jarak} km', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                StarRating(rating: inst.rating, reviews: inst.ulasan),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 12),
                    const SizedBox(width: 3),
                    Text(inst.wilayah, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const Spacer(),
                    ...inst.transmisi.map((t) => Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(t, style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                    )),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: AppTheme.success, size: 12),
                    const SizedBox(width: 4),
                    const Text('Rem Ganda', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${inst.pengalaman} thn pengalaman', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
