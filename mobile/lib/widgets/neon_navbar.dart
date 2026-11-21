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

/// Liquid Curved-Notch Floating Navbar (Inspired directly by Menu_Animation.mp4)
/// Features a sleek rounded bar with an animated concave U-shaped cutout and a
/// floating circular bubble that glides fluidly to cradle the active tab icon.
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
      duration: const Duration(milliseconds: 420),
    );
    _positionAnim = AlwaysStoppedAnimation(_currentPos);
  }

  @override
  void didUpdateWidget(covariant NeonArchNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final maxIdx = math.max(0, widget.tabs.length - 1);
    final target = widget.currentIndex.clamp(0, maxIdx).toDouble();

    if (oldWidget.tabs.length != widget.tabs.length) {
      // Role switched (tab count changed) — snap cleanly to new tab
      _controller.stop();
      _currentPos = target;
      _positionAnim = AlwaysStoppedAnimation(_currentPos);
    } else if (oldWidget.currentIndex != widget.currentIndex) {
      final begin = _positionAnim.value.clamp(0.0, maxIdx.toDouble());
      _positionAnim = Tween<double>(begin: begin, end: target).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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

  Color get _activeIconGlow {
    if (widget.accentColor == AppColors.emerald) {
      return const Color(0xFF2DD4BF); // Luminous Mint-Teal (Mitra)
    } else if (widget.accentColor == AppColors.purple) {
      return const Color(0xFFC084FC); // Luminous Lavender (Admin)
    }
    return const Color(0xFFFFB800); // Signature Luminous Gold from Menu_Animation.mp4 (Siswa)
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = widget.tabs.length;
    final safeIndex = widget.currentIndex.clamp(0, tabCount - 1);

    const double totalHeight = 84;
    const double barTop = 20;
    const double barHeight = 64;
    const double circleSize = 46;
    const double sidePad = 8;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    // 1. Sleek Rounded Bar with Dynamic Concave U-Notch Cutout
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CurvedNotchBarPainter(
                          notchCenterX: notchCenterX,
                          barTop: barTop,
                          barHeight: barHeight,
                          tabWidth: tabWidth,
                          accentColor: widget.accentColor,
                        ),
                      ),
                    ),

                    // 2. Gliding Floating Circular Bubble Nestled in the Concave Notch
                    Positioned(
                      left: notchCenterX - (circleSize / 2),
                      top: barTop - 16,
                      width: circleSize,
                      height: circleSize,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1E293B), // Futuristic Slate
                              Color(0xFF0B1120), // Deep Obsidian Navy
                            ],
                          ),
                          border: Border.all(
                            color: _activeIconGlow.withValues(alpha: 0.45),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.32),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: _activeIconGlow.withValues(alpha: 0.25),
                              blurRadius: 14,
                              spreadRadius: -2,
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
                                  // Animated Icon — rises smoothly into the floating circle when active
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 340),
                                    curve: Curves.easeOutBack,
                                    top: isSelected ? (barTop - 16 + (circleSize - 23) / 2) : (barTop + 14),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedScale(
                                          scale: isSelected ? 1.08 : 0.96,
                                          duration: const Duration(milliseconds: 280),
                                          curve: Curves.easeOutBack,
                                          child: Icon(
                                            tab.icon,
                                            size: 23,
                                            color: isSelected
                                                ? _activeIconGlow
                                                : Colors.white.withValues(alpha: 0.85),
                                            shadows: isSelected
                                                ? [
                                                    Shadow(
                                                      color: _activeIconGlow.withValues(alpha: 0.65),
                                                      blurRadius: 10,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        if ((tab.badgeCount ?? 0) > 0)
                                          Positioned(
                                            right: -8,
                                            top: -6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.emerald,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
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
                                  ),

                                  // Crisp Label tucked cleanly along the bottom of the bar
                                  Positioned(
                                    bottom: 7,
                                    left: 2,
                                    right: 2,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 240),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                        color: isSelected
                                            ? _activeIconGlow
                                            : Colors.white.withValues(alpha: 0.62),
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
  final Color accentColor;

  _CurvedNotchBarPainter({
    required this.notchCenterX,
    required this.barTop,
    required this.barHeight,
    required this.tabWidth,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final top = barTop;
    final bottom = barTop + barHeight;
    const double cornerR = 20.0;

    // Smooth organic U-notch parameters matching Menu_Animation.mp4
    final double notchHalfW = math.min(40.0, tabWidth * 0.60);
    final double notchBottom = top + 36.5;

    final double leftShoulder = (notchCenterX - notchHalfW).clamp(cornerR, w - cornerR - 40);
    final double rightShoulder = (notchCenterX + notchHalfW).clamp(cornerR + 40, w - cornerR);
    final double leftSpan = notchCenterX - leftShoulder;
    final double rightSpan = rightShoulder - notchCenterX;

    final path = Path()
      ..moveTo(cornerR, top)
      ..lineTo(leftShoulder, top)
      // Smooth S-curve down into circular cradle
      ..cubicTo(
        leftShoulder + leftSpan * 0.42,
        top,
        notchCenterX - 27,
        notchBottom,
        notchCenterX,
        notchBottom,
      )
      // Smooth S-curve back up to top edge
      ..cubicTo(
        notchCenterX + 27,
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

    // Soft Floating Shadow underneath the notched bar
    canvas.drawShadow(
      path.shift(const Offset(0, 6)),
      const Color(0xFF0F172A).withValues(alpha: 0.35),
      18,
      true,
    );

    // Sleek Deep Midnight Futuristic Gradient Fill
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF131C31),
          Color(0xFF0B1120),
        ],
      ).createShader(Rect.fromLTWH(0, top, w, barHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Subtle Crisp Glass Rim Highlight along the notched silhouette
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          accentColor.withValues(alpha: 0.12),
        ],
      ).createShader(Rect.fromLTWH(0, top, w, barHeight))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedNotchBarPainter oldDelegate) =>
      oldDelegate.notchCenterX != notchCenterX ||
      oldDelegate.tabWidth != tabWidth ||
      oldDelegate.accentColor != accentColor;
}
