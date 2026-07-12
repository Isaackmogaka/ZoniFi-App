import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/zonifi_top_bar.dart';

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ZonifiTopBar(showBackButton: true),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(140, 140),
                            painter: _RingPainter(progress: 0.95),
                          ),
                          const Icon(Icons.wifi, size: 28, color: AppColors.navy),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'CONNECTED',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '29:45',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        color: AppColors.navy,
                      ),
                    ),
                    const Text('remaining', style: TextStyle(fontSize: 11, color: AppColors.slate400)),
                    const SizedBox(height: 10),
                    const Text('50 MB used', style: TextStyle(fontSize: 11, color: AppColors.slate400)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// _RingPainter: the raw drawing instructions for the ring.
/// paint() draws it; shouldRepaint() tells Flutter when to redraw.
class _RingPainter extends CustomPainter {
  final double progress; // 0.0 = empty, 1.0 = full circle

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    final trackPaint = Paint()
      ..color = AppColors.slate200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14159 / 2; // start at 12 o'clock
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}