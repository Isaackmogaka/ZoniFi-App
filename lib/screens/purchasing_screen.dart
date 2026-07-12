import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/zonifi_top_bar.dart';
import 'connected_screen.dart';
import 'error_screen.dart';

class PurchasingScreen extends StatelessWidget {
  const PurchasingScreen({super.key});

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
                          children: const [
                            TextSpan(text: "We've sent an M-Pesa prompt to "),
                            TextSpan(
                              text: '07XX XXX XXX',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: '. Enter your PIN to complete the Ksh 20 purchase.',
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ConnectedScreen()),
                          );
                        },
                        child: const Text('(test) Simulate success'),
                      ),
                      TextButton(
                        onPressed: () {
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