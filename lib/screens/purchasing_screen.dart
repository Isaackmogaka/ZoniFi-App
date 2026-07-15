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
                      // TEMPORARY, Phase 2 only: these two buttons let us
                      // manually test both outcomes of a purchase, since
                      // the real M-Pesa success/failure simulation comes
                      // in Phase 6. Remove these once that logic exists.
                      TextButton(
                        onPressed: () {
                          // context.read (not watch) — this is a one-time
                          // action inside a callback, not something that
                          // needs to rebuild this widget. read() grabs
                          // the current WalletState once and calls a
                          // method on it.
                          final success = context.read<WalletState>().startSession(
                                cost: package.cost,
                                durationSeconds: package.durationSeconds,
                                packageLabel: package.label,
                              );
                          // Choose the haptic based on the REAL outcome,
                          // not an assumption — startSession() can still
                          // return false here if balance was insufficient,
                          // even though this button is labeled "success."
                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }
                          // Choose the haptic based on the REAL outcome,
                          // not an assumption — startSession() can still
                          // return false here if balance was insufficient,
                          // even though this button is labeled "success."
                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }
                          // Choose the haptic based on the REAL outcome,
                          // not an assumption — startSession() can still
                          // return false here if balance was insufficient,
                          // even though this button is labeled "success."
                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }
                          // Choose the haptic based on the REAL outcome,
                          // not an assumption — startSession() can still
                          // return false here if balance was insufficient,
                          // even though this button is labeled "success."
                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }
                          // Choose the haptic based on the REAL outcome,
                          // not an assumption — startSession() can still
                          // return false here if balance was insufficient,
                          // even though this button is labeled "success."
                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }
                          // Choose the haptic based on the REAL outcome,
                          // not an assumption — startSession() can still
                          // return false here if balance was insufficient,
                          // even though this button is labeled "success."
                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }
                          // Choose the haptic based on the REAL outcome,
                          // not an assumption — startSession() can still
                          // return false here if balance was insufficient,
                          // even though this button is labeled "success."
                          if (success) {
                            HapticFeedback.mediumImpact();
                          } else {
                            HapticFeedback.vibrate();
                          }
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  success ? const ConnectedScreen() : const ErrorScreen(),
                            ),
                          );
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