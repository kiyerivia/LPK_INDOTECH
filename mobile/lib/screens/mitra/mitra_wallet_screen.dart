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
    final progress = (appState.mitraMonthlySessions / targetSessions).clamp(
      0.0,
      1.0,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.matteBanner(
              color: AppColors.navBarBg,
              radius: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.navBarActiveIcon,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Saldo Siap Cair',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(appState.mitraWalletBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appState.mitraEscrowBalance > 0
                      ? 'Dana ditahan: ${formatRupiah(appState.mitraEscrowBalance)} (cair setelah kursus selesai)'
                      : 'Bagi hasil ${appState.mitraSplitPercent}% masuk otomatis setelah kursus mengemudi selesai',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: appState.canWithdrawMitraWallet
                        ? () => _showWithdrawSheet(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.white.withValues(
                        alpha: 0.72,
                      ),
                      disabledForegroundColor: AppColors.textMuted,
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.16),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.account_balance_rounded, size: 18),
                    label: Text(
                      appState.canWithdrawMitraWallet
                          ? 'Cairkan ke Rekening Bank'
                          : 'Selesaikan Kursus untuk Cairkan',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (appState.mitraEscrowBalance > 0) ...[
            const SizedBox(height: 12),
            GlassCard(
              highlight: true,
              highlightColor: AppColors.amber,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      color: AppColors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dana Ditahan (Kursus Berjalan)',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatRupiah(appState.mitraEscrowBalance)} akan otomatis cair ke saldo setelah kursus selesai.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Bonus Insentif Bulanan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${appState.mitraMonthlySessions}/$targetSessions Sesi',
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Riwayat Insentif & Pencairan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
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
            ...appState.walletTransactions.map(
              (trx) => GlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            (trx.isCredit
                                    ? AppColors.emerald
                                    : AppColors.primary)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        trx.isCredit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: trx.isCredit
                            ? AppColors.emerald
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trx.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${trx.subtitle} • ${trx.dateLabel}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${trx.isCredit ? '+' : '-'}${formatRupiah(trx.amount)}',
                      style: TextStyle(
                        color: trx.isCredit
                            ? AppColors.emerald
                            : AppColors.danger,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    final balance = appState.mitraWalletBalance;
    int selectedAmt = balance;
    String bank = 'Bank BCA ****4821';
    final presets = <int>{
      if (balance >= 250000) 250000,
      if (balance >= 500000) 500000,
      balance,
    }.toList()..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cairkan ke Rekening Bank',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((amt) {
                    final sel = selectedAmt == amt;
                    return ChoiceChip(
                      label: Text(
                        amt == balance
                            ? 'Semua (${formatRupiah(amt)})'
                            : formatRupiah(amt),
                      ),
                      selected: sel,
                      selectedColor: AppColors.primary.withValues(alpha: 0.16),
                      onSelected: (_) => setModalState(() => selectedAmt = amt),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        'Bank BCA ****4821',
                        'Bank BRI ****1102',
                        'Bank Mandiri ****8830',
                      ].map((b) {
                        return ChoiceChip(
                          label: Text(b),
                          selected: bank == b,
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.16,
                          ),
                          onSelected: (_) => setModalState(() => bank = b),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: 'Cairkan ${formatRupiah(selectedAmt)}',
                  color: AppColors.primary,
                  width: double.infinity,
                  onPressed: () {
                    final ok = appState.withdrawWallet(selectedAmt, bank);
                    Navigator.pop(ctx);
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pencairan ${formatRupiah(selectedAmt)} ke $bank berhasil.',
                          ),
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
}
