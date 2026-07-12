import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// OtpScreen: the 6-digit code verification step after LoginScreen.
///
/// WHY STATEFUL: as the user types each digit, we need to (a) track
/// what's been typed so far, and (b) automatically move the cursor to
/// the next box. Both of those are "this screen's own data changing
/// while it's alive" — the exact signal for StatefulWidget, same
/// reasoning as PackagesScreen.
///
/// PHASE 1 SCOPE: tapping "Verify" does nothing real yet. No actual
/// code is sent or checked — that's Firebase Phone Auth, Phase 5.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // One controller PER digit box. A TextEditingController is Flutter's
  // way of reading/writing what's inside a TextField — we need 6
  // separate ones since we have 6 separate boxes, not one field.
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  // FocusNode lets us programmatically move the keyboard's focus from
  // one box to the next — this is what creates the "auto-advance"
  // feel as you type, instead of manually tapping each box yourself.
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    // Every controller and focus node we create must be manually
    // cleaned up when this screen is removed, or it leaks memory.
    // This is a Flutter-specific responsibility that doesn't exist in,
    // say, plain HTML forms — Flutter doesn't clean these up for you
    // automatically.
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

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
                'Enter verification code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.slate400),
                  children: const [
                    TextSpan(text: 'Code sent to '),
                    TextSpan(
                      text: '+254 7XX XXX XXX',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Row of 6 boxes, evenly spaced using spaceBetween so
              // they stay readable on both small and large phones.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildDigitBox(index)),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('Verify'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Didn't get a code? Resend",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1, // exactly one digit per box
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
        decoration: InputDecoration(
          counterText: '', // hides Flutter's default "0/1" character counter
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        // onChanged fires every time the user types (or deletes) a
        // character in THIS box. We use it to decide whether to jump
        // focus forward (typed a digit) or backward (deleted a digit).
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            // Move focus to the next box once this one has a digit.
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            // Move focus back if the user deleted a digit.
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }
}