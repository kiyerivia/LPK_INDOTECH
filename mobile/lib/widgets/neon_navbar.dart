import 'dart:math' as math;
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

/// Matte Curved-Notch Floating Bottom Navigation Bar
/// Uses solid matte CIJ terracotta-red fill (no gradient) with layered drop shadows
/// and a matte warm-gold active indicator.
class NeonArchNavbar extends StatefulWidget {
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
  State<NeonArchNavbar> createState() => _NeonArchNavbarState();
}

class _NeonArchNavbarState extends State<NeonArchNavbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnim;
  double _currentPos = 0;

  @override
  void initState() {
    super.initState();
    _currentPos = widget.currentIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _positionAnim = AlwaysStoppedAnimation(_currentPos);
  }

  @override
  void didUpdateWidget(covariant NeonArchNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final maxIdx = math.max(0, widget.tabs.length - 1);
    final target = widget.currentIndex.clamp(0, maxIdx).toDouble();

    if (oldWidget.tabs.length != widget.tabs.length) {
      _controller.stop();
      _currentPos = target;
      _positionAnim = AlwaysStoppedAnimation(_currentPos);
    } else if (oldWidget.currentIndex != widget.currentIndex) {
      final begin = _positionAnim.value.clamp(0.0, maxIdx.toDouble());
      _positionAnim = Tween<double>(begin: begin, end: target).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
      _currentPos = target;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = widget.tabs.length;
    final safeIndex = widget.currentIndex.clamp(0, tabCount - 1);

    const double totalHeight = 82;
    const double barTop = 18;
    const double barHeight = 64;
    const double circleSize = 46;
    const double sidePad = 8;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SizedBox(
        height: totalHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final innerWidth = totalWidth - (sidePad * 2);
            final tabWidth = innerWidth / tabCount;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final animatedIndex = _positionAnim.value.clamp(0.0, (tabCount - 1).toDouble());
                final notchCenterX = sidePad + (animatedIndex + 0.5) * tabWidth;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Solid Matte Bar with Concave Notch & Layered Shadow
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CurvedNotchBarPainter(
                          notchCenterX: notchCenterX,
                          barTop: barTop,
                          barHeight: barHeight,
                          tabWidth: tabWidth,
                        ),
                      ),
                    ),

                    // 2. Solid Matte Floating Circle in the Notch (No Gradient)
                    Positioned(
                      left: notchCenterX - (circleSize / 2),
                      top: barTop - 15,
                      width: circleSize,
                      height: circleSize,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.navBarBubble,
                          border: Border.all(
                            color: AppColors.navBarActiveIcon.withValues(alpha: 0.55),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2B140E).withValues(alpha: 0.34),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: const Color(0xFF000000).withValues(alpha: 0.14),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Interactive Tab Icons & Labels
                    Positioned(
                      left: sidePad,
                      right: sidePad,
                      top: 0,
                      bottom: 0,
                      child: Row(
                        children: List.generate(tabCount, (index) {
                          final isSelected = safeIndex == index;
                          final tab = widget.tabs[index];

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onTabSelected(index),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                    top: isSelected ? (barTop - 15 + (circleSize - 22) / 2) : (barTop + 13),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(
                                          tab.icon,
                                          size: 22,
                                          color: isSelected
                                              ? AppColors.navBarActiveIcon
                                              : Colors.white.withValues(alpha: 0.82),
                                        ),
                                        if ((tab.badgeCount ?? 0) > 0)
                                          Positioned(
                                            right: -8,
                                            top: -6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.navBarActiveIcon,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: AppColors.navBarBubble, width: 1.4),
                                              ),
                                              child: Text(
                                                '${tab.badgeCount}',
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 2,
                                    right: 2,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.navBarActiveIcon
                                            : Colors.white.withValues(alpha: 0.78),
                                      ),
                                      child: Text(
                                        tab.label,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CurvedNotchBarPainter extends CustomPainter {
  final double notchCenterX;
  final double barTop;
  final double barHeight;
  final double tabWidth;

  _CurvedNotchBarPainter({
    required this.notchCenterX,
    required this.barTop,
    required this.barHeight,
    required this.tabWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final top = barTop;
    final bottom = barTop + barHeight;
    const double cornerR = 18.0;

    final double notchHalfW = math.min(38.0, tabWidth * 0.58);
    final double notchBottom = top + 34.5;

    final double leftShoulder = (notchCenterX - notchHalfW).clamp(cornerR, w - cornerR - 38);
    final double rightShoulder = (notchCenterX + notchHalfW).clamp(cornerR + 38, w - cornerR);
    final double leftSpan = notchCenterX - leftShoulder;
    final double rightSpan = rightShoulder - notchCenterX;

    final path = Path()
      ..moveTo(cornerR, top)
      ..lineTo(leftShoulder, top)
      ..cubicTo(
        leftShoulder + leftSpan * 0.42,
        top,
        notchCenterX - 26,
        notchBottom,
        notchCenterX,
        notchBottom,
      )
      ..cubicTo(
        notchCenterX + 26,
        notchBottom,
        rightShoulder - rightSpan * 0.42,
        top,
        rightShoulder,
        top,
      )
      ..lineTo(w - cornerR, top)
      ..quadraticBezierTo(w, top, w, top + cornerR)
      ..lineTo(w, bottom - cornerR)
      ..quadraticBezierTo(w, bottom, w - cornerR, bottom)
      ..lineTo(cornerR, bottom)
      ..quadraticBezierTo(0, bottom, 0, bottom - cornerR)
      ..lineTo(0, top + cornerR)
      ..quadraticBezierTo(0, top, cornerR, top)
      ..close();

    // Layered Drop Shadow underneath the matte bar
    canvas.drawShadow(
      path.shift(const Offset(0, 6)),
      const Color(0xFF2B140E).withValues(alpha: 0.34),
      16,
      true,
    );

    // Solid Matte Fill (Reddish-Yellow / Terracotta Doff — No Gradient)
    final fillPaint = Paint()
      ..color = AppColors.navBarBg
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Subtle Crisp Rim Edge
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNotchBarPainter oldDelegate) =>
      oldDelegate.notchCenterX != notchCenterX ||
      oldDelegate.tabWidth != tabWidth;
}
