import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavTabItem {
  final String label;
  final IconData icon;
  final int? badgeCount;

  const NavTabItem({
    required this.label,
    required this.icon,
    this.badgeCount,
  });
}

/// Floating Frosted Pearl Glass Navbar with Futuristic Neon Arch (Video V5)
class NeonArchNavbar extends StatelessWidget {
  final List<NavTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Color accentColor;

  const NeonArchNavbar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex.clamp(0, tabs.length - 1);

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          final indicatorLeft = safeIndex * tabWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Subtle Bottom Futuristic Accent Line
              Positioned(
                bottom: 0,
                left: 36,
                right: 36,
                height: 2.5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        accentColor.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Animated Neon Arch Bell-Curve Rising Over Active Tab
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                left: indicatorLeft,
                top: -14,
                width: tabWidth,
                height: 52,
                child: CustomPaint(
                  painter: _NeonArchPainter(color: accentColor),
                ),
              ),

              // Tabs Row
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = safeIndex == index;
                  final tab = tabs[index];

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        alignment: Alignment.center,
                        transform: Matrix4.translationValues(0, isSelected ? -3 : 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  tab.icon,
                                  size: 21,
                                  color: isSelected ? accentColor : AppColors.textMuted,
                                ),
                                if ((tab.badgeCount ?? 0) > 0)
                                  Positioned(
                                    right: -7,
                                    top: -5,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.emerald,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: Text(
                                        '${tab.badgeCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tab.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? accentColor : AppColors.textMuted,
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
          );
        },
      ),
    );
  }
}

class _NeonArchPainter extends CustomPainter {
  final Color color;
  _NeonArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const archWidth = 44.0;
    final leftX = centerX - (archWidth / 2);
    final rightX = centerX + (archWidth / 2);

    final path = Path()
      ..moveTo(leftX - 8, size.height)
      ..cubicTo(leftX + 2, size.height, leftX + 4, 8, centerX, 8)
      ..cubicTo(rightX - 4, 8, rightX - 2, size.height, rightX + 8, size.height);

    // 1. Soft Ambient Glow Under Arch
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.24), Colors.transparent],
        radius: 0.85,
      ).createShader(Rect.fromCircle(center: Offset(centerX, 20), radius: 24));
    canvas.drawCircle(Offset(centerX, 20), 20, glowPaint);

    // 2. Soft Luminous Outer Halo
    final blurPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, blurPaint);

    // 3. Crisp Futuristic Gradient Stroke
    final crispPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, Color.lerp(color, Colors.cyanAccent, 0.35)!, color],
      ).createShader(Rect.fromLTWH(leftX - 8, 8, archWidth + 16, size.height))
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, crispPaint);

    // 4. Center Jewel Dot
    final dotRing = Paint()..color = color;
    final dotCore = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(centerX, 8), 3.4, dotRing);
    canvas.drawCircle(Offset(centerX, 8), 1.6, dotCore);
  }

  @override
  bool shouldRepaint(covariant _NeonArchPainter oldDelegate) => oldDelegate.color != color;
}
