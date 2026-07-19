import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// OtpScreen: now requires the phone number from LoginScreen, so the
/// "Code sent to..." text reflects what the user actually entered,
/// instead of a hardcoded placeholder.
class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// True only when every one of the 6 boxes has a digit in it.
  bool get _isComplete =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  /// Called automatically the instant the 6th digit lands — no manual
  /// "Verify" tap needed. In Phase 1/2 scope, this still just
  /// navigates to Home; real code-checking against Firebase comes
  /// once billing/Blaze is sorted for real SMS.
  void _autoVerify() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  /// Clears all 6 boxes, refocuses the first one, and gives the user
  /// clear feedback that a new code was "sent" — real SMS resending
  /// logic is Phase 5/6 work once Firebase Phone Auth is fully wired,
  /// but the UI behavior itself is genuine now, not a dead link.
  void _resendCode() {
    HapticFeedback.lightImpact();
    for (final controller in _controllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new code has been sent'),
        duration: Duration(seconds: 2),
      ),
    );
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
                  children: [
                    const TextSpan(text: 'Code sent to '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildDigitBox(index)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Still tappable manually too, in case someone
                  // prefers pressing it rather than relying on
                  // auto-advance — but disabled until complete, since
                  // there's nothing valid to verify otherwise.
                  onPressed: !_isComplete ? null : _autoVerify,
                  child: const Text('Verify'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _resendCode,
                  child: const Text(
                    "Didn't get a code? Resend",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
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
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }

          // Check completeness on EVERY keystroke (not just the last
          // box), since the user could type out of order or paste —
          // setState() triggers here so the Verify button's
          // enabled/disabled state updates live too.
          setState(() {});

          // The instant all 6 are filled, auto-advance — no manual
          // tap needed. We check this after the setState above so
          // _isComplete reflects the very latest keystroke.
          if (_isComplete) {
            // Unfocus the keyboard first, since we're about to
            // navigate away — leaving it focused can cause a visual
            // flicker as the new screen builds underneath it.
            FocusScope.of(context).unfocus();
            _autoVerify();
          }
        },
      ),
    );
  }
}