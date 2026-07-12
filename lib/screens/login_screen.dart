import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

/// LoginScreen: collects a phone number, then (in the real app) sends
/// an OTP via SMS. Replaces the earlier email/password version — a
/// better fit for the Kenyan market, where M-Pesa already ties almost
/// every user to a phone number, and it skips "forgot password"
/// entirely.
///
/// PHASE 1 RULE: still intentionally "dumb." Tapping "Send code" does
/// nothing real yet — no actual SMS is sent. That requires Firebase
/// Phone Auth, which is Phase 5 work. Right now we're only proving
/// this layout is correct.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We'll text you a code to verify it's you.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(height: 32),

              // The phone field is split into two parts: a fixed
              // "+254" country-code prefix (Kenya), and the actual
              // number field. Splitting them like this prevents users
              // from accidentally typing the country code wrong or
              // forgetting it — a common source of failed SMS delivery
              // in real apps.
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+254',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '7XX XXX XXX',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const OtpScreen()),
                     );
                   },
                  child: const Text('Send code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}