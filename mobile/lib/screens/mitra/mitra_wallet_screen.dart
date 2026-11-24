import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class MitraWalletScreen extends StatelessWidget {
  final AppState appState;

  const MitraWalletScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    const targetSessions = 25;
    final progress = (appState.mitraMonthlySessions / targetSessions).clamp(0.0, 1.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Dompet Insentif Mitra LPK', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(appState.mitraWalletBalance),
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart Split ${appState.mitraSplitPercent}% otomatis cair ke saldo setelah sesi selesai',
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: appState.mitraWalletBalance >= 100000
                        ? () => _showWithdrawSheet(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.emerald,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.outbox_rounded, size: 18),
                    label: const Text('Tarik Saldo ke Rekening / E-Wallet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
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
                  children: [
                    const Text('Bonus Insentif Bulanan LPK', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                    const Spacer(),
                    Text(
                      '${appState.mitraMonthlySessions}/$targetSessions Sesi',
                      style: const TextStyle(color: AppColors.amber, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation(AppColors.amber),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  appState.mitraMonthlySessions >= targetSessions
                      ? 'Target tercapai! Bonus +Rp 350.000 siap dicairkan.'
                      : 'Selesaikan ${targetSessions - appState.mitraMonthlySessions} sesi lagi untuk bonus +Rp 350.000.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('Riwayat Insentif & Pencairan', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          if (appState.walletTransactions.isEmpty)
            const GlassCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada riwayat insentif atau penarikan saldo. Insentif 60% otomatis masuk setelah sesi pelatihan selesai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            )
          else
            ...appState.walletTransactions.map((trx) => GlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (trx.isCredit ? AppColors.emerald : AppColors.primary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        trx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: trx.isCredit ? AppColors.emerald : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trx.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('${trx.subtitle} • ${trx.dateLabel}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Text(
                      '${trx.isCredit ? '+' : '-'}${formatRupiah(trx.amount)}',
                      style: TextStyle(
                        color: trx.isCredit ? AppColors.emerald : AppColors.danger,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    int selectedAmt = 500000;
    String bank = 'BCA ****4821';
    if (selectedAmt > appState.mitraWalletBalance) selectedAmt = appState.mitraWalletBalance;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tarik Saldo Mitra', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [250000, 500000, 1000000].where((a) => a <= appState.mitraWalletBalance).map((amt) {
                  final sel = selectedAmt == amt;
                  return ChoiceChip(
                    label: Text(formatRupiah(amt)),
                    selected: sel,
                    selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                    onSelected: (_) => setModalState(() => selectedAmt = amt),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['BCA ****4821', 'BRI ****1102', 'GoPay 0812-xxx'].map((b) {
                  return ChoiceChip(
                    label: Text(b),
                    selected: bank == b,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (_) => setModalState(() => bank = b),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              NeonButton(
                label: 'Cairkan ${formatRupiah(selectedAmt)}',
                color: AppColors.emerald,
                width: double.infinity,
                onPressed: () {
                  appState.withdrawWallet(selectedAmt, bank);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Penarikan ${formatRupiah(selectedAmt)} ke $bank berhasil!'), backgroundColor: AppColors.emerald),
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
