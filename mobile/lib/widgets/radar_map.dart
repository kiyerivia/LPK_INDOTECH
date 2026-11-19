import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

/// Sleek Futuristic Light-Tech GPS Radar & Nearest Driver Map (Apple Maps / Tesla vibe)
class RadarDriverMap extends StatefulWidget {
  final List<Instructor> instructors;
  final double radiusKm;
  final String userArea;
  final Instructor? selectedInstructor;
  final ValueChanged<Instructor> onSelectInstructor;

  const RadarDriverMap({
    super.key,
    required this.instructors,
    required this.radiusKm,
    required this.userArea,
    required this.selectedInstructor,
    required this.onSelectInstructor,
  });

  @override
  State<RadarDriverMap> createState() => _RadarDriverMapState();
}

class _RadarDriverMapState extends State<RadarDriverMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF3FF), Color(0xFFDFEEFD)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: [
                // Clean Vector Map Grid & Cyan Radar Pulse
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, _) => CustomPaint(
                    size: Size(w, h),
                    painter: _RadarGridPainter(
                      progress: _pulseCtrl.value,
                      radiusFactor: (widget.radiusKm / 10).clamp(0.35, 1.0),
                    ),
                  ),
                ),

                // Top-left Live Radar Tag
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.emerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RADAR GPS • ${widget.userArea}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top-right Radius Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${widget.instructors.length} Driver • ≤${widget.radiusKm.toInt()} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // User GPS Center Pin
                Positioned(
                  left: w * 0.5 - 24,
                  top: h * 0.5 - 22,
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                          ],
                        ),
                        child: const Text(
                          'Lokasi Kamu',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),

                // Clickable Nearest Driver Pins
                ...widget.instructors.take(5).map((inst) {
                  final isSelected = widget.selectedInstructor?.id == inst.id;
                  return Positioned(
                    left: (w * inst.mapX - 28).clamp(8.0, w - 76),
                    top: (h * inst.mapY - 22).clamp(40.0, h - 54),
                    child: GestureDetector(
                      onTap: () => widget.onSelectInstructor(inst),
                      child: AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])
                                : null,
                            color: isSelected ? null : Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.white : AppColors.emerald.withValues(alpha: 0.65),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected ? AppColors.primary : Colors.black)
                                    .withValues(alpha: isSelected ? 0.35 : 0.10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                color: isSelected ? Colors.white : AppColors.emerald,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${inst.distanceKm}km',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  final double progress;
  final double radiusFactor;

  _RadarGridPainter({required this.progress, required this.radiusFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Subtle Crisp Blueprint Street Grid
    final gridPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Clean White Major Roads
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 4;
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.32), roadPaint);
    canvas.drawLine(Offset(size.width * 0.28, 0), Offset(size.width * 0.62, size.height), roadPaint);

    // Concentric Futuristic Radar Rings
    final maxR = (size.shortestSide * 0.48) * radiusFactor;
    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawCircle(center, maxR * 0.45, ringPaint);
    canvas.drawCircle(center, maxR * 0.78, ringPaint);
    canvas.drawCircle(center, maxR, ringPaint);

    // Expanding Cyan Pulse Wave
    final waveRadius = maxR * progress;
    final wavePaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: (1 - progress) * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, waveRadius, wavePaint);

    final fillWave = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: (1 - progress) * 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, waveRadius, fillWave);
  }

  @override
  bool shouldRepaint(covariant _RadarGridPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.radiusFactor != radiusFactor;
}
