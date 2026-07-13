import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/zonifi_top_bar.dart';
import '../state/wallet_state.dart';
import 'packages_screen.dart';

/// HomeScreen: balance card + Buy Wi-Fi + usage stats.
/// Values are hardcoded for now (Ksh 100.00, 30:00, 50 MB) — proving
/// the layout is correct. Real data comes from state management later.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch<WalletState>() does two things: grabs the current
    // value right now, AND tells Flutter "rebuild this widget whenever
    // WalletState calls notifyListeners()." No setState() needed here
    // — Provider handles triggering the rebuild for us.
    final wallet = context.watch<WalletState>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ZonifiTopBar(showBackButton: false),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ksh ${wallet.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PackagesScreen()),
                  );
                },
                  child: const Text('BUY WI-FI'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Usage',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStat(
                    value: _formatDuration(wallet.secondsRemaining),
                    label: 'remaining',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.slate200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _buildStat(
                    value: wallet.lastPackageLabel ?? '—',
                    label: 'last package',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    wallet.isConnected ? Icons.wifi : Icons.wifi_off,
                    size: 14,
                    color: wallet.isConnected ? AppColors.teal : AppColors.slate400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    wallet.isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: wallet.isConnected ? AppColors.teal : AppColors.slate400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Converts a raw seconds count into "MM:SS" display format, e.g.
  /// 1800 seconds becomes "30:00". padLeft(2, '0') ensures single
  /// digits show as "05" instead of "5", matching the mockup's format.
  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildStat({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.navy,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.slate400),
        ),
      ],
    );
  }
}