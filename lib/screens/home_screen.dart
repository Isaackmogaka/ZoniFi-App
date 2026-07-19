import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/zonifi_top_bar.dart';
import '../state/wallet_state.dart';
import 'packages_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletState>();
    final hasEverPurchased = wallet.lastPackageLabel != null;

    return Scaffold(
      body: SafeArea(
        // RefreshIndicator wraps scrollable content and gives the
        // native "pull down, see a spinner, release to refresh"
        // gesture for free. onRefresh must return a Future — the
        // spinner stays visible until that Future completes, which is
        // exactly what loadUserData() already gives us since it's
        // async.
        child: RefreshIndicator(
          onRefresh: () => context.read<WalletState>().loadUserData(),
          child: SingleChildScrollView(
            // AlwaysScrollableScrollPhysics is important here: without
            // it, RefreshIndicator's pull gesture only works when
            // there's enough content to actually scroll. Since Home's
            // content is often shorter than the screen (especially the
            // empty state), this physics setting forces the pull
            // gesture to work even when nothing needs to scroll yet.
            physics: const AlwaysScrollableScrollPhysics(),
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
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: wallet.balance),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Text(
                              'Ksh ${value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          },
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
                  if (hasEverPurchased)
                    _buildUsageStats(context, wallet)
                  else
                    _buildEmptyState(),
                  // A little extra bottom space so the last bit of
                  // content isn't flush against the screen edge when
                  // scrolled all the way down.
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsageStats(BuildContext context, WalletState wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Usage',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.navy,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionHistoryScreen(),
                  ),
                );
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_find, size: 28, color: AppColors.slate400),
          const SizedBox(height: 10),
          const Text(
            'No Wi-Fi purchased yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Buy a package above to get connected.',
            style: TextStyle(fontSize: 11, color: AppColors.slate400),
            textAlign: TextAlign.center,
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