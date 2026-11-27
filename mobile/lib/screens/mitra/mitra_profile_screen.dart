import 'package:flutter/material.dart';
import '../../config/app_version.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/biometric_card.dart';
import '../../widgets/common.dart';

class MitraProfileScreen extends StatefulWidget {
  final AppState appState;

  const MitraProfileScreen({super.key, required this.appState});

  @override
  State<MitraProfileScreen> createState() => _MitraProfileScreenState();
}

class _MitraProfileScreenState extends State<MitraProfileScreen> {
  final List<String> _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final Set<String> _activeDays = {'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'};

  @override
  Widget build(BuildContext context) {
    final app = widget.appState;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BiometricSecurityCard(appState: app),
          const SizedBox(height: 14),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 20),
                    SizedBox(width: 8),
                    Text('Dokumen & Verifikasi Mitra LPK', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                _docRow('Identitas e-KTP & SKCK', 'Belum diunggah'),
                _docRow('SIM A Umum / SIM B1 Aktif', 'Menunggu verifikasi'),
                _docRow('STNK & Armada (${app.mitraCarInfo})', 'Menunggu verifikasi'),
                _docRow('Braket Pedal Rem Ganda Standar LPK', 'Wajib Uji Safety LPK'),
                _docRow('Sertifikasi Mengajar (TOT Instruktur)', 'LPK Citra Indotech Jaya'),
                const SizedBox(height: 12),
                NeonButton(
                  label: 'Daftar / Ajukan Mitra Driver Baru (KYC)',
                  icon: Icons.upload_file_rounded,
                  outlined: true,
                  color: AppColors.emerald,
                  width: double.infinity,
                  onPressed: () => _openMitraRegistrationSheet(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Radius Area Layanan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                    Text('${app.mitraServiceRadius.toInt()} km', style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800)),
                  ],
                ),
                Slider(
                  value: app.mitraServiceRadius,
                  min: 3,
                  max: 10,
                  divisions: 7,
                  activeColor: AppColors.emerald,
                  inactiveColor: AppColors.borderSubtle,
                  onChanged: app.setMitraRadius,
                ),
                const SizedBox(height: 6),
                const Text('Kecamatan Purwokerto Aktif:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: app.serviceAreas.map((area) {
                    final active = app.mitraServiceAreas.contains(area.name);
                    return GestureDetector(
                      onTap: () => app.toggleMitraArea(area.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? AppColors.emerald.withValues(alpha: 0.14) : AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: active ? AppColors.emerald : Colors.transparent),
                        ),
                        child: Text(
                          area.name,
                          style: TextStyle(
                            color: active ? AppColors.emerald : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jadwal Tersedia Mingguan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _days.map((d) {
                    final sel = _activeDays.contains(d);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (sel && _activeDays.length > 1) {
                          _activeDays.remove(d);
                        } else {
                          _activeDays.add(d);
                        }
                      }),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.22),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          d,
                          style: TextStyle(
                            color: sel ? Colors.white : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              AppVersions.partner.shortLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docRow(String title, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          Text(status, style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _openMitraRegistrationSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final carCtrl = TextEditingController(text: 'Daihatsu Xenia MT • R 2210 XY');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pendaftaran Mitra Instruktur Baru', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Data pengajuan langsung masuk ke antrean Verifikasi KYC Admin LPK.', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Driver')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. WhatsApp')),
              const SizedBox(height: 10),
              TextField(controller: carCtrl, decoration: const InputDecoration(labelText: 'Unit Mobil & Plat Nomor')),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.check_box_rounded, color: AppColors.emerald, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Upload KTP, SIM, STNK & Foto Braket Rem Ganda (Terlampir)', style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NeonButton(
                label: 'Kirim Pengajuan ke Admin LPK',
                icon: Icons.send_rounded,
                color: AppColors.emerald,
                width: double.infinity,
                onPressed: () {
                  widget.appState.registerNewMitraApplication(
                    name: nameCtrl.text.trim().isEmpty ? 'Wahyu Saputra' : nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim().isEmpty ? '0812-9988-7766' : phoneCtrl.text.trim(),
                    carInfo: carCtrl.text.trim(),
                    simType: 'SIM A Umum',
                    area: 'Purwokerto Utara',
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengajuan dikirim dan menunggu verifikasi Admin LPK.'),
                      backgroundColor: AppColors.emerald,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
