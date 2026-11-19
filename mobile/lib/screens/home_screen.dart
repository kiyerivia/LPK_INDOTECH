import 'package:flutter/material.dart';
import '../models/data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/booking_sheet.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final VoidCallback onSearchTap;

  const HomeScreen({super.key, required this.userName, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(context),
          const SizedBox(height: 8),
          _buildStats(),
          const SizedBox(height: 8),
          SectionHeader(title: '🔥 Instruktur Terdekat', actionLabel: 'Lihat Semua', onAction: onSearchTap),
          _buildInstrukturList(context),
          const SizedBox(height: 8),
          SectionHeader(title: '📦 Paket Pelatihan', actionLabel: 'Semua Paket', onAction: onSearchTap),
          _buildPaketList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark.withOpacity(0.8), AppTheme.bgDark],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: -5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: AppTheme.success, size: 12),
                    SizedBox(width: 4),
                    Text('Purwokerto', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: AppTheme.primary, size: 12),
                    SizedBox(width: 4),
                    Text('LPK Resmi', style: TextStyle(color: AppTheme.textPrimary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Hai, $userName! 👋', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Belajar Mengemudi\nDimulai dari Sini 🚗', style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.15))),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                  SizedBox(width: 10),
                  Text('Cari instruktur terdekat...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      {'icon': Icons.people, 'value': '500+', 'label': 'Siswa', 'color': AppTheme.info},
      {'icon': Icons.drive_eta, 'value': '45', 'label': 'Instruktur', 'color': AppTheme.success},
      {'icon': Icons.star, 'value': '4.8', 'label': 'Rating', 'color': AppTheme.warning},
      {'icon': Icons.school, 'value': '98%', 'label': 'Lulus', 'color': AppTheme.primary},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: AppTheme.glassCard(),
              child: Column(
                children: [
                  Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
                  const SizedBox(height: 4),
                  Text(s['value'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 15)),
                  Text(s['label'] as String, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstrukturList(BuildContext context) {
    final online = mockInstruktur.where((i) => i.online).take(3).toList();
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: online.length,
        itemBuilder: (_, i) {
          final inst = online[i];
          return GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BookingSheet(instruktur: inst),
            ),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.glassCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AvatarInitial(initial: inst.foto, size: 42),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Online', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(inst.nama.split(' ').take(2).join(' '), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  StarRating(rating: inst.rating, reviews: inst.ulasan),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primary, size: 12),
                      const SizedBox(width: 3),
                      Text('${inst.jarak} km', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: inst.transmisi.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(t, style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaketList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: mockPaket.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: p.terpopuler ? AppTheme.glassCardHighlight() : AppTheme.glassCard(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          if (p.terpopuler) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: const Text('Terpopuler', style: TextStyle(color: AppTheme.warning, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${p.sesi} sesi pelatihan', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rp${(p.harga / 1000000).toStringAsFixed(1)}jt', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
                    const Text('total', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
