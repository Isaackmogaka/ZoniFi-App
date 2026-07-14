import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/zonifi_top_bar.dart';
import '../state/wallet_state.dart';
import 'packages_screen.dart';

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletState>();

    final progress = wallet.totalSessionSeconds > 0
        ? wallet.secondsRemaining / wallet.totalSessionSeconds
        : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ZonifiTopBar(showBackButton: true),
            Expanded(
              child: Center(
                child: wallet.isConnected
                    ? _buildConnectedContent(wallet, progress)
                    : _buildExpiredContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedContent(WalletState wallet, double progress) {
    return Column(
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
                painter: _RingPainter(progress: progress),
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
        Text(
          _formatDuration(wallet.secondsRemaining),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 30,
            color: AppColors.navy,
          ),
        ),
        const Text(
          'remaining',
          style: TextStyle(fontSize: 11, color: AppColors.slate400),
        ),
        const SizedBox(height: 10),
        Text(
          wallet.lastPackageLabel ?? '',
          style: const TextStyle(fontSize: 11, color: AppColors.slate400),
        ),
      ],
    );
  }

  Widget _buildExpiredContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.slate200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off,
              size: 28,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Session ended',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your Wi-Fi time has run out. Buy another package to reconnect.",
            style: TextStyle(fontSize: 12, color: AppColors.slate400, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PackagesScreen()),
                );
              },
              child: const Text('Buy Wi-Fi'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

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

    const startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * progress.clamp(0.0, 1.0);

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