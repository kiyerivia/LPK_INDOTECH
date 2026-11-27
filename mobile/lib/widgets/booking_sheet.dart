import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class BookingSheet extends StatefulWidget {
  final AppState appState;
  final Instructor instructor;
  final DrivingPackage? initialPackage;

  const BookingSheet({
    super.key,
    required this.appState,
    required this.instructor,
    this.initialPackage,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  late DrivingPackage _selectedPkg;
  late String _selectedTransmisi;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '09:00 - 11:00 WIB';
  String _paymentMethod = 'QRIS Instan';
  late TextEditingController _addressCtrl;
  int _step = 0;

  final _slots = const [
    '07:00 - 09:00 WIB',
    '09:00 - 11:00 WIB',
    '13:00 - 15:00 WIB',
    '15:30 - 17:30 WIB',
  ];

  final _payments = const ['QRIS Instan', 'Virtual Account BCA', 'GoPay / OVO / DANA'];

  @override
  void initState() {
    super.initState();
    _selectedPkg = widget.initialPackage ?? widget.appState.packages[1];
    _selectedTransmisi = widget.instructor.transmissions.first;
    _addressCtrl = TextEditingController(
      text: 'Jl. Kampus Grendeng No. 45, ${widget.appState.studentLocation}',
    );
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  void _confirmBooking() {
    widget.appState.createBooking(
      instructor: widget.instructor,
      package: _selectedPkg,
      date: _selectedDate,
      timeSlot: _selectedSlot,
      transmission: _selectedTransmisi,
      pickupAddress: _addressCtrl.text.trim(),
    );
    setState(() => _step = 3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),

            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  AvatarInitial(initial: widget.instructor.initial, size: 46, online: widget.instructor.isOnline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.instructor.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.instructor.carModel} • ${widget.instructor.plateNumber}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.near_me_rounded, color: AppColors.primary, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.instructor.distanceKm} km (±${widget.instructor.etaMinutes} mnt)',
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const StatusPill(
                    label: 'Rem Ganda',
                    color: AppColors.emerald,
                    icon: Icons.verified_user_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_step < 3) _buildSteps(),
            if (_step < 3) const SizedBox(height: 16),

            if (_step == 0) _buildStepPaket(),
            if (_step == 1) _buildStepJadwal(),
            if (_step == 2) _buildStepPaymentSplit(),
            if (_step == 3) _buildSuccess(),

            const SizedBox(height: 18),

            if (_step < 3)
              Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      flex: 2,
                      child: NeonButton(
                        label: 'Kembali',
                        outlined: true,
                        onPressed: () => setState(() => _step--),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 3,
                    child: NeonButton(
                      label: _step == 0
                          ? 'Pilih Jadwal'
                          : _step == 1
                              ? 'Review & Bayar'
                              : 'Bayar & Order Mitra',
                      icon: _step == 2 ? Icons.lock_rounded : Icons.arrow_forward_rounded,
                      color: _step == 2 ? AppColors.emerald : AppColors.primary,
                      onPressed: () {
                        if (_step < 2) {
                          setState(() => _step++);
                        } else {
                          _confirmBooking();
                        }
                      },
                    ),
                  ),
                ],
              )
            else
              NeonButton(
                label: 'Lihat di Jadwal Saya',
                width: double.infinity,
                icon: Icons.calendar_month_rounded,
                onPressed: () => Navigator.of(context).pop(true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps() {
    const labels = ['Paket & Jemput', 'Jadwal', 'Smart Split'];
    return Row(
      children: List.generate(labels.length, (i) {
        final active = i == _step;
        final done = i < _step;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.emerald
                      : active
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: active ? Colors.white : AppColors.textMuted,
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepPaket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Titik Penjemputan Siswa (GPS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _addressCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.primary),
            hintText: 'Masukkan alamat jemput di Purwokerto...',
          ),
        ),
        const SizedBox(height: 14),
        const Text('Pilih Transmisi Mobil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: widget.instructor.transmissions.map((t) {
            final sel = _selectedTransmisi == t;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTransmisi = t),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.borderSubtle, width: sel ? 1.5 : 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t,
                    style: TextStyle(
                      color: sel ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const Text('Pilih Paket Pelatihan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        ...widget.appState.packages.map((pkg) {
          final sel = _selectedPkg.id == pkg.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedPkg = pkg),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? AppColors.primary : AppColors.borderSubtle, width: sel ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13)),
                            if (pkg.isPopular) ...[
                              const SizedBox(width: 6),
                              const StatusPill(label: 'Populer', color: AppColors.amber),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${pkg.sessions}x pertemuan • ${pkg.description}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatRupiah(pkg.price),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepJadwal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Mulai Sesi Pertama', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: const Text('Ubah', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Slot Waktu Tersedia (2 Jam/Sesi)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _slots.map((s) {
            final sel = _selectedSlot == s;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.borderSubtle, width: sel ? 1.5 : 1),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    color: sel ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const Text('Metode Pembayaran Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        ..._payments.map((m) {
          final sel = _paymentMethod == m;
          return GestureDetector(
            onTap: () => setState(() => _paymentMethod = m),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: sel ? AppColors.emerald.withValues(alpha: 0.10) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? AppColors.emerald : AppColors.borderSubtle, width: sel ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Icon(
                    sel ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 18,
                    color: sel ? AppColors.emerald : AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Text(m, style: TextStyle(color: sel ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepPaymentSplit() {
    final mitraAmt = (_selectedPkg.price * widget.appState.mitraSplitPercent / 100).round();
    final lpkAmt = (_selectedPkg.price * widget.appState.lpkSplitPercent / 100).round();
    final platformAmt = _selectedPkg.price - mitraAmt - lpkAmt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              InfoRow(icon: Icons.school_rounded, label: 'Paket', value: '${_selectedPkg.name} (${_selectedPkg.sessions}x)'),
              InfoRow(icon: Icons.directions_car_rounded, label: 'Transmisi', value: _selectedTransmisi),
              InfoRow(icon: Icons.calendar_today_rounded, label: 'Jadwal Sesi 1', value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} • $_selectedSlot'),
              InfoRow(icon: Icons.location_on_rounded, label: 'Titik Jemput', value: _addressCtrl.text),
              InfoRow(icon: Icons.payment_rounded, label: 'Pembayaran', value: _paymentMethod),
              const Divider(height: 18),
              InfoRow(
                icon: Icons.receipt_long_rounded,
                label: 'Total Pembayaran',
                value: formatRupiah(_selectedPkg.price),
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          highlight: true,
          highlightColor: AppColors.emerald,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: AppColors.emerald, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Transparansi Smart Split Otomatis',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _splitRow('Mitra Instruktur (${widget.appState.mitraSplitPercent}%)', formatRupiah(mitraAmt), AppColors.emerald),
              _splitRow('LPK INDOTECH — Kurikulum & Sertifikat (${widget.appState.lpkSplitPercent}%)', formatRupiah(lpkAmt), AppColors.primary),
              _splitRow('Platform & Asuransi Latihan (${widget.appState.platformSplitPercent}%)', formatRupiah(platformAmt), AppColors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _splitRow(String label, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))),
          Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.emerald,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Order Terkirim',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.instructor.name} (${widget.instructor.plateNumber}) telah menerima permintaan jadwal Anda.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
