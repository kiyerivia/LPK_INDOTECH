import 'package:flutter/material.dart';
import '../models/data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class BookingSheet extends StatefulWidget {
  final Instruktur instruktur;

  const BookingSheet({super.key, required this.instruktur});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  PaketLatihan? _selectedPaket;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedJam = '09:00';
  int _step = 0; // 0=paket, 1=jadwal, 2=konfirmasi, 3=sukses

  final List<String> _jamList = ['07:00', '09:00', '11:00', '13:00', '15:00', '17:00'];

  void _nextStep() {
    if (_step < 3) setState(() => _step++);
    if (_step == 3) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12121A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // Instruktur info
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AvatarInitial(initial: widget.instruktur.foto, size: 50),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.instruktur.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      StarRating(rating: widget.instruktur.rating, reviews: widget.instruktur.ulasan),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_outlined, color: AppTheme.success, size: 12),
                          SizedBox(width: 3),
                          Text('Rem Ganda', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Step indicator
          _buildStepIndicator(),
          const SizedBox(height: 20),

          // Step content
          if (_step == 0) _buildPilihPaket(),
          if (_step == 1) _buildPilihJadwal(),
          if (_step == 2) _buildKonfirmasi(),
          if (_step == 3) _buildSukses(),

          const SizedBox(height: 16),

          // CTA button
          if (_step < 3)
            NeonButton(
              label: _step == 0 ? 'Pilih Jadwal →' : _step == 1 ? 'Konfirmasi →' : 'Bayar & Booking',
              onPressed: (_step == 0 && _selectedPaket == null) ? null : _nextStep,
              width: double.infinity,
              icon: _step == 2 ? Icons.payment : Icons.arrow_forward,
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Paket', 'Jadwal', 'Konfirmasi'];
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i == _step;
        final done = i < _step;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppTheme.success : active ? AppTheme.primary : Colors.white.withOpacity(0.1),
                  border: Border.all(color: active ? AppTheme.primary : Colors.transparent),
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text('${i + 1}', style: TextStyle(color: active ? Colors.white : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              Text(steps[i], style: TextStyle(color: active ? AppTheme.textPrimary : AppTheme.textSecondary, fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
              if (i < steps.length - 1) ...[
                const SizedBox(width: 6),
                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                const SizedBox(width: 6),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPilihPaket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Paket Pelatihan', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        ...mockPaket.map((p) {
          final selected = _selectedPaket?.id == p.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedPaket = p),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? AppTheme.primary : Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14)),
                            if (p.terpopuler) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Populer', style: TextStyle(color: AppTheme.warning, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${p.sesi} sesi · ${p.deskripsi}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp${(p.harga / 1000).toStringAsFixed(0)}rb',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 15),
                      ),
                      if (selected) const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPilihJadwal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Tanggal & Jam', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        // Date picker
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.calendar_today, color: AppTheme.primary, size: 20),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    builder: (ctx, child) => Theme(
                      data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppTheme.primary)),
                      child: child!,
                    ),
                  );
                  if (d != null) setState(() => _selectedDate = d);
                },
                child: const Text('Ganti', style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Pilih Jam', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: _jamList.map((j) {
            final sel = j == _selectedJam;
            return GestureDetector(
              onTap: () => setState(() => _selectedJam = j),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? AppTheme.primary : Colors.white.withOpacity(0.1)),
                ),
                child: Text(j, style: TextStyle(color: sel ? AppTheme.primary : AppTheme.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKonfirmasi() {
    final instrukturShare = (_selectedPaket!.harga * 0.60).round();
    final lpkShare = (_selectedPaket!.harga * 0.27).round();
    final platformShare = (_selectedPaket!.harga * 0.13).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan Booking', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              InfoRow(icon: Icons.person_outline, label: 'Instruktur', value: widget.instruktur.nama),
              InfoRow(icon: Icons.school_outlined, label: 'Paket', value: _selectedPaket!.nama),
              InfoRow(icon: Icons.calendar_today, label: 'Tanggal', value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              InfoRow(icon: Icons.access_time, label: 'Jam', value: _selectedJam),
              const Divider(height: 20),
              InfoRow(icon: Icons.payments_outlined, label: 'Total Bayar', value: 'Rp${(_selectedPaket!.harga / 1000).toStringAsFixed(0)}rb', valueColor: AppTheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transparansi Pembagian 💰', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              _splitRow('Instruktur (60%)', 'Rp${(instrukturShare / 1000).toStringAsFixed(0)}rb', AppTheme.success),
              _splitRow('LPK INDOTECH (27%)', 'Rp${(lpkShare / 1000).toStringAsFixed(0)}rb', AppTheme.info),
              _splitRow('Platform (13%)', 'Rp${(platformShare / 1000).toStringAsFixed(0)}rb', AppTheme.warning),
            ],
          ),
        ),
      ],
    );
  }

  Widget _splitRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSukses() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.success, Color(0xFF059669)]),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 16),
        const Text('Booking Berhasil! 🎉', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text('Instruktur akan menghubungi Anda via WhatsApp', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
      ],
    );
  }
}
