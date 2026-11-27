import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_version.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/biometric_card.dart';
import '../../widgets/common.dart';

class SiswaProfileScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onOpenAuth;

  const SiswaProfileScreen({
    super.key,
    required this.appState,
    required this.onOpenAuth,
  });

  static const List<String> _transmissions = ['Manual (MT)', 'Matic (AT)', 'Keduanya'];

  Future<void> _openEditProfileSheet(BuildContext context) async {
    final nameCtrl = TextEditingController(text: appState.userName);
    final phoneCtrl = TextEditingController(text: appState.userPhone);
    final addressCtrl = TextEditingController(text: appState.studentAddress);
    String selectedArea = appState.serviceAreas.any((a) => a.name == appState.studentLocation)
        ? appState.studentLocation
        : appState.serviceAreas.first.name;
    String selectedTransmission = _transmissions.contains(appState.studentTransmission)
        ? appState.studentTransmission
        : _transmissions.first;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Edit Profil Siswa',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 19),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor WhatsApp',
                    hintText: '0812-xxxx-xxxx',
                    prefixIcon: Icon(Icons.phone_outlined, size: 19),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedArea,
                  decoration: const InputDecoration(
                    labelText: 'Area Jemput Utama',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 19),
                  ),
                  items: appState.serviceAreas
                      .map((a) => DropdownMenuItem(value: a.name, child: Text(a.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedArea = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Detail Alamat / Patokan Jemput',
                    hintText: 'Contoh: Jl. Kampus No. 12, depan gerbang...',
                    prefixIcon: Icon(Icons.home_outlined, size: 19),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pilihan Transmisi Belajar',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _transmissions.map((t) {
                    final active = selectedTransmission == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: active,
                      selectedColor: AppColors.primary.withValues(alpha: 0.16),
                      onSelected: (_) => setModalState(() => selectedTransmission = t),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                NeonButton(
                  label: saving ? 'Menyimpan...' : 'Simpan Perubahan Profil',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.primary,
                  width: double.infinity,
                  onPressed: saving
                      ? null
                      : () async {
                          final cleanName = nameCtrl.text.trim();
                          if (cleanName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama lengkap tidak boleh kosong.'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            return;
                          }
                          setModalState(() => saving = true);
                          appState.updateStudentProfile(
                            fullName: cleanName,
                            phone: phoneCtrl.text,
                            location: selectedArea,
                            address: addressCtrl.text,
                            transmission: selectedTransmission,
                          );

                          // Sync profile metadata to Supabase Auth when signed in
                          try {
                            final client = Supabase.instance.client;
                            if (client.auth.currentUser != null) {
                              await client.auth.updateUser(
                                UserAttributes(
                                  data: {
                                    'full_name': cleanName,
                                    'phone': phoneCtrl.text.trim(),
                                    'pickup_area': selectedArea,
                                    'pickup_address': addressCtrl.text.trim(),
                                    'transmission': selectedTransmission,
                                  },
                                ),
                              );
                            }
                          } catch (_) {}

                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil siswa berhasil diperbarui!'),
                                backgroundColor: AppColors.emerald,
                              ),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = appState.userName.isNotEmpty ? appState.userName : 'Siswa Baru';
    final displayPhone = appState.userPhone.isNotEmpty ? appState.userPhone : 'Belum diisi';
    final displayAddress = appState.studentAddress.isNotEmpty
        ? '${appState.studentLocation} • ${appState.studentAddress}'
        : appState.studentLocation;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AvatarInitial(
                  initial: displayName[0].toUpperCase(),
                  size: 68,
                  online: true,
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  appState.userEmail.isNotEmpty ? appState.userEmail : 'Belum ada email',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                StatusPill(
                  label: appState.isLoggedIn ? 'Akun Siswa Aktif' : 'Belum Login',
                  color: appState.isLoggedIn ? AppColors.emerald : AppColors.primary,
                  icon: Icons.verified_user_rounded,
                ),
                const SizedBox(height: 14),
                if (appState.isLoggedIn)
                  NeonButton(
                    label: 'Edit Profil Siswa',
                    icon: Icons.edit_rounded,
                    outlined: true,
                    color: AppColors.primary,
                    width: double.infinity,
                    onPressed: () => _openEditProfileSheet(context),
                  )
                else
                  NeonButton(
                    label: 'Login / Daftar Akun',
                    icon: Icons.login_rounded,
                    width: double.infinity,
                    onPressed: onOpenAuth,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          BiometricSecurityCard(appState: appState),
          const SizedBox(height: 14),

          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tile(Icons.phone_outlined, 'Nomor WhatsApp', displayPhone, () => _openEditProfileSheet(context)),
                _divider(),
                _tile(Icons.location_on_outlined, 'Alamat Penjemputan Utama', displayAddress, () => _openEditProfileSheet(context)),
                _divider(),
                _tile(Icons.settings_outlined, 'Transmisi Belajar', appState.studentTransmission, () => _openEditProfileSheet(context)),
                _divider(),
                _tile(Icons.receipt_long_outlined, 'Riwayat Booking', '${appState.orders.length} booking tercatat', () {}),
                _divider(),
                _tile(Icons.shield_outlined, 'Standar Keamanan Rem Ganda', 'Semua mobil mitra wajib lulus uji LPK', () {}),
              ],
            ),
          ),

          if (appState.isLoggedIn) ...[
            const SizedBox(height: 14),
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                title: const Text('Keluar Akun', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 14)),
                onTap: appState.logout,
              ),
            ),
          ],

          const SizedBox(height: 16),
          Text(
            AppVersions.driving.shortLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 21),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 54);
}
