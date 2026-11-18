import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonArchNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onSearchTriggered;

  const NeonArchNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onSearchTriggered,
  });

  @override
  State<NeonArchNavbar> createState() => _NeonArchNavbarState();
}

class _NeonArchNavbarState extends State<NeonArchNavbar> {
  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Beranda', 'icon': Icons.home_rounded},
    {'label': 'Cari', 'icon': Icons.search_rounded},
    {'label': 'Jadwal', 'icon': Icons.calendar_month_rounded},
    {'label': 'Rapor', 'icon': Icons.military_tech_rounded},
    {'label': 'Profil', 'icon': Icons.person_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xE80C0C0E), // 92% dark glass pill
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle Bottom Neon Glow Line
          Positioned(
            bottom: 0,
            left: 30,
            right: 30,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Fluid Neon Arch Indicator that animates horizontally
          LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / _tabs.length;
              final indicatorLeft = widget.currentIndex * tabWidth;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                left: indicatorLeft,
                top: -14, // Rises above the navbar like in Video V5
                width: tabWidth,
                height: 52,
                child: CustomPaint(
                  painter: _NeonArchPainter(),
                ),
              );
            },
          ),

          // Nav Items Row
          Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = widget.currentIndex == index;
              final tab = _tabs[index];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.onTabSelected(index);
                    if (index == 1) {
                      widget.onSearchTriggered();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    alignment: Alignment.center,
                    transform: Matrix4.translationValues(
                      0,
                      isSelected ? -4 : 0,
                      0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 22,
                          color: isSelected ? AppColors.primary : AppColors.textSubtle,
                          shadows: isSelected
                              ? [
                                  Shadow(
                                    color: AppColors.primaryGlow.withOpacity(0.8),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primaryLight : AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NeonArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final archWidth = 44.0;
    final leftX = centerX - (archWidth / 2);
    final rightX = centerX + (archWidth / 2);

    // Smooth Bell-Curve Path
    final path = Path();
    path.moveTo(leftX - 8, size.height);
    path.cubicTo(
      leftX + 2,
      size.height,
      leftX + 4,
      8,
      centerX,
      8,
    );
    path.cubicTo(
      rightX - 4,
      8,
      rightX - 2,
      size.height,
      rightX + 8,
      size.height,
    );

    // 1. Ambient Radial Glow Under the Arch
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.35),
          Colors.transparent,
        ],
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: Offset(centerX, 20), radius: 24));
    canvas.drawCircle(Offset(centerX, 20), 20, glowPaint);

    // 2. Blurred Glow Stroke
    final blurPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, blurPaint);

    // 3. Crisp Bright Neon Stroke
    final crispPaint = Paint()
      ..color = AppColors.primaryGlow
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, crispPaint);

    // 4. White Center Jewel Dot at Top Peak
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(centerX, 8), 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
