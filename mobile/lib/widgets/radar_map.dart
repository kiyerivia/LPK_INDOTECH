import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'google_map_embed_stub.dart'
    if (dart.library.js_interop) 'google_map_embed_web.dart'
    as gmaps;

/// Interactive Google Maps + Live GPS Radar Overlay for CIJ Driving
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
  bool _satellite = false;
  bool _locatingGps = false;
  ({double lat, double lng})? _liveGps;

  /// Real Purwokerto & Banyumas coordinates for each service area
  static const Map<String, ({double lat, double lng})> _areaCoords = {
    'Purwokerto Utara': (lat: -7.4095, lng: 109.2470),
    'Purwokerto Timur': (lat: -7.4244, lng: 109.2485),
    'Purwokerto Selatan': (lat: -7.4455, lng: 109.2398),
    'Purwokerto Barat': (lat: -7.4260, lng: 109.2220),
    'Sokaraja': (lat: -7.4565, lng: 109.2896),
    'Baturraden': (lat: -7.3133, lng: 109.2286),
  };

  ({double lat, double lng}) get _activeCoords =>
      _liveGps ??
      _areaCoords[widget.userArea] ??
      const (lat: -7.4244, lng: 109.2396);

  int get _zoomForRadius {
    if (widget.radiusKm <= 3.0) return 14;
    if (widget.radiusKm <= 5.0) return 13;
    return 12;
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant RadarDriverMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userArea != widget.userArea) {
      _liveGps = null; // Re-center to newly chosen area
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _locateMe() async {
    setState(() => _locatingGps = true);
    final pos = await gmaps.getBrowserGpsPosition();
    if (!mounted) return;
    setState(() {
      _locatingGps = false;
      if (pos != null) _liveGps = pos;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pos != null
              ? 'GPS terkunci di (${pos.lat.toStringAsFixed(4)}, ${pos.lng.toStringAsFixed(4)})'
              : 'Izin lokasi belum aktif — menggunakan koordinat ${widget.userArea}.',
        ),
        backgroundColor: pos != null ? AppColors.emerald : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coords = _activeCoords;
    final mapWidget = gmaps.buildGoogleMapEmbed(
      lat: coords.lat,
      lng: coords.lng,
      zoom: _zoomForRadius,
      mapType: _satellite ? 'k' : 'm',
    );
    final hasGoogleMap = mapWidget != null;

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F1D1A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: [
                // Layer 1: Live Google Maps (Web) or Crisp Vector Grid Fallback (Tests/Native)
                if (hasGoogleMap)
                  Positioned.fill(child: mapWidget)
                else
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => CustomPaint(
                      size: Size(w, h),
                      painter: _RadarGridPainter(
                        progress: _pulseCtrl.value,
                        radiusFactor: (widget.radiusKm / 10).clamp(0.35, 1.0),
                        drawBackgroundGrid: true,
                      ),
                    ),
                  ),

                // Layer 2: Translucent Cyan Radar Pulse Overlay on top of Google Maps (non-blocking)
                if (hasGoogleMap)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, _) => CustomPaint(
                          size: Size(w, h),
                          painter: _RadarGridPainter(
                            progress: _pulseCtrl.value,
                            radiusFactor: (widget.radiusKm / 10).clamp(
                              0.35,
                              1.0,
                            ),
                            drawBackgroundGrid: false,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Top-left Live Google Maps + Radar Tag
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
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
                          _liveGps != null ? 'GPS Aktif' : widget.userArea,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top-right Radius & Active Drivers Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF292524),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.instructors.length} Mitra (${widget.radiusKm.toInt()} km)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Center User GPS Pin (only when fallback vector map is shown; Google Maps has its own pin!)
                if (!hasGoogleMap)
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
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Lokasi Kamu',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
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
                    top: (h * inst.mapY - 22).clamp(44.0, h - 68),
                    child: GestureDetector(
                      onTap: () => widget.onSelectInstructor(inst),
                      child: AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary.withValues(alpha: 0.55),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isSelected
                                            ? AppColors.primary
                                            : Colors.black)
                                        .withValues(
                                          alpha: isSelected ? 0.30 : 0.14,
                                        ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_car_rounded,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.emerald,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${inst.distanceKm}km',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
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

                // Bottom-left Map / Satellite Layer Toggle
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _satellite = !_satellite),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _satellite
                                ? Icons.map_rounded
                                : Icons.satellite_alt_rounded,
                            size: 13,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _satellite ? 'Mode Peta' : 'Satelit',
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
                ),

                // Bottom-right Real GPS & Open in Google Maps Controls
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _locatingGps ? null : _locateMe,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.my_location_rounded,
                                size: 13,
                                color: _liveGps != null
                                    ? AppColors.emerald
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _locatingGps ? 'Mencari...' : 'GPS Saya',
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
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            gmaps.openInGoogleMaps(coords.lat, coords.lng),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.open_in_new_rounded,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
  final bool drawBackgroundGrid;

  _RadarGridPainter({
    required this.progress,
    required this.radiusFactor,
    required this.drawBackgroundGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (drawBackgroundGrid) {
      final gridPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.06)
        ..strokeWidth = 1;

      for (double x = 0; x < size.width; x += 28) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += 28) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }

      final roadPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 4;
      canvas.drawLine(
        Offset(0, size.height * 0.65),
        Offset(size.width, size.height * 0.32),
        roadPaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.28, 0),
        Offset(size.width * 0.62, size.height),
        roadPaint,
      );
    }

    // Concentric Radar Rings
    final maxR = (size.shortestSide * 0.44) * radiusFactor;
    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(
        alpha: drawBackgroundGrid ? 0.18 : 0.32,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawCircle(center, maxR * 0.5, ringPaint);
    canvas.drawCircle(center, maxR, ringPaint);

    // Expanding Cyan Pulse Wave
    final waveRadius = maxR * progress;
    final wavePaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: (1 - progress) * 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(center, waveRadius, wavePaint);

    final fillWave = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: (1 - progress) * 0.14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, waveRadius, fillWave);
  }

  @override
  bool shouldRepaint(covariant _RadarGridPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.radiusFactor != radiusFactor ||
      oldDelegate.drawBackgroundGrid != drawBackgroundGrid;
}
