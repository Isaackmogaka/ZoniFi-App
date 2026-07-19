import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../widgets/zonifi_top_bar.dart';
import '../state/wallet_state.dart';
import 'packages_screen.dart';
import 'connected_screen.dart';
import 'error_screen.dart';

class PurchasingScreen extends StatelessWidget {
  final WifiPackage package;

  const PurchasingScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ZonifiTopBar(showBackButton: true),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: AppColors.teal,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Confirm on your phone',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate400,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: "We've sent an M-Pesa prompt to "),
                            const TextSpan(
                              text: '07XX XXX XXX',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: '. Enter your PIN to complete the ${package.label} purchase.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Waiting for confirmation…',
                        style: TextStyle(fontSize: 11, color: AppColors.slate400),
                      ),
                      const SizedBox(height: 32),
                      TextButton(
                        // Marked async now, since we need to AWAIT
                        // startSession() rather than just call it —
                        // it genuinely takes time now (real Firestore
                        // writes), not an instant local-only update.
                        onPressed: () async {
                          final wallet = context.read<WalletState>();
                          final success = await wallet.startSession(
                            cost: package.cost,
                            durationSeconds: package.durationSeconds,
                            packageLabel: package.label,
                          );

                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }

                          // If the purchase succeeded locally but
                          // couldn't sync to Firestore (no internet,
                          // etc.), warn the user clearly rather than
                          // silently proceeding as if everything saved.
                          if (success && wallet.hasSyncError) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Purchase saved on this device, but couldn't "
                                    "sync — check your connection.",
                                  ),
                                  backgroundColor: AppColors.amber,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          }

                          // context.mounted check: after an `await`,
                          // it's possible the user navigated away or
                          // the widget was removed before this code
                          // resumes. Using context after that can
                          // crash — this check guards against that.
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    success ? const ConnectedScreen() : const ErrorScreen(),
                              ),
                            );
                          }
                        },
                        child: const Text('(test) Simulate success'),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.vibrate();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ErrorScreen()),
                          );
                        },
                        child: const Text('(test) Simulate failure'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}