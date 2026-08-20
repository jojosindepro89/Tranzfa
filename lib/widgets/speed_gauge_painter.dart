import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeedGaugeWidget extends StatelessWidget {
  final double value; // 0.0 to 1.0 (speed value)
  final double width;
  final double height;

  const SpeedGaugeWidget({
    super.key,
    this.value = 0.78,
    this.width = 240,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle radial glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.goldPrimary.withOpacity(0.18),
                    AppTheme.emeraldAccent.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Custom Gauge Dial & Needle
          CustomPaint(
            size: Size(width, height),
            painter: SpeedGaugePainter(speedRatio: value),
          ),

          // Exchange Arrows + Dollar Icon Badge (Top Right of Gauge)
          Positioned(
            top: 12,
            right: width * 0.18,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF07241A),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.emeraldAccent.withOpacity(0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.emeraldAccent.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.sync,
                    color: AppTheme.emeraldAccent,
                    size: 20,
                  ),
                  Text(
                    '\$',
                    style: TextStyle(
                      color: AppTheme.emeraldAccent.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Segmented Progress Bar at Bottom of Card
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Inactive Green Segment
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldDark.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                // Active Glowing Gold Bar Segment
                Container(
                  width: 64,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldPrimary.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Inactive Green Segment
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldDark.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpeedGaugePainter extends CustomPainter {
  final double speedRatio;

  SpeedGaugePainter({required this.speedRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final radius = math.min(size.width, size.height) * 0.38;

    // Track Arc (Outer dark glow arc)
    final trackPaint = Paint()
      ..color = AppTheme.emeraldDark.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    const startAngle = math.pi * 0.85; // ~153 degrees
    const sweepAngle = math.pi * 1.30; // ~234 degrees

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active Golden Arc
    final activeArcPaint = Paint()
      ..color = AppTheme.goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    final activeSweep = sweepAngle * speedRatio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activeArcPaint,
    );

    // Speedometer Center Knob / Hub Fill
    final centerHubPaint = Paint()
      ..color = AppTheme.goldPrimary
      ..style = PaintingStyle.fill;

    // Outer Glow for Hub
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = AppTheme.goldPrimary.withOpacity(0.9)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Solid Hub Dome shape (semi dome)
    final R = radius * 0.68;
    final hubRect = Rect.fromCircle(center: center, radius: R);
    final hubPath = Path()
      ..addArc(hubRect, math.pi * 0.8, math.pi * 1.4)
      ..close();
    canvas.drawPath(hubPath, centerHubPaint);

    // Needle Pointer Drawing
    final needleAngle = startAngle + activeSweep;
    final needleLength = radius * 0.75;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = const Color(0xFF131313)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);
  }

  @override
  bool shouldRepaint(covariant SpeedGaugePainter oldDelegate) {
    return oldDelegate.speedRatio != speedRatio;
  }
}
