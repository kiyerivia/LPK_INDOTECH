import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class BookingBottomSheet extends StatefulWidget {
  final Instructor instructor;
  final DrivingPackage? selectedPackage;

  const BookingBottomSheet({
    super.key,
    required this.instructor,
    this.selectedPackage,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  String _selectedDate = 'Besok, 19 Nov';
  late String _selectedSlot;
  String _transmission = 'Manual';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.instructor.availableSlots.first;
  }

  @override
  Widget build(BuildContext context) {
    final cost = widget.selectedPackage?.price ?? 150000;
    final instructorFee = (cost * 0.60).round();
    final lpkFee = (cost * 0.27).round();
    final platformFee = cost - instructorFee - lpkFee;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: Color(0xFF111115),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.5)),
      ),
      child: _isSuccess
          ? _buildSuccessView(cost)
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Booking Jadwal & Penjemputan', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  const Text('Konfirmasi Sesi Latihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),

                  // Instructor snapshot
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(widget.instructor.avatar, width: 44, height: 44, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.instructor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${widget.instructor.carModel} • ${widget.instructor.distanceKm} km', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              Text(widget.instructor.dualPedal, style: const TextStyle(fontSize: 10, color: AppColors.emerald)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Pilih Hari:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: ['Hari Ini', 'Besok, 19 Nov', 'Lusa, 20 Nov'].map((d) {
                      final isSelected = _selectedDate == d;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDate = d),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),
                  const Text('Slot Waktu (Buffer 30m):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.instructor.availableSlots.map((slot) {
                      final isSelected = _selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textMain,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  // Smart Split Payment
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        _buildSplitRow('Mitra Instruktur (60%)', 'Rp ${instructorFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                        _buildSplitRow('LPK Indotech (27%)', 'Rp ${lpkFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                        _buildSplitRow('Platform & Asuransi (13%)', 'Rp ${platformFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                        const Divider(color: AppColors.cardBorder, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Biaya Pelatihan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(
                              'Rp ${cost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _isSuccess = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Kunci Jadwal & Bayar (QRIS)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSplitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSubtle)),
          Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textMain, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildSuccessView(int cost) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 54),
        const SizedBox(height: 12),
        const Text('Jadwal Berhasil Dikunci!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Instruktur ${widget.instructor.name} akan menjemput ke alamatmu pada $_selectedDate ($_selectedSlot).',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kembali ke Menu Utama', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
