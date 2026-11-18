import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenAuth;

  const ProfileScreen({super.key, required this.onOpenAuth});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        // Profile Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: GlassCardDecoration(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person_rounded, size: 34, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Dimas Aditya P.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Aktif', style: TextStyle(fontSize: 9, color: AppColors.emerald, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Text('ID: LPK-2026-0941 • Purwokerto Utara', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    const Text('Paket Dasar Pemula (Manual)', style: TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Saved Pickup Addresses
        const Text('Titik Jemput Door-to-Door', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: GlassCardDecoration(
            color: const Color(0xCC1A1619),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Kost / Rumah (Utama)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(width: 6),
                        Text('Default', style: TextStyle(fontSize: 9, color: AppColors.primaryLight)),
                      ],
                    ),
                    Text('Kost Putri Melati, Jl. Kampus Grendeng No. 12, Purwokerto Utara', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: GlassCardDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.apartment_rounded, color: AppColors.textSubtle, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kampus FISIP Unsoed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('Jl. HR Boenyamin, Purwokerto Utara', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Riwayat Pembayaran & Invoice
        const Text('Riwayat Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: GlassCardDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paket Dasar Pemula (10 Jam)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('QRIS Auto • INV/LPK/2026/0921', style: TextStyle(fontSize: 10, color: AppColors.textSubtle, fontFamily: 'monospace')),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Rp 1.500.000', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('LUNAS', style: TextStyle(fontSize: 9, color: AppColors.emerald, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tips & Trik Nyetir
        const Text('Tips Mengemudi LPK Indotech', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: GlassCardDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Rumus Stop & Go Tanjakan Baturraden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryLight)),
              SizedBox(height: 4),
              Text(
                'Tarik rem tangan penuh, injak kopling & masuk gigi 1. Tekan gas ke 2000 RPM, angkat kopling perlahan sampai bodi mobil terasa terangkat, lalu lepas rem tangan bertahap.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Hubungi Layanan Siswa
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka WhatsApp Customer Care LPK Indotech...')),
              );
            },
            icon: const Icon(Icons.support_agent_rounded, size: 18),
            label: const Text('Chat Layanan Siswa LPK Indotech'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
