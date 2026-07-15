import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/zonifi_top_bar.dart';
import '../state/wallet_state.dart';
import '../state/transaction.dart';

/// TransactionHistoryScreen: a dedicated statement-style screen,
/// matching the pattern used by M-Pesa and most Kenyan fintech apps
/// — full history lives on its own screen, separate from the glanceable
/// Home dashboard.
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletState>();
    final transactions = wallet.transactions;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ZonifiTopBar(showBackButton: true),
              const SizedBox(height: 8),
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                // Same empty-state reasoning as HomeScreen: a plain
                // blank list looks broken to a first-time user, so we
                // branch based on whether any transactions exist yet.
                child: transactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AppColors.slate200,
                        ),
                        itemBuilder: (context, index) {
                          return _buildTransactionTile(transactions[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 32, color: AppColors.slate400),
          const SizedBox(height: 10),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your purchase history will appear here.',
            style: TextStyle(fontSize: 11, color: AppColors.slate400),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.packageLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTimestamp(transaction.timestamp),
                style: const TextStyle(fontSize: 11, color: AppColors.slate400),
              ),
            ],
          ),
          Text(
            '- Ksh ${transaction.cost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// A simple, readable timestamp format, e.g. "15 Jul, 14:32".
  /// Deliberately simple — a full date/time library isn't needed for
  /// something this small.
  String _formatTimestamp(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month, $hour:$minute';
  }
}