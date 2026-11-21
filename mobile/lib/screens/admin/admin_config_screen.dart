import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/biometric_card.dart';
import '../../widgets/common.dart';

class AdminConfigScreen extends StatefulWidget {
  final AppState appState;

  const AdminConfigScreen({super.key, required this.appState});

  @override
  State<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<AdminConfigScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final accounts = AuthService.allAccounts;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biometric Security Card for Super Admin
          BiometricSecurityCard(appState: appState),
          const SizedBox(height: 16),

          // Hierarchy & Master Verification Header
          Row(
            children: [
              Expanded(
                child: Text(
                  appState.isMaster
                      ? 'Otoritas Verifikasi MASTER INDOTECH'
                      : 'Manajemen Akun Super Admin / LPK',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              GestureDetector(
                onTap: () => _openCreateAccountSheet(context),
                child: const StatusPill(
                  label: '+ Tambah Akun',
                  color: AppColors.purple,
                  icon: Icons.person_add_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: accounts.map((acc) {
                final badgeColor = acc.isMaster
                    ? AppColors.amber
                    : acc.isSuperAdmin
                        ? AppColors.purple
                        : acc.role == UserRole.admin
                            ? AppColors.primary
                            : acc.role == UserRole.mitra
                                ? AppColors.emerald
                                : AppColors.primaryLight;
                final badgeLabel = acc.isMaster
                    ? 'MASTER INDOTECH'
                    : acc.isSuperAdmin
                        ? 'SUPER ADMIN / LPK'
                        : acc.role == UserRole.admin
                            ? (acc.verifiedByMaster ? 'ADMIN / LPK' : 'PENDING MASTER')
                            : acc.role == UserRole.mitra
                                ? 'MITRA'
                                : 'SISWA';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      AvatarInitial(
                        initial: acc.isMaster
                            ? 'M'
                            : (acc.fullName.isNotEmpty ? acc.fullName[0].toUpperCase() : 'U'),
                        size: 38,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acc.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12.5),
                            ),
                            Text(
                              '${acc.username} • ${acc.email}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (appState.isMaster && !acc.isMaster && !acc.verifiedByMaster)
                        GestureDetector(
                          onTap: () {
                            AuthService.setAccountVerifiedByMaster(acc.username, true);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${acc.fullName} resmi diverifikasi oleh MASTER INDOTECH!'),
                                backgroundColor: AppColors.emerald,
                              ),
                            );
                          },
                          child: const StatusPill(
                            label: 'Verifikasi',
                            color: AppColors.emerald,
                            icon: Icons.verified_rounded,
                          ),
                        )
                      else
                        StatusPill(
                          label: badgeLabel,
                          color: badgeColor,
                          icon: acc.isMaster ? Icons.workspace_premium_rounded : null,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Smart Split Config
          const Text('Pengaturan Tarif & Bagi Hasil Otomatis', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bagian Mitra Driver:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('${appState.mitraSplitPercent}%', style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800)),
                  ],
                ),
                Slider(
                  value: appState.mitraSplitPercent.toDouble(),
                  min: 50,
                  max: 70,
                  divisions: 20,
                  activeColor: AppColors.emerald,
                  inactiveColor: AppColors.borderSubtle,
                  onChanged: (v) => appState.updateSplit(v.round(), appState.lpkSplitPercent),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bagian LPK INDOTECH:', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('${appState.lpkSplitPercent}%', style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w800)),
                  ],
                ),
                Slider(
                  value: appState.lpkSplitPercent.toDouble(),
                  min: 15,
                  max: 35,
                  divisions: 20,
                  activeColor: AppColors.purple,
                  inactiveColor: AppColors.borderSubtle,
                  onChanged: (v) => appState.updateSplit(appState.mitraSplitPercent, v.round()),
                ),
                InfoRow(
                  icon: Icons.memory_rounded,
                  label: 'Platform & Asuransi (Otomatis)',
                  value: '${appState.platformSplitPercent}%',
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Service Areas Management
          const Text('Kelola Wilayah Layanan Purwokerto', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: appState.serviceAreas.asMap().entries.map((entry) {
                final idx = entry.key;
                final area = entry.value;
                return SwitchListTile(
                  dense: true,
                  title: Text(area.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: Text('${area.activeDrivers} mitra driver terdaftar', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.emerald,
                  value: area.active,
                  onChanged: (_) => appState.toggleServiceArea(idx),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Curriculum Standards
          const Text('Kurikulum Standar LPK (5 Modul)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...appState.modules.map((m) => GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.purple, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
                          Text(m.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _openCreateAccountSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    UserRole role = UserRole.admin;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
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
                const Text('Buat Akun Baru (Khusus Super Admin)', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Super Admin / LPK'),
                      selected: role == UserRole.admin,
                      onSelected: (_) => setModalState(() => role = UserRole.admin),
                    ),
                    ChoiceChip(
                      label: const Text('Mitra Driver'),
                      selected: role == UserRole.mitra,
                      onSelected: (_) => setModalState(() => role = UserRole.mitra),
                    ),
                    ChoiceChip(
                      label: const Text('Siswa'),
                      selected: role == UserRole.siswa,
                      onSelected: (_) => setModalState(() => role = UserRole.siswa),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email / Username')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'No. WhatsApp')),
                const SizedBox(height: 10),
                TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Kata Sandi (min. 6 karakter)')),
                const SizedBox(height: 16),
                NeonButton(
                  label: 'Simpan Akun Baru',
                  icon: Icons.person_add_rounded,
                  color: AppColors.purple,
                  width: double.infinity,
                  onPressed: () async {
                    final res = await AuthService.register(
                      fullName: nameCtrl.text,
                      phone: phoneCtrl.text,
                      email: emailCtrl.text,
                      password: passCtrl.text,
                      role: role,
                      allowAdminCreation: true,
                    );
                    if (!context.mounted) return;
                    if (res.success) {
                      Navigator.pop(ctx);
                      setState(() {});
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res.message),
                        backgroundColor: res.success ? AppColors.emerald : AppColors.danger,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
